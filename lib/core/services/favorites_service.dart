import 'package:flutter/foundation.dart';

/// Kullanıcının favori işletme ve ürünlerini yöneten merkezi reaktif servis.
///
/// [ValueNotifier] ile favori ekleme/çıkarma işlemleri anında tüm sayfalarda tetiklenir.
class FavoritesService {
  FavoritesService._();

  /// Favori işletme kimlikleri kümesi.
  static final ValueNotifier<Set<String>> favoriteStoreIds =
      ValueNotifier<Set<String>>({'store_1', 'store_2'});

  /// Favori ürün kimlikleri kümesi.
  static final ValueNotifier<Set<String>> favoriteProductIds =
      ValueNotifier<Set<String>>({'prod_1_1', 'prod_2_1', 'prod_4_1'});

  /// İşletmenin favoride olup olmadığını kontrol eder.
  static bool isStoreFavorite(String storeId) {
    return favoriteStoreIds.value.contains(storeId);
  }

  /// İşletmenin favori durumunu tersine çevirir (ekle/çıkar).
  static bool toggleStoreFavorite(String storeId) {
    final updated = Set<String>.from(favoriteStoreIds.value);
    final isFav = updated.contains(storeId);
    if (isFav) {
      updated.remove(storeId);
    } else {
      updated.add(storeId);
    }
    favoriteStoreIds.value = updated;
    return !isFav;
  }

  /// İşletmeyi favorilerden doğrudan çıkarır.
  static void removeStoreFavorite(String storeId) {
    final updated = Set<String>.from(favoriteStoreIds.value)..remove(storeId);
    favoriteStoreIds.value = updated;
  }

  /// İşletmeyi favorilere ekler.
  static void addStoreFavorite(String storeId) {
    final updated = Set<String>.from(favoriteStoreIds.value)..add(storeId);
    favoriteStoreIds.value = updated;
  }

  /// Ürünün favoride olup olmadığını kontrol eder.
  static bool isProductFavorite(String productId) {
    return favoriteProductIds.value.contains(productId);
  }

  /// Ürünün favori durumunu tersine çevirir (ekle/çıkar).
  static bool toggleProductFavorite(String productId) {
    final updated = Set<String>.from(favoriteProductIds.value);
    final isFav = updated.contains(productId);
    if (isFav) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    favoriteProductIds.value = updated;
    return !isFav;
  }

  /// Ürünü favorilerden doğrudan çıkarır.
  static void removeProductFavorite(String productId) {
    final updated = Set<String>.from(favoriteProductIds.value)..remove(productId);
    favoriteProductIds.value = updated;
  }

  /// Ürünü favorilere ekler.
  static void addProductFavorite(String productId) {
    final updated = Set<String>.from(favoriteProductIds.value)..add(productId);
    favoriteProductIds.value = updated;
  }
}

