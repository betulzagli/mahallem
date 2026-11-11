import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_bloc.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'business_orders_screen.dart';
import '../widgets/add_edit_product_dialog.dart';

/// Mahalle esnafı ana yönetim paneli: Günlük ciro, sipariş sayıları, dükkan açık/kapalı
/// ve mola durumu butonları, hızlı ürün ekleme ve bekleyen sipariş bildirimleri sunar.
class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.read<AuthBloc>().state;
    final storeId = (authState is Authenticated && authState.user.storeId != null)
        ? authState.user.storeId!
        : 'store_1';

    final orderRepo = context.read<OrderRepository>();

    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, storeState) {
        final stores = storeState is StoreLoaded ? storeState.stores : SampleData.stores;
        final currentStore = stores.firstWhere(
          (s) => s.id == storeId,
          orElse: () => stores.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('İşletme Paneli'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Yeni Ürün Ekle',
                onPressed: () => showAddEditProductDialog(
                  context: context,
                  storeId: storeId,
                  storeName: currentStore.name,
                ),
              ),
              const ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddEditProductDialog(
              context: context,
              storeId: storeId,
              storeName: currentStore.name,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Ürün Ekle'),
          ),
          body: StreamBuilder<List<OrderEntity>>(
            stream: orderRepo.watchStoreOrders(storeId),
            builder: (context, snapshot) {
              final orders = snapshot.data ?? [];
              final newOrders = orders.where((o) => o.subOrders[storeId]?.isPending ?? false).length;
              final preparingOrders = orders.where((o) =>
                  (o.subOrders[storeId]?.isPreparing ?? false) ||
                  (o.subOrders[storeId]?.isAccepted ?? false)).length;
              final completedOrders = orders.where((o) =>
                  (o.subOrders[storeId]?.isReady ?? false) ||
                  o.status == OrderStatus.delivered).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Store Open/Close Toggle Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentStore.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentStore.canAcceptOrders
                                      ? 'Mağazanız Açık • Sipariş Kabul Ediliyor'
                                      : 'Mağazanız Kapalı • Yeni Sipariş Alınmıyor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: currentStore.canAcceptOrders
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: currentStore.isOpen,
                            onChanged: (val) {
                              context.read<StoreBloc>().add(
                                    StoreOpenStatusToggled(
                                      storeId: storeId,
                                      isOpen: val,
                                      autoReopen: currentStore.autoReopenOnNextSchedule,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Yeni Sipariş',
                            count: '$newOrders',
                            color: Colors.orange,
                            icon: Icons.notifications_active_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Hazırlanıyor',
                            count: '$preparingOrders',
                            color: Colors.blue,
                            icon: Icons.outdoor_grill_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Hazır / Bitti',
                            count: '$completedOrders',
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick Action: Add Product Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.6),
                            colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yeni Ürün Ekle',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mağazanıza yeni ürün ekleyip mahallenin erişimine açın',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => showAddEditProductDialog(
                              context: context,
                              storeId: storeId,
                              storeName: currentStore.name,
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Ürün Ekle'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(70, 36),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Orders Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Son Siparişler',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BusinessOrdersScreen(),
                              ),
                            );
                          },
                          child: const Text('Tümünü Yönet'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (orders.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Henüz mağazanıza iletilen sipariş bulunmuyor.'),
                        ),
                      )
                    else
                      ...orders.take(3).map((order) {
                        final sub = order.subOrders[storeId];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              '${order.orderNumber} - ${order.customerName}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${sub?.items.length ?? 0} ürününüz var • ${CurrencyFormatter.format(sub?.subtotal ?? 0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BusinessOrdersScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
