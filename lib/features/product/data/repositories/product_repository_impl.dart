import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/constants/sample_data.dart';

/// [ProductRepository] arayüzünün somut implementasyonu.
///
/// Cloud Firestore ve bellek içi örnek ürün verilerini eşzamanlı destekler.
class ProductRepositoryImpl implements ProductRepository {
  final bool _isFirebaseReady;
  final FirebaseFirestore? _firestore;

  final List<ProductEntity> _memoryProducts = List.from(SampleData.products);
  final _productsStreamController = StreamController<List<ProductEntity>>.broadcast();

  ProductRepositoryImpl({
    bool isFirebaseReady = false,
    FirebaseFirestore? firestore,
  })  : _isFirebaseReady = isFirebaseReady,
        _firestore = firestore {
    _productsStreamController.add(_memoryProducts);
  }

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    if (_isFirebaseReady && _firestore != null) {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => _fromFirestore(doc.id, doc.data())).toList();
    }
    return List.unmodifiable(_memoryProducts);
  }

  @override
  Future<List<ProductEntity>> getProductsByStore(String storeId) async {
    if (_isFirebaseReady && _firestore != null) {
      final snapshot = await _firestore
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .get();
      return snapshot.docs.map((doc) => _fromFirestore(doc.id, doc.data())).toList();
    }
    return _memoryProducts.where((p) => p.storeId == storeId).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    if (_isFirebaseReady && _firestore != null) {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return null;
      return _fromFirestore(doc.id, doc.data()!);
    }
    try {
      return _memoryProducts.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    if (_isFirebaseReady && _firestore != null) {
      final docRef = _firestore.collection('products').doc();
      await docRef.set({
        'storeId': product.storeId,
        'storeName': product.storeName,
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'isActive': product.isActive,
        'sampleImageKey': product.sampleImageKey,
        'imageUrl': product.imageUrl,
        'unit': product.unit,
        'allowedUnits': product.allowedUnits,
        'unitPrices': product.unitPrices,
      });
    }
    _memoryProducts.add(product);
    _productsStreamController.add(_memoryProducts);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    if (_isFirebaseReady && _firestore != null) {
      await _firestore.collection('products').doc(product.id).update({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'isActive': product.isActive,
        'sampleImageKey': product.sampleImageKey,
        'imageUrl': product.imageUrl,
        'unit': product.unit,
        'allowedUnits': product.allowedUnits,
        'unitPrices': product.unitPrices,
      });
    }
    final index = _memoryProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _memoryProducts[index] = product;
      _productsStreamController.add(_memoryProducts);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    if (_isFirebaseReady && _firestore != null) {
      await _firestore.collection('products').doc(productId).delete();
    }
    _memoryProducts.removeWhere((p) => p.id == productId);
    _productsStreamController.add(_memoryProducts);
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    final product = await getProductById(productId);
    if (product == null) return;
    await updateProduct(product.copyWith(stock: newStock));
  }

  ProductEntity _fromFirestore(String id, Map<String, dynamic> data) {
    return ProductEntity(
      id: id,
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      sampleImageKey: data['sampleImageKey'] ?? 'grocery',
      imageUrl: data['imageUrl'],
      unit: data['unit'] ?? 'adet',
      allowedUnits: (data['allowedUnits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['adet'],
      unitPrices: (data['unitPrices'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
    );
  }
}

