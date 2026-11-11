import 'package:equatable/equatable.dart';

/// Esnafın satışa sunduğu ürünü, stok durumunu ve birim fiyatlandırmalarını temsil eden etki alanı varlığı.
class ProductEntity extends Equatable {
  final String id;
  final String storeId;
  final String storeName;
  final String name;
  final String description;
  final String category;
  final double price; // Unit price
  final int stock; // Unit stock count
  final bool isActive;
  final String sampleImageKey;
  final String? imageUrl;
  final String unit; // 'adet', 'kg', 'paket'
  final List<String> allowedUnits; // e.g. ['adet'], ['kg', 'adet']
  final Map<String, double> unitPrices; // Price per unit, e.g. {'kg': 38.0, 'adet': 6.50}

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    this.isActive = true,
    required this.sampleImageKey,
    this.imageUrl,
    this.unit = 'adet',
    this.allowedUnits = const ['adet'],
    this.unitPrices = const {},
  });

  double priceForUnit(String targetUnit) {
    if (unitPrices.containsKey(targetUnit)) {
      return unitPrices[targetUnit]!;
    }
    return price;
  }

  bool get isInStock => stock > 0 && isActive;

  ProductEntity copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? name,
    String? description,
    String? category,
    double? price,
    int? stock,
    bool? isActive,
    String? sampleImageKey,
    String? imageUrl,
    bool clearImageUrl = false,
    String? unit,
    List<String>? allowedUnits,
    Map<String, double>? unitPrices,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      sampleImageKey: sampleImageKey ?? this.sampleImageKey,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      unit: unit ?? this.unit,
      allowedUnits: allowedUnits ?? this.allowedUnits,
      unitPrices: unitPrices ?? this.unitPrices,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        storeName,
        name,
        description,
        category,
        price,
        stock,
        isActive,
        sampleImageKey,
        imageUrl,
        unit,
        allowedUnits,
        unitPrices,
      ];
}
