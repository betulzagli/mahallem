import 'package:flutter/material.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/favorites_service.dart';
import 'product_detail_screen.dart';
import 'market_detail_screen.dart';
import 'explore_screen.dart';

/// Müşterinin favorilediği işletmeleri ve ürünleri listelediği ekran.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          FavoritesService.favoriteStoreIds,
          FavoritesService.favoriteProductIds,
        ]),
        builder: (context, _) {
          final storeIds = FavoritesService.favoriteStoreIds.value;
          final productIds = FavoritesService.favoriteProductIds.value;

          final favStores =
              SampleData.stores.where((s) => storeIds.contains(s.id)).toList();
          final favProducts =
              SampleData.products.where((p) => productIds.contains(p.id)).toList();

          final isEmpty = favStores.isEmpty && favProducts.isEmpty;

          if (isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF795E).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_outline,
                        size: 44,
                        color: Color(0xFFFF795E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Favori Listeniz Boş',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beğendiğiniz mahalle esnaflarını ve taze ürünleri kalp ikonuna basarak favorilerinize ekleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Esnafları Keşfet',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ExploreScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (favStores.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Favori Esnaflarınız',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${favStores.length} esnaf',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...favStores.map((store) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: ProductVisualBadge(
                          imageKey: store.sampleImageKey,
                          imageUrl: store.imageUrl,
                          size: 44,
                          iconSize: 22,
                        ),
                        title: Text(
                          store.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${store.category} • ${store.neighborhood}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Color(0xFFFF795E)),
                          tooltip: 'Favorilerden çıkar',
                          onPressed: () {
                            FavoritesService.removeStoreFavorite(store.id);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('${store.name} favorilerden çıkarıldı.'),
                                duration: const Duration(milliseconds: 1200),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MarketDetailScreen(storeId: store.id),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
                if (favProducts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Favori Ürünleriniz',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${favProducts.length} ürün',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...favProducts.map((p) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: ProductVisualBadge(
                          imageKey: p.sampleImageKey,
                          imageUrl: p.imageUrl,
                          size: 44,
                          iconSize: 22,
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${p.storeName} • ${CurrencyFormatter.format(p.price)} / ${p.unit}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Color(0xFFFF795E)),
                          tooltip: 'Favorilerden çıkar',
                          onPressed: () {
                            FavoritesService.removeProductFavorite(p.id);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('${p.name} favorilerden çıkarıldı.'),
                                duration: const Duration(milliseconds: 1200),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(productId: p.id),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
