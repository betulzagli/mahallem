import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// Events
/// Ürün yönetimi olaylarının temel sınıfı.
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

/// Ürünleri yükleme olayı (tüm ürünler veya belirli bir mağazaya göre).
class ProductsLoadRequested extends ProductEvent {
  final String? storeId;
  const ProductsLoadRequested({this.storeId});
  @override
  List<Object?> get props => [storeId];
}

/// Yeni ürün ekleme olayı.
class ProductAddRequested extends ProductEvent {
  final ProductEntity product;
  const ProductAddRequested(this.product);
  @override
  List<Object?> get props => [product];
}

/// Ürün güncelleme olayı.
class ProductUpdateRequested extends ProductEvent {
  final ProductEntity product;
  const ProductUpdateRequested(this.product);
  @override
  List<Object?> get props => [product];
}

/// Ürün silme olayı.
class ProductDeleteRequested extends ProductEvent {
  final String productId;
  final String storeId;
  const ProductDeleteRequested({required this.productId, required this.storeId});
  @override
  List<Object?> get props => [productId, storeId];
}

/// Ürün durumlarının temel sınıfı.
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductsLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final String? storeId;
  const ProductsLoaded({required this.products, this.storeId});
  @override
  List<Object?> get props => [products, storeId];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  const ProductOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductFailure extends ProductState {
  final String message;
  const ProductFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// Ürün listeleme, ekleme, güncelleme ve silme akışlarını yöneten BLoC.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    on<ProductsLoadRequested>(_onLoad);
    on<ProductAddRequested>(_onAdd);
    on<ProductUpdateRequested>(_onUpdate);
    on<ProductDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
      ProductsLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductsLoading());
    try {
      final list = event.storeId != null
          ? await _productRepository.getProductsByStore(event.storeId!)
          : await _productRepository.getAllProducts();
      emit(ProductsLoaded(products: list, storeId: event.storeId));
    } catch (e) {
      emit(ProductFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAdd(
      ProductAddRequested event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.addProduct(event.product);
      final list = await _productRepository.getProductsByStore(event.product.storeId);
      emit(ProductsLoaded(products: list, storeId: event.product.storeId));
    } catch (e) {
      emit(ProductFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdate(
      ProductUpdateRequested event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.updateProduct(event.product);
      final list = await _productRepository.getProductsByStore(event.product.storeId);
      emit(ProductsLoaded(products: list, storeId: event.product.storeId));
    } catch (e) {
      emit(ProductFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDelete(
      ProductDeleteRequested event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.deleteProduct(event.productId);
      final list = await _productRepository.getProductsByStore(event.storeId);
      emit(ProductsLoaded(products: list, storeId: event.storeId));
    } catch (e) {
      emit(ProductFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

