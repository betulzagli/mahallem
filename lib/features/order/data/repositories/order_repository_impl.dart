import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/utils/delivery_fee_calculator.dart';

/// [OrderRepository] arayüzünün somut implementasyonu.
///
/// Stok rezervasyonu, market alt siparişleri, süre takibi, kurye simülasyonu ve iptal/iade
/// kurallarını Cloud Firestore ve yerel bellek desteğiyle yönetir.
class OrderRepositoryImpl implements OrderRepository {
  final bool _isFirebaseReady;
  final FirebaseFirestore? _firestore;
  final ProductRepository _productRepository;

  final List<OrderEntity> _memoryOrders = [];
  final _ordersStreamController = StreamController<List<OrderEntity>>.broadcast();

  OrderRepositoryImpl({
    bool isFirebaseReady = false,
    FirebaseFirestore? firestore,
    required ProductRepository productRepository,
  })  : _isFirebaseReady = isFirebaseReady,
        _firestore = firestore,
        _productRepository = productRepository {
    _ordersStreamController.add(_memoryOrders);
  }

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    // 1. Validate max 3 stores rule
    if (order.subOrders.length > AppConstants.maxMarketsPerOrder) {
      throw Exception('Sipariş başına en fazla 3 market bulunabilir.');
    }

    // 2. Validate latest stock and reserve
    for (final item in order.items) {
      final product = await _productRepository.getProductById(item.productId);
      if (product == null || product.stock < item.quantity) {
        throw Exception('${item.productName} için yetersiz stok!');
      }
    }

    // Reserve stock immediately
    for (final item in order.items) {
      final product = await _productRepository.getProductById(item.productId);
      if (product != null) {
        await _productRepository.updateStock(product.id, product.stock - item.quantity);
      }
    }

    final newOrder = order.copyWith(isStockReleased: false);

    if (_isFirebaseReady && _firestore != null) {
      await _firestore.collection('orders').doc(newOrder.id).set(_toFirestore(newOrder));
    }

    _memoryOrders.insert(0, newOrder);
    _ordersStreamController.add(_memoryOrders);
    return newOrder;
  }

  @override
  Future<List<OrderEntity>> getCustomerOrders(String customerId) async {
    await _evaluateAllTimeouts();
    if (_isFirebaseReady && _firestore != null) {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _fromFirestore(doc.id, doc.data())).toList();
    }
    return _memoryOrders.where((o) => o.customerId == customerId).toList();
  }

  @override
  Future<List<OrderEntity>> getStoreOrders(String storeId) async {
    await _evaluateAllTimeouts();
    if (_isFirebaseReady && _firestore != null) {
      final snapshot = await _firestore
          .collection('orders')
          .where('storeOwnerIds', arrayContains: storeId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _fromFirestore(doc.id, doc.data())).toList();
    }
    return _memoryOrders.where((o) => o.subOrders.containsKey(storeId)).toList();
  }

  @override
  Stream<List<OrderEntity>> watchCustomerOrders(String customerId) async* {
    if (_isFirebaseReady && _firestore != null) {
      yield* _firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snap) => snap.docs.map((d) => _fromFirestore(d.id, d.data())).toList());
      return;
    }
    // Yield initial data immediately so StreamBuilder never hangs
    yield await getCustomerOrders(customerId);
    yield* _ordersStreamController.stream
        .map((list) => list.where((o) => o.customerId == customerId).toList());
  }

  @override
  Stream<List<OrderEntity>> watchStoreOrders(String storeId) async* {
    if (_isFirebaseReady && _firestore != null) {
      yield* _firestore
          .collection('orders')
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => _fromFirestore(d.id, d.data()))
              .where((o) => o.subOrders.containsKey(storeId))
              .toList());
      return;
    }
    // Yield initial data immediately so StreamBuilder never hangs
    yield await getStoreOrders(storeId);
    yield* _ordersStreamController.stream
        .map((list) => list.where((o) => o.subOrders.containsKey(storeId)).toList());
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) async* {
    if (_isFirebaseReady && _firestore != null) {
      yield* _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return _fromFirestore(doc.id, doc.data()!);
      });
      return;
    }
    // Yield initial order state immediately
    yield await _getOrder(orderId);
    yield* _ordersStreamController.stream.map((list) {
      try {
        return list.firstWhere((o) => o.id == orderId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> updateSubOrderStatus({
    required String orderId,
    required String storeId,
    required SubOrderStatus status,
    String? reason,
  }) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Sipariş bulunamadı.');

    final subOrder = order.subOrders[storeId];
    if (subOrder == null) throw Exception('Alt sipariş bulunamadı.');

    // Enforce 10-minute response deadline check
    if ((status == SubOrderStatus.accepted || status == SubOrderStatus.rejected) &&
        subOrder.isResponseExpired()) {
      throw Exception('Market yanıt süresi (10 dakika) dolmuştur.');
    }

    final updatedSub = subOrder.copyWith(
      status: status,
      rejectionReason: reason,
      preparedAt: status == SubOrderStatus.ready ? DateTime.now() : null,
    );

    final updatedSubs = Map<String, SubOrderEntity>.from(order.subOrders);
    updatedSubs[storeId] = updatedSub;

    // Evaluate overall state machine
    OrderStatus newOrderStatus = order.status;
    DateTime? decisionDeadline = order.decisionDeadline;
    DateTime? courierStart = order.courierStartTimestamp;
    bool stockReleased = order.isStockReleased;
    double refund = order.simulatedRefundAmount;

    final allSubs = updatedSubs.values.toList();
    final allAccepted = allSubs.every((s) => s.status == SubOrderStatus.accepted || s.status == SubOrderStatus.ready || s.status == SubOrderStatus.preparing);
    final anyRejected = allSubs.any((s) => s.status == SubOrderStatus.rejected);
    final allRejected = allSubs.every((s) => s.status == SubOrderStatus.rejected);
    final allResponded = allSubs.every((s) => s.status != SubOrderStatus.pending);

    if (allRejected) {
      // 1. All stores rejected -> Auto-cancel & Full simulated refund
      newOrderStatus = OrderStatus.cancelled;
      refund = order.grandTotal;
      if (!stockReleased) {
        await _releaseStockForItems(order.items);
        stockReleased = true;
      }
    } else if (anyRejected && allResponded) {
      // 2. At least one rejected and all responded -> Customer has 5 mins to decide
      newOrderStatus = OrderStatus.pendingCustomerDecision;
      decisionDeadline = DateTime.now().add(AppConstants.customerDecisionDuration);
    } else if (allAccepted && allResponded) {
      // 3. All accepted -> Start preparation for all
      newOrderStatus = OrderStatus.preparing;
      for (final key in updatedSubs.keys) {
        if (updatedSubs[key]!.status == SubOrderStatus.accepted) {
          updatedSubs[key] = updatedSubs[key]!.copyWith(status: SubOrderStatus.preparing);
        }
      }
    }

    // Check if all active stores are ready -> start courier simulation
    if (newOrderStatus == OrderStatus.preparing) {
      final allReady = updatedSubs.values
          .where((s) => s.status != SubOrderStatus.rejected)
          .every((s) => s.status == SubOrderStatus.ready);
      if (allReady && courierStart == null) {
        courierStart = DateTime.now();
        newOrderStatus = OrderStatus.courierAssigned;
      }
    }

    final updatedOrder = order.copyWith(
      subOrders: updatedSubs,
      status: newOrderStatus,
      decisionDeadline: decisionDeadline,
      courierStartTimestamp: courierStart,
      isStockReleased: stockReleased,
      simulatedRefundAmount: refund,
    );

    await _saveOrder(updatedOrder);
  }

  @override
  Future<void> customerContinueAfterRejection({
    required String orderId,
    required String rejectedStoreId,
  }) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Sipariş bulunamadı.');

    if (order.status != OrderStatus.pendingCustomerDecision) {
      throw Exception('Bu işlem yalnızca ret sonrası karar aşamasında yapılabilir.');
    }

    if (order.isDecisionExpired()) {
      await cancelOrder(orderId: orderId, reason: '5 dakikalık karar süresi doldu.');
      throw Exception('5 dakikalık karar süresi dolduğu için sipariş iptal edilmiştir.');
    }

    // Remove rejected store items and suborder
    final remainingItems = order.items.where((i) => i.storeId != rejectedStoreId).toList();
    final remainingSubs = Map<String, SubOrderEntity>.from(order.subOrders)..remove(rejectedStoreId);

    if (remainingSubs.isEmpty) {
      await cancelOrder(orderId: orderId, reason: 'Tüm marketler siparişten çıkarıldı.');
      return;
    }

    // Release stock of the removed store's items only
    final removedItems = order.items.where((i) => i.storeId == rejectedStoreId).toList();
    await _releaseStockForItems(removedItems);

    // Recalculate totals and delivery fee
    final remainingStoreIds = remainingSubs.keys.toList();
    final newProductsTotal = remainingItems.fold(0.0, (total, i) => total + i.subtotal);
    final newDeliveryCalc = DeliveryFeeCalculator.calculate(storeIds: remainingStoreIds);
    final newGrandTotal = newProductsTotal + newDeliveryCalc.totalDeliveryFee;
    final priceDiff = (order.grandTotal - newGrandTotal).clamp(0.0, double.infinity);

    // Update remaining stores to preparing
    for (final key in remainingSubs.keys) {
      if (remainingSubs[key]!.status == SubOrderStatus.accepted) {
        remainingSubs[key] = remainingSubs[key]!.copyWith(status: SubOrderStatus.preparing);
      }
    }

    final updatedOrder = order.copyWith(
      items: remainingItems,
      subOrders: remainingSubs,
      status: OrderStatus.preparing,
      productsTotal: newProductsTotal,
      deliveryFee: newDeliveryCalc.totalDeliveryFee,
      grandTotal: newGrandTotal,
      simulatedRefundAmount: order.simulatedRefundAmount + priceDiff,
      decisionDeadline: null,
    );

    await _saveOrder(updatedOrder);
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Sipariş bulunamadı.');

    // Once preparation starts, customer cancellation is not permitted
    if (!order.canCustomerCancel) {
      throw Exception('Hazırlık başladıktan sonra müşteri tarafından iptal yapılamaz.');
    }

    // Release stock once
    if (!order.isStockReleased) {
      await _releaseStockForItems(order.items);
    }

    final updated = order.copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: reason,
      simulatedRefundAmount: order.grandTotal,
      isStockReleased: true,
    );

    await _saveOrder(updated);
  }

  @override
  Future<void> evaluateTimeouts(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null || order.isCompleted) return;

    final now = DateTime.now();

    // 1. Check store response deadlines (10 min)
    bool changed = false;
    final subs = Map<String, SubOrderEntity>.from(order.subOrders);
    for (final entry in subs.entries) {
      if (entry.value.isResponseExpired(now)) {
        subs[entry.key] = entry.value.copyWith(
          status: SubOrderStatus.rejected,
          rejectionReason: '10 dakikalık yanıt süresi doldu (Otomatik Ret).',
        );
        changed = true;
      }
    }

    if (changed) {
      // Re-evaluate suborders state
      final allRejected = subs.values.every((s) => s.status == SubOrderStatus.rejected);
      if (allRejected) {
        await cancelOrder(orderId: orderId, reason: 'Tüm marketler yanıt vermedi.');
        return;
      } else {
        final anyRejected = subs.values.any((s) => s.status == SubOrderStatus.rejected);
        final allResponded = subs.values.every((s) => s.status != SubOrderStatus.pending);
        if (anyRejected && allResponded) {
          final updated = order.copyWith(
            subOrders: subs,
            status: OrderStatus.pendingCustomerDecision,
            decisionDeadline: now.add(AppConstants.customerDecisionDuration),
          );
          await _saveOrder(updated);
          return;
        }
      }
    }

    // 2. Check customer decision deadline (5 min)
    if (order.status == OrderStatus.pendingCustomerDecision && order.isDecisionExpired(now)) {
      await cancelOrder(
        orderId: orderId,
        reason: '5 dakikalık müşteri karar süresi doldu (Otomatik İptal).',
      );
    }
  }

  Future<void> _evaluateAllTimeouts() async {
    final list = List<OrderEntity>.from(_memoryOrders);
    for (final order in list) {
      if (!order.isCompleted) {
        await evaluateTimeouts(order.id);
      }
    }
  }

  Future<void> _releaseStockForItems(List<OrderItemEntity> items) async {
    for (final item in items) {
      final product = await _productRepository.getProductById(item.productId);
      if (product != null) {
        await _productRepository.updateStock(product.id, product.stock + item.quantity);
      }
    }
  }

  Future<OrderEntity?> _getOrder(String id) async {
    if (_isFirebaseReady && _firestore != null) {
      final doc = await _firestore.collection('orders').doc(id).get();
      if (!doc.exists) return null;
      return _fromFirestore(doc.id, doc.data()!);
    }
    try {
      return _memoryOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveOrder(OrderEntity order) async {
    if (_isFirebaseReady && _firestore != null) {
      await _firestore.collection('orders').doc(order.id).set(_toFirestore(order));
    }
    final index = _memoryOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _memoryOrders[index] = order;
    } else {
      _memoryOrders.insert(0, order);
    }
    _ordersStreamController.add(_memoryOrders);
  }

  Map<String, dynamic> _toFirestore(OrderEntity order) {
    return {
      'orderNumber': order.orderNumber,
      'customerId': order.customerId,
      'customerName': order.customerName,
      'customerPhone': order.customerPhone,
      'storeOwnerIds': order.subOrders.keys.toList(),
      'storeIds': order.subOrders.keys.toList(),
      'status': order.status.name,
      'productsTotal': order.productsTotal,
      'deliveryFee': order.deliveryFee,
      'grandTotal': order.grandTotal,
      'simulatedRefundAmount': order.simulatedRefundAmount,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'decisionDeadline': order.decisionDeadline != null
          ? Timestamp.fromDate(order.decisionDeadline!)
          : null,
      'courierStartTimestamp': order.courierStartTimestamp != null
          ? Timestamp.fromDate(order.courierStartTimestamp!)
          : null,
      'cancellationReason': order.cancellationReason,
      'isStockReleased': order.isStockReleased,
      'items': order.items
          .map((i) => {
                'productId': i.productId,
                'storeId': i.storeId,
                'storeName': i.storeName,
                'productName': i.productName,
                'unitPrice': i.unitPrice,
                'quantity': i.quantity,
                'sampleImageKey': i.sampleImageKey,
                'imageUrl': i.imageUrl,
                'unit': i.unit,
              })
          .toList(),
      'subOrders': order.subOrders.map((k, v) => MapEntry(k, {
            'storeId': v.storeId,
            'storeName': v.storeName,
            'status': v.status.name,
            'subtotal': v.subtotal,
            'responseDeadline': Timestamp.fromDate(v.responseDeadline),
            'rejectionReason': v.rejectionReason,
            'preparedAt': v.preparedAt != null ? Timestamp.fromDate(v.preparedAt!) : null,
          })),
    };
  }

  OrderEntity _fromFirestore(String id, Map<String, dynamic> data) {
    final rawItems = (data['items'] as List<dynamic>? ?? []);
    final items = rawItems
        .map((m) => OrderItemEntity(
              productId: m['productId'] ?? '',
              storeId: m['storeId'] ?? '',
              storeName: m['storeName'] ?? '',
              productName: m['productName'] ?? '',
              unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0.0,
              quantity: (m['quantity'] as num?)?.toInt() ?? 1,
              sampleImageKey: m['sampleImageKey'] ?? 'grocery',
              imageUrl: m['imageUrl'] as String?,
              unit: m['unit'] ?? 'adet',
            ))
        .toList();

    final rawSubs = (data['subOrders'] as Map<String, dynamic>? ?? {});
    final subOrders = rawSubs.map((k, v) {
      final subItems = items.where((i) => i.storeId == k).toList();
      return MapEntry(
        k,
        SubOrderEntity(
          storeId: v['storeId'] ?? k,
          storeName: v['storeName'] ?? '',
          items: subItems,
          subtotal: (v['subtotal'] as num?)?.toDouble() ?? 0.0,
          status: SubOrderStatus.values.firstWhere(
            (e) => e.name == v['status'],
            orElse: () => SubOrderStatus.pending,
          ),
          responseDeadline: (v['responseDeadline'] as Timestamp?)?.toDate() ??
              DateTime.now().add(AppConstants.storeResponseDuration),
          rejectionReason: v['rejectionReason'],
          preparedAt: (v['preparedAt'] as Timestamp?)?.toDate(),
        ),
      );
    });

    return OrderEntity(
      id: id,
      orderNumber: data['orderNumber'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      deliveryAddress: SampleData.sampleAddresses.first,
      items: items,
      subOrders: subOrders,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pendingResponse,
      ),
      productsTotal: (data['productsTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (data['grandTotal'] as num?)?.toDouble() ?? 0.0,
      simulatedRefundAmount: (data['simulatedRefundAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      decisionDeadline: (data['decisionDeadline'] as Timestamp?)?.toDate(),
      courierStartTimestamp: (data['courierStartTimestamp'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'],
      isStockReleased: data['isStockReleased'] ?? false,
    );
  }
}
