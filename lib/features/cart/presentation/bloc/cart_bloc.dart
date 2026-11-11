import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

// Events
/// Sepet olaylarının temel sınıfı.
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

/// Sepete ürün ekleme olayı (miktar ve seçili birim ile).
class CartItemAdded extends CartEvent {
  final ProductEntity product;
  final int quantity;
  final String? unit;
  const CartItemAdded({required this.product, this.quantity = 1, this.unit});
  @override
  List<Object?> get props => [product, quantity, unit];
}

/// Sepetten ürünü tamamen kaldırma olayı.
class CartItemRemoved extends CartEvent {
  final String productId;
  const CartItemRemoved(this.productId);
  @override
  List<Object?> get props => [productId];
}

/// Sepetteki ürünün miktarını güncelleme olayı.
class CartItemQuantityChanged extends CartEvent {
  final String productId;
  final int quantity;
  const CartItemQuantityChanged({required this.productId, required this.quantity});
  @override
  List<Object?> get props => [productId, quantity];
}

/// Sepeti tamamen boşaltma olayı.
class CartCleared extends CartEvent {}

/// Sepet durumunu ve olası uyarı mesajlarını tutan durum sınıfı.
class CartState extends Equatable {
  final CartEntity cart;
  final String? warningMessage;

  const CartState({
    this.cart = const CartEntity(),
    this.warningMessage,
  });

  CartState copyWith({
    CartEntity? cart,
    String? warningMessage,
    bool clearWarning = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }

  @override
  List<Object?> get props => [cart, warningMessage];
}

/// Sepet işlemlerini, maksimum 3 market kontrolünü ve hesaplamaları yöneten BLoC.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityChanged>(_onQuantityChanged);
    on<CartCleared>(_onCartCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final currentCart = state.cart;

    // Check max 3 stores rule
    if (!currentCart.canAddProductFromStore(event.product.storeId)) {
      emit(state.copyWith(
        warningMessage:
            'Sipariş başına en fazla 3 marketten ürün ekleyebilirsiniz. Başka bir market eklemek için mevcut marketlerden birinin ürünlerini sepetten çıkarınız.',
      ));
      return;
    }

    final selectedUnit = event.unit ?? event.product.unit;
    final existingIndex = currentCart.items.indexWhere(
        (i) => i.product.id == event.product.id && i.selectedUnit == selectedUnit);

    List<CartItemEntity> updatedItems = List.from(currentCart.items);
    if (existingIndex != -1) {
      final currentItem = updatedItems[existingIndex];
      final newQty = currentItem.quantity + event.quantity;
      if (newQty > event.product.stock) {
        emit(state.copyWith(
          warningMessage:
              'Mevcut stok sınırına (${event.product.stock} $selectedUnit) ulaşıldı.',
        ));
        return;
      }
      updatedItems[existingIndex] = currentItem.copyWith(quantity: newQty);
    } else {
      if (event.quantity > event.product.stock) {
        emit(state.copyWith(
          warningMessage:
              'Mevcut stok sınırına (${event.product.stock} $selectedUnit) ulaşıldı.',
        ));
        return;
      }
      final price = event.product.priceForUnit(selectedUnit);
      updatedItems.add(CartItemEntity(
        product: event.product,
        quantity: event.quantity,
        selectedUnit: selectedUnit,
        unitPrice: price,
      ));
    }

    emit(CartState(
      cart: CartEntity(items: updatedItems),
      warningMessage: null,
    ));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final updatedItems =
        state.cart.items.where((i) => i.product.id != event.productId).toList();
    emit(CartState(
      cart: CartEntity(items: updatedItems),
      warningMessage: null,
    ));
  }

  void _onQuantityChanged(CartItemQuantityChanged event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(CartItemRemoved(event.productId));
      return;
    }

    final index =
        state.cart.items.indexWhere((i) => i.product.id == event.productId);
    if (index == -1) return;

    final item = state.cart.items[index];
    if (event.quantity > item.product.stock) {
      emit(state.copyWith(
        warningMessage:
            'Mevcut stok sınırına (${item.product.stock} adet) ulaşıldı.',
      ));
      return;
    }

    final updatedItems = List<CartItemEntity>.from(state.cart.items);
    updatedItems[index] = item.copyWith(quantity: event.quantity);

    emit(CartState(
      cart: CartEntity(items: updatedItems),
      warningMessage: null,
    ));
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}

