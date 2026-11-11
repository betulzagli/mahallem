import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../bloc/order_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/sample_data.dart';
import 'order_detail_screen.dart';

/// Müşteri sipariş listesi ekranı: Aktif siparişler ve geçmiş siparişler sekmeleri ile
/// tüm siparişlerin durumlarını ve detaylarına geçişi sunar.
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: const Text(
          'Hazırlık başlamadan önce bu siparişi iptal etmek istediğinizden emin misiniz? '
          'Simüle ödeme kartınıza anında tam olarak iade edilecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<OrderBloc>().add(
                    OrderCancelRequested(
                      orderId: order.id,
                      reason: 'Müşteri liste ekranından siparişi iptal etti.',
                    ),
                  );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sipariş iptal edildi ve tutar karta iade edildi.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Evet, İptal Et', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : SampleData.sampleCustomer.id;
    final orderRepo = context.read<OrderRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişlerim'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Aktif Siparişler'),
            Tab(text: 'Geçmiş & İptal'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderEntity>>(
        stream: orderRepo.watchCustomerOrders(userId),
        builder: (context, snapshot) {
          final allOrders = snapshot.data ?? [];
          final activeOrders = allOrders.where((o) => !o.isCompleted).toList();
          final pastOrders = allOrders.where((o) => o.isCompleted).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // 1. Aktif Siparişler Tab (Cancelled orders are instantly removed from here!)
              activeOrders.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Aktif Siparişiniz Yok',
                      message: 'Şu anda hazırlanan veya yolda olan bir siparişiniz bulunmuyor.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildOrderCard(
                          context,
                          activeOrders[index],
                          isActiveTab: true,
                        );
                      },
                    ),

              // 2. Geçmiş & İptal Tab
              pastOrders.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'Geçmiş Sipariş Bulunmuyor',
                      message: 'Tamamlanan veya iptal edilen geçmiş bir sipariş kaydı yok.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pastOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildOrderCard(
                          context,
                          pastOrders[index],
                          isActiveTab: false,
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order, {required bool isActiveTab}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveStatus = order.computedStatus;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: effectiveStatus == OrderStatus.cancelled
                ? Colors.red.withValues(alpha: 0.3)
                : colorScheme.outline,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: effectiveStatus == OrderStatus.cancelled
                        ? Colors.red.shade700
                        : colorScheme.primary,
                  ),
                ),
                _StatusTag(status: effectiveStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Marketler: ${order.subOrders.values.map((s) => s.storeName).join(", ")}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.items.length} çeşit ürün • Tek Teslimat',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            if (order.cancellationReason != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'İptal Nedeni: ${order.cancellationReason}',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                ),
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  CurrencyFormatter.format(order.grandTotal),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            // In Active tab, if customer can cancel before preparation, provide an instant cancel button
            if (isActiveTab && order.canCustomerCancel) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 0.8),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 14),
                    label: const Text('Siparişi İptal Et', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showCancelDialog(context, order),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusTag extends StatelessWidget {
  final OrderStatus status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.pendingResponse => ('Onay Bekliyor', Colors.orange),
      OrderStatus.pendingCustomerDecision => ('Kararınız Bekleniyor', Colors.amber.shade900),
      OrderStatus.preparing => ('Hazırlanıyor', Colors.blue),
      OrderStatus.courierAssigned => ('Kurye Atandı', Colors.indigo),
      OrderStatus.courierCollecting => ('Toplanıyor', Colors.purple),
      OrderStatus.courierOnTheWay => ('Yolda', Colors.teal),
      OrderStatus.delivered => ('Teslim Edildi', Colors.green),
      OrderStatus.cancelled => ('İptal Edildi', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
