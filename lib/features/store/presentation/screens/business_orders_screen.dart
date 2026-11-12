import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/product_image_placeholder.dart';

/// Esnafa gelen alt siparişlerin yönetildiği ekran: Bekleyen, Hazırlanan, Tamamlanan ve
/// İptal/Ret sekmeleri; sipariş kabul etme, gerekçeli ret ve hazır işaretleme imkanı sunar.
class BusinessOrdersScreen extends StatefulWidget {
  const BusinessOrdersScreen({super.key});

  @override
  State<BusinessOrdersScreen> createState() => _BusinessOrdersScreenState();
}

class _BusinessOrdersScreenState extends State<BusinessOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.read<AuthBloc>().state;
    final storeId = (authState is Authenticated && authState.user.storeId != null)
        ? authState.user.storeId!
        : 'store_1';
    final orderRepo = context.read<OrderRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Siparişler'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Yeni Siparişler'),
            Tab(text: 'Hazırlanıyor'),
            Tab(text: 'Hazır'),
            Tab(text: 'Geçmiş'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderEntity>>(
        stream: orderRepo.watchStoreOrders(storeId),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              // 1. New Orders
              _OrderSublist(
                orders: orders.where((o) => o.subOrders[storeId]?.isPending ?? false).toList(),
                storeId: storeId,
                emptyMessage: 'Yeni bekleyen siparişiniz yok.',
              ),
              // 2. Preparing
              _OrderSublist(
                orders: orders
                    .where((o) =>
                        (o.subOrders[storeId]?.isPreparing ?? false) ||
                        (o.subOrders[storeId]?.isAccepted ?? false))
                    .toList(),
                storeId: storeId,
                emptyMessage: 'Şu anda hazırlanan siparişiniz yok.',
              ),
              // 3. Ready
              _OrderSublist(
                orders: orders.where((o) => o.subOrders[storeId]?.isReady ?? false).toList(),
                storeId: storeId,
                emptyMessage: 'Kurye toplamasını bekleyen hazır siparişiniz yok.',
              ),
              // 4. Past / Cancelled
              _OrderSublist(
                orders: orders
                    .where((o) =>
                        (o.subOrders[storeId]?.isRejected ?? false) ||
                        o.status == OrderStatus.delivered ||
                        o.status == OrderStatus.cancelled)
                    .toList(),
                storeId: storeId,
                emptyMessage: 'Geçmiş sipariş kaydı bulunmuyor.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSublist extends StatelessWidget {
  final List<OrderEntity> orders;
  final String storeId;
  final String emptyMessage;

  const _OrderSublist({
    required this.orders,
    required this.storeId,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyStateView(
        icon: Icons.inbox_outlined,
        title: 'Sipariş Bulunamadı',
        message: emptyMessage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final sub = order.subOrders[storeId];
        if (sub == null) return const SizedBox();

        return _StoreOrderCard(
          order: order,
          subOrder: sub,
          storeId: storeId,
        );
      },
    );
  }
}

class _StoreOrderCard extends StatelessWidget {
  final OrderEntity order;
  final SubOrderEntity subOrder;
  final String storeId;

  const _StoreOrderCard({
    required this.order,
    required this.subOrder,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final remainingSecs =
        subOrder.responseDeadline.difference(DateTime.now()).inSeconds;
    final remainingFormatted = remainingSecs > 0
        ? '${(remainingSecs ~/ 60).toString().padLeft(2, '0')}:${(remainingSecs % 60).toString().padLeft(2, '0')}'
        : 'Süre Doldu';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Müşteri: ${order.customerName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(subOrder.subtotal),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          if (subOrder.isPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Kalan Yanıt Süreniz: $remainingFormatted (10 dk sınır)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(),

          // ONLY THIS STORE'S ITEMS (Security Requirement)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mağazanızdan İstenen Ürünler:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                ...subOrder.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ProductVisualBadge(
                          imageKey: item.sampleImageKey,
                          imageUrl: item.imageUrl,
                          size: 32,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.quantity} adet x ${item.productName}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.subtotal),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (subOrder.isPending) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Kabul Et',
              height: 42,
              onPressed: () {
                context.read<OrderBloc>().add(
                      SubOrderStatusUpdateRequested(
                        orderId: order.id,
                        storeId: storeId,
                        status: SubOrderStatus.accepted,
                      ),
                    );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              text: 'Reddet',
              height: 42,
              type: AppButtonType.outlined,
              onPressed: () {
                _showRejectDialog(context);
              },
            ),
          ),
        ],
      );
    } else if (subOrder.isPreparing || subOrder.isAccepted) {
      return AppButton(
        text: 'Hazır Olarak İşaretle (Kurye Çağır)',
        height: 44,
        onPressed: () {
          context.read<OrderBloc>().add(
                SubOrderStatusUpdateRequested(
                  orderId: order.id,
                  storeId: storeId,
                  status: SubOrderStatus.ready,
                ),
              );
        },
      );
    } else if (subOrder.isReady) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '✓ Ürünler hazırlandı, kurye toplaması bekleniyor',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      );
    } else if (subOrder.isRejected) {
      return Text(
        'Bu sipariş reddedildi: ${subOrder.rejectionReason ?? ""}',
        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    return const SizedBox();
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController(text: 'Ürün stokta bulunmuyor');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Siparişi Reddet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu siparişi reddettiğinizde müşteriye alternatif seçenek bildirilecektir.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Ret Gerekçesi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrderBloc>().add(
                    SubOrderStatusUpdateRequested(
                      orderId: order.id,
                      storeId: storeId,
                      status: SubOrderStatus.rejected,
                      reason: reasonController.text.trim(),
                    ),
                  );
            },
            child: const Text('Reddet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
