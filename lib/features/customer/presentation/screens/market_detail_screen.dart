import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../store/presentation/bloc/store_bloc.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/favorites_service.dart';
import 'product_detail_screen.dart';

/// İşletme/dükkan detay ekranı: Dükkan bilgileri, çalışma saatleri, arama seçeneği,
/// açık/kapalı durumu ve mağazaya ait ürünlerin listesini sunar.
class MarketDetailScreen extends StatefulWidget {
  final String storeId;

  const MarketDetailScreen({super.key, required this.storeId});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsLoadRequested(storeId: widget.storeId));
  }

  void _showCallStoreModal(BuildContext context, StoreEntity store) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_in_talk,
                size: 28,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              store.phoneNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${store.name} ile telefon görüşmesi başlatılsın mı?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Ara'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('${store.name} aranıyor (${store.phoneNumber})...'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, storeState) {
        if (storeState is! StoreLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final store = storeState.stores.firstWhere(
          (s) => s.id == widget.storeId,
          orElse: () => storeState.stores.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(store.name),
            actions: [
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesService.favoriteStoreIds,
                builder: (context, favStoreIds, _) {
                  final isFav = favStoreIds.contains(store.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? const Color(0xFFFF795E) : null,
                    ),
                    onPressed: () {
                      final added = FavoritesService.toggleStoreFavorite(store.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(added
                              ? '${store.name} favorilere eklendi.'
                              : '${store.name} favorilerden çıkarıldı.'),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Store Header Banner
                Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Center(
                        child: ProductVisualBadge(
                          imageKey: store.sampleImageKey,
                          imageUrl: store.imageUrl,
                          size: 72,
                          iconSize: 36,
                          borderRadius: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        store.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${store.category} • ${store.neighborhood}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Open/Closed Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: store.canAcceptOrders
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.canAcceptOrders
                              ? 'Açık • Sipariş Alıyor'
                              : 'Şu Anda Kapalı • Sipariş Alınamıyor',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: store.canAcceptOrders
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        store.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                store.openingHours,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _showCallStoreModal(context, store),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    store.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Ara',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.route, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${store.sampleRouteDistanceKm} km',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (!store.canAcceptOrders) ...[
                  Container(
                    color: colorScheme.errorContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu mağaza kapalı olduğu için şu an sepetinize bu mağazadan yeni ürün ekleyemezsiniz.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Products list header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Mağaza Ürünleri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, productState) {
                    if (productState is ProductsLoading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (productState is ProductsLoaded) {
                      final products = productState.products;
                      if (products.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('Bu mağazada henüz ürün bulunmuyor.'),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _StoreProductTile(
                            product: product,
                            canAddToCart: store.canAcceptOrders,
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StoreProductTile extends StatefulWidget {
  final ProductEntity product;
  final bool canAddToCart;

  const _StoreProductTile({
    required this.product,
    required this.canAddToCart,
  });

  @override
  State<_StoreProductTile> createState() => _StoreProductTileState();
}

class _StoreProductTileState extends State<_StoreProductTile> {
  int _quantity = 1;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.product.allowedUnits.isNotEmpty
        ? widget.product.allowedUnits.first
        : widget.product.unit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.product;
    final canAddToCart = widget.canAddToCart;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProductVisualBadge(
              imageKey: product.sampleImageKey,
              imageUrl: product.imageUrl,
              size: 58,
              iconSize: 28,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        CurrencyFormatter.format(product.priceForUnit(_selectedUnit)),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' / $_selectedUnit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 11,
                          color: product.stock > 0
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  if (product.allowedUnits.length > 1) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: product.allowedUnits.map((u) {
                        final isSel = _selectedUnit == u;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedUnit = u),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSel ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                u,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Stepper and Add button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: _quantity > 1 ? colorScheme.onSurface : colorScheme.outline,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                      InkWell(
                        onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: _quantity < product.stock ? colorScheme.onSurface : colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: (canAddToCart && product.isInStock)
                      ? () {
                          context.read<CartBloc>().add(
                                CartItemAdded(
                                  product: product,
                                  quantity: _quantity,
                                  unit: _selectedUnit,
                                ),
                              );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$_quantity $_selectedUnit ${product.name} sepete eklendi.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: (canAddToCart && product.isInStock)
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ekle',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
