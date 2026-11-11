import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../order/presentation/screens/checkout_screen.dart';

/// Müşteri sepet ekranı.
///
/// Çoklu market ürünlerini gruplar, teslimat ücretini şeffaf şekilde gösterir ve
/// maksimum 3 market kuralını denetler.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.cart.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Sepeti Temizle',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sepeti Temizle'),
                      content: const Text('Sepetinizdeki tüm ürünler silinecek. Emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Vazgeç'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CartBloc>().add(CartCleared());
                            Navigator.pop(ctx);
                          },
                          child: const Text('Temizle', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state.warningMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.warningMessage!),
                backgroundColor: colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final cart = state.cart;

          if (cart.isEmpty) {
            return const EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Sepetiniz Boş',
              message:
                  'Mahallenizdeki esnaflardan ürün ekleyerek çoklu market sepetinizi oluşturmaya başlayın.',
            );
          }

          final grouped = cart.itemsGroupedByStore;
          final deliveryCalc = cart.deliveryFeeCalculation;

          return Column(
            children: [
              // Store limit indicator banner
              Container(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.store, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sepetteki Market Sayısı: ${cart.storeCount} / ${AppConstants.maxMarketsPerOrder}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Text(
                      'Tek Teslimat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Grouped items list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.keys.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final storeId = grouped.keys.elementAt(index);
                    final storeItems = grouped[storeId]!;
                    final storeName = storeItems.first.product.storeName;
                    final storeSubtotal =
                        storeItems.fold(0.0, (sum, i) => sum + i.subtotal);

                    return _StoreCartSection(
                      storeName: storeName,
                      items: storeItems,
                      subtotal: storeSubtotal,
                    );
                  },
                ),
              ),

              // Bottom Summary & Checkout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(top: BorderSide(color: colorScheme.outline, width: 0.8)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ürünler Toplamı (${cart.uniqueItemCount} çeşit):',
                              style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          Text(CurrencyFormatter.format(cart.productsTotal),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Delivery fee breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Tek Teslimat Ücreti:',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
                              IconButton(
                                icon: const Icon(Icons.info_outline, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Teslimat Ücreti Hesabı'),
                                      content: Text(
                                        'Mahallem Tek Teslimat Formülü:\n'
                                        '• Taban Ücret: ${AppConstants.baseDeliveryFee} TL\n'
                                        '• Market Katkısı (${deliveryCalc.storeCount} market × ${AppConstants.perMarketFee} TL): ${deliveryCalc.storeFee} TL\n'
                                        '• Örnek Rota (${deliveryCalc.routeKm} km × ${AppConstants.perKilometerFee} TL): ${deliveryCalc.distanceFee} TL\n\n'
                                        'Toplam Teslimat: ${CurrencyFormatter.format(deliveryCalc.totalDeliveryFee)}',
                                        style: const TextStyle(fontSize: 13, height: 1.5),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Text(CurrencyFormatter.format(cart.deliveryFee),
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 16),
                      // Grand total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Genel Toplam:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(cart.grandTotal),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        text: 'Siparişi Onayla (${CurrencyFormatter.format(cart.grandTotal)})',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(cart: cart),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StoreCartSection extends StatelessWidget {
  final String storeName;
  final List<CartItemEntity> items;
  final double subtotal;

  const _StoreCartSection({
    required this.storeName,
    required this.items,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.storefront, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(subtotal),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Items
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _CartItemRow(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        ProductVisualBadge(
          imageKey: item.product.sampleImageKey,
          imageUrl: item.product.imageUrl,
          size: 44,
          iconSize: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '${CurrencyFormatter.format(item.effectiveUnitPrice)} / ${item.selectedUnit}',
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        // Stepper
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
                onPressed: () {
                  context.read<CartBloc>().add(
                        CartItemQuantityChanged(
                          productId: item.product.id,
                          quantity: item.quantity - 1,
                        ),
                      );
                },
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
                onPressed: () {
                  context.read<CartBloc>().add(
                        CartItemQuantityChanged(
                          productId: item.product.id,
                          quantity: item.quantity + 1,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          CurrencyFormatter.format(item.subtotal),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}
