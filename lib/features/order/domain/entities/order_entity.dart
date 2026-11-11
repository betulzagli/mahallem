import 'package:equatable/equatable.dart';
import '../../../customer/domain/entities/address_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Ana siparişin yaşam döngüsü durumları.
enum OrderStatus {
  pendingResponse, // Market yanıtı bekleniyor (10 dk)
  pendingCustomerDecision, // Ret oldu, müşterinin devam/iptal kararı bekleniyor (5 dk)
  preparing, // Kabul edildi/müşteri devam etti, marketler hazırlıyor
  courierAssigned, // Bütün marketler hazır, kurye atandı
  courierCollecting, // Kurye marketlerden ürünleri topluyor
  courierOnTheWay, // Kurye adrese doğru yolda
  delivered, // Teslim edildi
  cancelled, // İptal edildi
}

/// İlgili işletmeye özel alt siparişin durumları.
enum SubOrderStatus {
  pending,
  accepted,
  rejected,
  preparing,
  ready,
}

/// Siparişteki anlık ürün görüntüsü ve sipariş kalemi.
class OrderItemEntity extends Equatable {
  final String productId;
  final String storeId;
  final String storeName;
  final String productName;
  final double unitPrice; // Snapshot of unit price at order time
  final int quantity;
  final String sampleImageKey;
  final String? imageUrl;
  final String unit;

  const OrderItemEntity({
    required this.productId,
    required this.storeId,
    required this.storeName,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.sampleImageKey,
    this.imageUrl,
    this.unit = 'adet',
  });

  double get subtotal => unitPrice * quantity;

  @override
  List<Object?> get props => [
        productId,
        storeId,
        storeName,
        productName,
        unitPrice,
        quantity,
        sampleImageKey,
        imageUrl,
        unit,
      ];
}

/// Çoklu pazar sepetinde belirli bir esnafa ait alt siparişi temsil eden varlık.
class SubOrderEntity extends Equatable {
  final String storeId;
  final String storeName;
  final List<OrderItemEntity> items;
  final double subtotal;
  final SubOrderStatus status;
  final DateTime responseDeadline;
  final String? rejectionReason;
  final DateTime? preparedAt;

  const SubOrderEntity({
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.subtotal,
    required this.status,
    required this.responseDeadline,
    this.rejectionReason,
    this.preparedAt,
  });

  bool get isPending => status == SubOrderStatus.pending;
  bool get isAccepted => status == SubOrderStatus.accepted;
  bool get isRejected => status == SubOrderStatus.rejected;
  bool get isPreparing => status == SubOrderStatus.preparing;
  bool get isReady => status == SubOrderStatus.ready;

  bool isResponseExpired([DateTime? now]) {
    final current = now ?? DateTime.now();
    return status == SubOrderStatus.pending && current.isAfter(responseDeadline);
  }

  SubOrderEntity copyWith({
    String? storeId,
    String? storeName,
    List<OrderItemEntity>? items,
    double? subtotal,
    SubOrderStatus? status,
    DateTime? responseDeadline,
    String? rejectionReason,
    DateTime? preparedAt,
  }) {
    return SubOrderEntity(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      status: status ?? this.status,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      preparedAt: preparedAt ?? this.preparedAt,
    );
  }

  @override
  List<Object?> get props => [
        storeId,
        storeName,
        items,
        subtotal,
        status,
        responseDeadline,
        rejectionReason,
        preparedAt,
      ];
}

/// Müşterinin tek teslimatlı çoklu pazar ana siparişini temsil eden etki alanı varlığı.
class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final AddressEntity deliveryAddress;
  final List<OrderItemEntity> items;
  final Map<String, SubOrderEntity> subOrders;
  final OrderStatus status;
  final double productsTotal;
  final double deliveryFee;
  final double grandTotal;
  final double simulatedRefundAmount;
  final DateTime createdAt;
  final DateTime? decisionDeadline; // 5 mins from rejection
  final DateTime? courierStartTimestamp;
  final String? cancellationReason;
  final bool isStockReleased;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.subOrders,
    required this.status,
    required this.productsTotal,
    required this.deliveryFee,
    required this.grandTotal,
    this.simulatedRefundAmount = 0.0,
    required this.createdAt,
    this.decisionDeadline,
    this.courierStartTimestamp,
    this.cancellationReason,
    this.isStockReleased = false,
  });

  bool get canCustomerCancel =>
      status == OrderStatus.pendingResponse ||
      status == OrderStatus.pendingCustomerDecision;

  bool get isCompleted =>
      status == OrderStatus.delivered || status == OrderStatus.cancelled;

  bool isDecisionExpired([DateTime? now]) {
    if (status != OrderStatus.pendingCustomerDecision || decisionDeadline == null) {
      return false;
    }
    final current = now ?? DateTime.now();
    return current.isAfter(decisionDeadline!);
  }

  /// Calculates real-time courier stage dynamically from courierStartTimestamp.
  /// Guarantees that app relaunch or different devices calculate consistent state!
  OrderStatus get computedStatus {
    if (status == OrderStatus.cancelled) return OrderStatus.cancelled;
    if (courierStartTimestamp == null) return status;

    final elapsed = DateTime.now().difference(courierStartTimestamp!);
    final stage1 = AppConstants.courierAssignedDuration;
    final stage2 = stage1 + AppConstants.courierCollectingDuration;
    final stage3 = stage2 + AppConstants.courierOnTheWayDuration;

    if (elapsed < stage1) {
      return OrderStatus.courierAssigned;
    } else if (elapsed < stage2) {
      return OrderStatus.courierCollecting;
    } else if (elapsed < stage3) {
      return OrderStatus.courierOnTheWay;
    } else {
      return OrderStatus.delivered;
    }
  }

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    AddressEntity? deliveryAddress,
    List<OrderItemEntity>? items,
    Map<String, SubOrderEntity>? subOrders,
    OrderStatus? status,
    double? productsTotal,
    double? deliveryFee,
    double? grandTotal,
    double? simulatedRefundAmount,
    DateTime? createdAt,
    DateTime? decisionDeadline,
    DateTime? courierStartTimestamp,
    String? cancellationReason,
    bool? isStockReleased,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      subOrders: subOrders ?? this.subOrders,
      status: status ?? this.status,
      productsTotal: productsTotal ?? this.productsTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      grandTotal: grandTotal ?? this.grandTotal,
      simulatedRefundAmount: simulatedRefundAmount ?? this.simulatedRefundAmount,
      createdAt: createdAt ?? this.createdAt,
      decisionDeadline: decisionDeadline ?? this.decisionDeadline,
      courierStartTimestamp: courierStartTimestamp ?? this.courierStartTimestamp,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isStockReleased: isStockReleased ?? this.isStockReleased,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        customerName,
        customerPhone,
        deliveryAddress,
        items,
        subOrders,
        status,
        productsTotal,
        deliveryFee,
        grandTotal,
        simulatedRefundAmount,
        createdAt,
        decisionDeadline,
        courierStartTimestamp,
        cancellationReason,
        isStockReleased,
      ];
}
