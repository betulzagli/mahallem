import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/favorites_service.dart';
import 'market_detail_screen.dart';

/// Ürün detay ekranı: Gerçek fotoğraf, birim seçimi (kg / adet), dinamik birim fiyatı,
/// miktar seçici ve sepete ekleme aksiyonlarını sunar.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductsLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final product = state.products.firstWhere(
          (p) => p.id == widget.productId,
          orElse: () => state.products.first,
        );

        _selectedUnit ??= product.allowedUnits.isNotEmpty
            ? product.allowedUnits.first
            : product.unit;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            actions: [
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesService.favoriteProductIds,
                builder: (context, favIds, _) {
                  final isFav = favIds.contains(product.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? const Color(0xFFFF795E) : null,
                    ),
                    onPressed: () {
                      final added = FavoritesService.toggleProductFavorite(product.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(added
                              ? '${product.name} favorilere eklendi.'
                              : '${product.name} favorilerden çıkarıldı.'),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Visual
                      Center(
                        child: ProductVisualBadge(
                          imageKey: product.sampleImageKey,
                          imageUrl: product.imageUrl,
                          size: 160,
                          iconSize: 75,
                          borderRadius: 24,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Store tag link
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MarketDetailScreen(storeId: product.storeId),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.storefront, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              product.storeName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 16, color: colorScheme.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Product Title
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price and Stock row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                CurrencyFormatter.format(product.priceForUnit(_selectedUnit!)),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                ' / $_selectedUnit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isInStock
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.isInStock
                                  ? 'Stokta Var (${product.stock} $_selectedUnit)'
                                  : 'Tükendi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: product.isInStock
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Unit selection if multiple units allowed (e.g. kg vs adet)
                      if (product.allowedUnits.length > 1) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Sipariş Birimi Seçimi',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: product.allowedUnits.map((u) {
                            return ButtonSegment<String>(
                              value: u,
                              label: Text(
                                u.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              icon: Icon(
                                u == 'kg'
                                    ? Icons.scale_outlined
                                    : Icons.inventory_2_outlined,
                                size: 16,
                              ),
                            );
                          }).toList(),
                          selected: {_selectedUnit!},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selectedUnit = newSelection.first;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Ürün Açıklaması',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Multi-market rule reminder
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Bu ürün sepetinize eklendiğinde, aynı siparişte en fazla 3 farklı marketten alışveriş yapabilirsiniz.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar: Quantity & Add to Cart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(top: BorderSide(color: colorScheme.outline, width: 0.8)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Quantity Stepper
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: _quantity < product.stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to Cart Button
                      Expanded(
                        child: AppButton(
                          text: product.isInStock
                              ? 'Sepete Ekle (${CurrencyFormatter.format(product.priceForUnit(_selectedUnit!) * _quantity)})'
                              : 'Stokta Yok',
                          onPressed: product.isInStock
                              ? () {
                                  context.read<CartBloc>().add(
                                        CartItemAdded(
                                          product: product,
                                          quantity: _quantity,
                                          unit: _selectedUnit,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '$_quantity $_selectedUnit ${product.name} sepete eklendi.'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
