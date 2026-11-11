import '../entities/product_entity.dart';

/// Ürün CRUD ve stok işlemlerini tanımlayan soyut depo arayüzü.
abstract class ProductRepository {
  /// Sistemdeki tüm ürünleri listeler.
  Future<List<ProductEntity>> getAllProducts();

  /// Belirli bir mağazaya ait ürünleri listeler.
  Future<List<ProductEntity>> getProductsByStore(String storeId);

  /// Kimliğe göre tek bir ürünü getirir.
  Future<ProductEntity?> getProductById(String productId);

  /// Yeni bir ürün ekler.
  Future<void> addProduct(ProductEntity product);

  /// Mevcut bir ürünü günceller.
  Future<void> updateProduct(ProductEntity product);

  /// Ürünü siler.
  Future<void> deleteProduct(String productId);

  /// Ürünün mevcut stok miktarını günceller.
  Future<void> updateStock(String productId, int newStock);
}

