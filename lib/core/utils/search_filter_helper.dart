import '../../features/product/domain/entities/product_entity.dart';
import '../../features/store/domain/entities/store_entity.dart';

class SearchFilterHelper {
  SearchFilterHelper._();

  /// Normalizes Turkish characters and casing for robust case/accent-insensitive search.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .trim();
  }

  /// Checks if a text matches a search query using normalized substring search.
  static bool matchesQuery(String text, String query) {
    final normQuery = normalize(query);
    if (normQuery.isEmpty) return true;
    final normText = normalize(text);
    return normText.contains(normQuery);
  }

  /// Matches a product against a selected category string (store category or product category).
  static bool matchesProductCategory({
    required ProductEntity product,
    required String selectedCategory,
    required List<StoreEntity> stores,
  }) {
    if (selectedCategory.isEmpty || selectedCategory == 'Tümü') return true;

    final normSelected = normalize(selectedCategory);
    final normProdCat = normalize(product.category);

    // Direct match with product category
    if (normProdCat == normSelected ||
        normProdCat.contains(normSelected) ||
        normSelected.contains(normProdCat)) {
      return true;
    }

    // Find store category
    String storeCategory = '';
    for (final s in stores) {
      if (s.id == product.storeId) {
        storeCategory = s.category;
        break;
      }
    }

    final normStoreCat = normalize(storeCategory);
    if (normStoreCat.isNotEmpty) {
      if (normStoreCat == normSelected ||
          normStoreCat.contains(normSelected) ||
          normSelected.contains(normStoreCat)) {
        return true;
      }
    }

    // Semantic category mapping between store and product types:
    // 1. Manav <-> Sebze & Meyve
    if ((normSelected.contains('manav') ||
            normSelected.contains('sebze') ||
            normSelected.contains('meyve')) &&
        (normProdCat.contains('sebze') || normProdCat.contains('meyve'))) {
      return true;
    }

    // 2. Kasap <-> Kırmızı Et / Tavuk
    if ((normSelected.contains('kasap') || normSelected.contains('et')) &&
        (normProdCat.contains('et') ||
            normProdCat.contains('kiyma') ||
            normProdCat.contains('kofte') ||
            normProdCat.contains('tavuk'))) {
      return true;
    }

    // 3. Fırın / Unlu Mamül <-> Ekmek & Fırın
    if ((normSelected.contains('firin') ||
            normSelected.contains('unlu') ||
            normSelected.contains('ekmek')) &&
        (normProdCat.contains('ekmek') ||
            normProdCat.contains('firin') ||
            normProdCat.contains('simit') ||
            normProdCat.contains('unlu'))) {
      return true;
    }

    // 4. Market / Bakkal <-> Temel Gıda & Süt & Kahvaltılık
    if ((normSelected.contains('market') || normSelected.contains('bakkal')) &&
        (normProdCat.contains('temel') ||
            normProdCat.contains('sut') ||
            normProdCat.contains('gida') ||
            normProdCat.contains('kahvalti') ||
            normProdCat.contains('peynir') ||
            normProdCat.contains('cay'))) {
      return true;
    }

    return false;
  }

  /// Matches a store against a selected category string.
  static bool matchesStoreCategory({
    required StoreEntity store,
    required String selectedCategory,
  }) {
    if (selectedCategory.isEmpty || selectedCategory == 'Tümü') return true;

    final normSelected = normalize(selectedCategory);
    final normStoreCat = normalize(store.category);

    if (normStoreCat == normSelected ||
        normStoreCat.contains(normSelected) ||
        normSelected.contains(normStoreCat)) {
      return true;
    }

    // Semantic matching for stores:
    if (normSelected.contains('manav') && normStoreCat.contains('manav')) return true;
    if (normSelected.contains('kasap') && normStoreCat.contains('kasap')) return true;
    if (normSelected.contains('firin') &&
        (normStoreCat.contains('firin') || normStoreCat.contains('unlu'))) {
      return true;
    }
    if ((normSelected.contains('market') || normSelected.contains('bakkal')) &&
        (normStoreCat.contains('market') || normStoreCat.contains('bakkal'))) {
      return true;
    }
    if ((normSelected.contains('sebze') || normSelected.contains('meyve')) &&
        normStoreCat.contains('manav')) {
      return true;
    }
    if (normSelected.contains('et') && normStoreCat.contains('kasap')) return true;
    if (normSelected.contains('ekmek') &&
        (normStoreCat.contains('firin') || normStoreCat.contains('unlu'))) {
      return true;
    }
    if ((normSelected.contains('temel') || normSelected.contains('sut')) &&
        (normStoreCat.contains('market') || normStoreCat.contains('bakkal'))) {
      return true;
    }

    return false;
  }
}
