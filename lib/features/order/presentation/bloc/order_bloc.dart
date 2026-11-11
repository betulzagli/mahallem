import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../customer/domain/entities/address_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

// Events
/// Sipariş yönetim olaylarının temel sınıfı.
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

/// Müşteri siparişlerini yükleme olayı.
class CustomerOrdersLoadRequested extends OrderEvent {
  final String customerId;
  const CustomerOrdersLoadRequested(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

/// İşletme siparişlerini yükleme olayı.
class StoreOrdersLoadRequested extends OrderEvent {
  final String storeId;
  const StoreOrdersLoadRequested(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

/// Yeni sipariş oluşturma olayı.
class OrderCreateRequested extends OrderEvent {
  final CartEntity cart;
  final AddressEntity address;
  final UserEntity customer;
  const OrderCreateRequested({
    required this.cart,
    required this.address,
    required this.customer,
  });
  @override
  List<Object?> get props => [cart, address, customer];
}

/// İşletme tarafından alt sipariş durumunu güncelleme olayı.
class SubOrderStatusUpdateRequested extends OrderEvent {
  final String orderId;
  final String storeId;
  final SubOrderStatus status;
  final String? reason;
  const SubOrderStatusUpdateRequested({
    required this.orderId,
    required this.storeId,
    required this.status,
    this.reason,
  });
  @override
  List<Object?> get props => [orderId, storeId, status, reason];
}

/// Müşterinin bir market ret verdikten sonra kalanlarla devam etme kararı olayı.
class CustomerContinueDecisionRequested extends OrderEvent {
  final String orderId;
  final String rejectedStoreId;
  const CustomerContinueDecisionRequested({
    required this.orderId,
    required this.rejectedStoreId,
  });
  @override
  List<Object?> get props => [orderId, rejectedStoreId];
}

class OrderCancelRequested extends OrderEvent {
  final String orderId;
  final String reason;
  const OrderCancelRequested({required this.orderId, required this.reason});
  @override
  List<Object?> get props => [orderId, reason];
}

class OrderCheckTimeoutRequested extends OrderEvent {
  final String orderId;
  const OrderCheckTimeoutRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

// States
/// Sipariş durumlarının temel sınıfı.
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrderState {}

class OrdersLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderPlacedSuccess extends OrderState {
  final OrderEntity order;
  const OrderPlacedSuccess(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderOperationSuccess extends OrderState {
  final String message;
  const OrderOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// Müşteri ve işletme sipariş akışlarını, durum güncellemelerini yöneten BLoC.
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrdersInitial()) {
    on<CustomerOrdersLoadRequested>(_onLoadCustomerOrders);
    on<StoreOrdersLoadRequested>(_onLoadStoreOrders);
    on<OrderCreateRequested>(_onCreateOrder);
    on<SubOrderStatusUpdateRequested>(_onUpdateSubOrderStatus);
    on<CustomerContinueDecisionRequested>(_onCustomerContinue);
    on<OrderCancelRequested>(_onCancelOrder);
    on<OrderCheckTimeoutRequested>(_onCheckTimeout);
  }

  Future<void> _onLoadCustomerOrders(
      CustomerOrdersLoadRequested event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await _orderRepository.getCustomerOrders(event.customerId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadStoreOrders(
      StoreOrdersLoadRequested event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await _orderRepository.getStoreOrders(event.storeId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateOrder(
      OrderCreateRequested event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    try {
      final cart = event.cart;
      final now = DateTime.now();
      final orderNumber = 'MHL-${now.millisecondsSinceEpoch.toString().substring(7)}';

      final orderItems = cart.items
          .map((i) => OrderItemEntity(
                productId: i.product.id,
                storeId: i.product.storeId,
                storeName: i.product.storeName,
                productName: i.product.name,
                unitPrice: i.effectiveUnitPrice,
                quantity: i.quantity,
                sampleImageKey: i.product.sampleImageKey,
                imageUrl: i.product.imageUrl,
                unit: i.selectedUnit,
              ))
          .toList();

      final subOrders = <String, SubOrderEntity>{};
      for (final entry in cart.itemsGroupedByStore.entries) {
        final storeId = entry.key;
        final items = entry.value;
        final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
        final storeName = items.first.product.storeName;

        subOrders[storeId] = SubOrderEntity(
          storeId: storeId,
          storeName: storeName,
          items: items
              .map((i) => OrderItemEntity(
                    productId: i.product.id,
                    storeId: i.product.storeId,
                    storeName: i.product.storeName,
                    productName: i.product.name,
                    unitPrice: i.effectiveUnitPrice,
                    quantity: i.quantity,
                    sampleImageKey: i.product.sampleImageKey,
                    imageUrl: i.product.imageUrl,
                    unit: i.selectedUnit,
                  ))
              .toList(),
          subtotal: subtotal,
          status: SubOrderStatus.pending,
          responseDeadline: now.add(const Duration(minutes: 10)),
        );
      }

      final newOrder = OrderEntity(
        id: 'order_${now.millisecondsSinceEpoch}',
        orderNumber: orderNumber,
        customerId: event.customer.id,
        customerName: event.customer.fullName,
        customerPhone: event.customer.phoneNumber ?? '05551234567',
        deliveryAddress: event.address,
        items: orderItems,
        subOrders: subOrders,
        status: OrderStatus.pendingResponse,
        productsTotal: cart.productsTotal,
        deliveryFee: cart.deliveryFee,
        grandTotal: cart.grandTotal,
        createdAt: now,
      );

      final created = await _orderRepository.createOrder(newOrder);
      emit(OrderPlacedSuccess(created));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateSubOrderStatus(
      SubOrderStatusUpdateRequested event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.updateSubOrderStatus(
        orderId: event.orderId,
        storeId: event.storeId,
        status: event.status,
        reason: event.reason,
      );
      emit(const OrderOperationSuccess('Sipariş durumu güncellendi.'));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCustomerContinue(
      CustomerContinueDecisionRequested event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.customerContinueAfterRejection(
        orderId: event.orderId,
        rejectedStoreId: event.rejectedStoreId,
      );
      emit(const OrderOperationSuccess('Güncel tutar onaylandı, hazırlığa geçildi.'));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCancelOrder(
      OrderCancelRequested event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.cancelOrder(
        orderId: event.orderId,
        reason: event.reason,
      );
      emit(const OrderOperationSuccess('Sipariş başarıyla iptal edildi. Simüle iade yapıldı.'));
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCheckTimeout(
      OrderCheckTimeoutRequested event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.evaluateTimeouts(event.orderId);
    } catch (_) {}
  }
}

