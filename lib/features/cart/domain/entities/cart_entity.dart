import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/delivery_fee_calculator.dart';

/// Sepette yer alan tekil bir ürün kalemini (seçili birim, birim fiyat ve adet ile) temsil eden varlık.
class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final String selectedUnit;
  final double unitPrice;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.selectedUnit = 'adet',
    this.unitPrice = 0.0,
  });

  /// Seçili birime göre geçerli olan birim fiyatı döner.
  double get effectiveUnitPrice => unitPrice > 0 ? unitPrice : product.price;

  /// Bu kalemin ara toplam tutarı (`effectiveUnitPrice * quantity`).
  double get subtotal => effectiveUnitPrice * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? selectedUnit,
    double? unitPrice,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [product, quantity, selectedUnit, unitPrice];
}

/// Müşterinin sepetini, çoklu market kısıtlarını ve teslimat ücreti hesaplamasını yöneten etki alanı varlığı.
class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Toplam ürün adedi (tüm miktarların toplamı).
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Sepetteki farklı ürün çeşidi sayısı (sepet ikonu üzerindeki rozette gösterilir).
  int get uniqueItemCount => items.length;

  /// Sepette ürünleri bulunan tekil işletmelerin kimlik listesi.
  List<String> get uniqueStoreIds =>
      items.map((e) => e.product.storeId).toSet().toList();

  /// Sepetteki tekil işletme sayısı.
  int get storeCount => uniqueStoreIds.length;

  /// Kesinleşen kural: Sipariş başına en fazla 3 marketten ürün eklenebilir.
  bool canAddProductFromStore(String storeId) {
    if (uniqueStoreIds.contains(storeId)) return true;
    return storeCount < AppConstants.maxMarketsPerOrder;
  }

  /// Sipariş oluşturulurken ürünleri ait oldukları işletmeye göre gruplar.
  Map<String, List<CartItemEntity>> get itemsGroupedByStore {
    final map = <String, List<CartItemEntity>>{};
    for (final item in items) {
      map.putIfAbsent(item.product.storeId, () => []).add(item);
    }
    return map;
  }

  /// Yalnızca ürünlerin toplam tutarı.
  double get productsTotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Çoklu market ve rota mesafesine göre teslimat ücreti hesabı.
  DeliveryFeeCalculation get deliveryFeeCalculation =>
      DeliveryFeeCalculator.calculate(storeIds: uniqueStoreIds);

  /// Müşteriye yansıtılacak teslimat ücreti.
  double get deliveryFee => deliveryFeeCalculation.totalDeliveryFee;

  /// Ürünler toplamı + teslimat ücreti = Genel Toplam.
  double get grandTotal => productsTotal + deliveryFee;

  @override
  List<Object?> get props => [items];
}
