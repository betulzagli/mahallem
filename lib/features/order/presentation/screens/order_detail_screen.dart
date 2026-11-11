import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/delivery_fee_calculator.dart';

/// Sipariş takip ve detay ekranı: Gerçek zamanlı geri sayım sayaçları (10 dk market yanıtı,
/// 5 dk müşteri kararı), alt siparişlerin esnaf bazlı durumları, kurye aşamaları simülasyonu,
/// iptal etme ve ret sonrası kalan marketlerle devam etme aksiyonlarını yönetir.
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Timer? _ticker;
  Stream<OrderEntity?>? _orderStream;

  @override
  void initState() {
    super.initState();
    // 1-second ticker to update timers and check timeouts in real-time
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        context.read<OrderBloc>().add(OrderCheckTimeoutRequested(widget.orderId));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderStream ??= context.read<OrderRepository>().watchOrder(widget.orderId);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Detayı ve Takip'),
      ),
      body: StreamBuilder<OrderEntity?>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data;
          if (order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Sipariş Bulunamadı',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aradığınız sipariş sistemde bulunamadı veya henüz oluşturulmadı.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Siparişlerime Dön',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          }

          final effectiveStatus = order.computedStatus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                          _OrderStatusBadge(status: effectiveStatus),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sipariş Tarihi: ${_formatDateTime(order.createdAt)}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      if (order.simulatedRefundAmount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Simüle İade Tutarı: ${CurrencyFormatter.format(order.simulatedRefundAmount)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Decision Alert Banner if store rejected and awaiting customer choice
                if (order.status == OrderStatus.pendingCustomerDecision) ...[
                  _CustomerDecisionCard(order: order),
                  const SizedBox(height: 16),
                ],

                // Courier Simulation Visual Tracker (Atandı -> Toplanıyor -> Yolda -> Teslim Edildi)
                if (order.courierStartTimestamp != null &&
                    order.status != OrderStatus.cancelled) ...[
                  _CourierSimulationCard(order: order),
                  const SizedBox(height: 16),
                ],

                // Multi-Market SubOrders Section
                Text(
                  'Marketler ve Hazırlık Durumları',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                ...order.subOrders.values.map((subOrder) {
                  return _SubOrderCard(
                    subOrder: subOrder,
                    orderStatus: order.status,
                  );
                }),

                const SizedBox(height: 16),

                // Delivery Info & Order Financial Breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teslimat Bilgileri',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.deliveryAddress.title} - ${order.deliveryAddress.neighborhood}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        order.deliveryAddress.fullAddress,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      if (order.deliveryAddress.deliveryNote != null)
                        Text(
                          'Teslimat Notu: ${order.deliveryAddress.deliveryNote}',
                          style: TextStyle(fontSize: 12, color: colorScheme.primary),
                        ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ürünler Toplamı:',
                              style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          Text(CurrencyFormatter.format(order.productsTotal),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tek Teslimat Ücreti:',
                              style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          Text(CurrencyFormatter.format(order.deliveryFee),
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Genel Toplam:',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          Text(
                            CurrencyFormatter.format(order.grandTotal),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cancellation Button (allowed only before preparation starts!)
                if (order.canCustomerCancel) ...[
                  AppButton(
                    text: 'Siparişi İptal Et',
                    type: AppButtonType.outlined,
                    onPressed: () {
                      _showCancelDialog(context, order);
                    },
                  ),
                ] else if (!order.isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_clock, size: 20, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hazırlık aşamasına geçildiği için sipariş doğrudan iptal edilemez.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: const Text(
          'Hazırlık başlamadan önce tüm siparişi iptal edebilirsiniz. '
          'Simüle ödemeniz kartınıza tam olarak iade edilecektir. Onaylıyor musunuz?',
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
                    OrderCancelRequested(
                      orderId: order.id,
                      reason: 'Müşteri hazırlık öncesinde siparişi iptal etti.',
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sipariş iptal edildi ve ücret iade edildi.'),
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Evet, İptal Et', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      OrderStatus.pendingResponse => (
          'Market Yanıtı Bekleniyor',
          Colors.orange.shade50,
          Colors.orange.shade800
        ),
      OrderStatus.pendingCustomerDecision => (
          'Müşteri Kararı Bekleniyor (5 dk)',
          Colors.amber.shade100,
          Colors.amber.shade900
        ),
      OrderStatus.preparing => ('Hazırlanıyor', Colors.blue.shade50, Colors.blue.shade800),
      OrderStatus.courierAssigned => (
          'Kurye Atandı',
          Colors.indigo.shade50,
          Colors.indigo.shade800
        ),
      OrderStatus.courierCollecting => (
          'Ürünler Toplanıyor',
          Colors.purple.shade50,
          Colors.purple.shade800
        ),
      OrderStatus.courierOnTheWay => (
          'Kurye Yolda',
          Colors.teal.shade50,
          Colors.teal.shade800
        ),
      OrderStatus.delivered => ('Teslim Edildi', Colors.green.shade50, Colors.green.shade800),
      OrderStatus.cancelled => ('İptal Edildi', Colors.red.shade50, Colors.red.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _SubOrderCard extends StatelessWidget {
  final SubOrderEntity subOrder;
  final OrderStatus orderStatus;

  const _SubOrderCard({
    required this.subOrder,
    required this.orderStatus,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.storefront, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subOrder.storeName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SubOrderStatusTag(status: subOrder.status),
              ],
            ),
          ),
          if (subOrder.isPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Market Yanıt Süresi: $remainingFormatted (10 dk sınır)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (subOrder.isRejected && subOrder.rejectionReason != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ret Gerekçesi: ${subOrder.rejectionReason}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(),
          // Items
          ...subOrder.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  ProductVisualBadge(
                    imageKey: item.sampleImageKey,
                    imageUrl: item.imageUrl,
                    size: 36,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${item.quantity} ${item.unit} ${item.productName}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.subtotal),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _SubOrderStatusTag extends StatelessWidget {
  final SubOrderStatus status;

  const _SubOrderStatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      SubOrderStatus.pending => ('Yanıt Bekleniyor', Colors.orange),
      SubOrderStatus.accepted => ('Kabul Edildi', Colors.blue),
      SubOrderStatus.rejected => ('Reddedildi', Colors.red),
      SubOrderStatus.preparing => ('Hazırlanıyor', Colors.purple),
      SubOrderStatus.ready => ('Hazırlandı', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CustomerDecisionCard extends StatelessWidget {
  final OrderEntity order;

  const _CustomerDecisionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rejectedSubs =
        order.subOrders.values.where((s) => s.status == SubOrderStatus.rejected).toList();
    final rejectedStore = rejectedSubs.isNotEmpty ? rejectedSubs.first : null;

    final remainingSecs = order.decisionDeadline != null
        ? order.decisionDeadline!.difference(DateTime.now()).inSeconds
        : 0;
    final timerText = remainingSecs > 0
        ? '${(remainingSecs ~/ 60).toString().padLeft(2, '0')}:${(remainingSecs % 60).toString().padLeft(2, '0')}'
        : 'Süre Doldu (Otomatik İptal)';

    // Precalculate new amounts if customer chooses to continue without rejected store
    final remainingSubs = Map<String, SubOrderEntity>.from(order.subOrders)
      ..remove(rejectedStore?.storeId);
    final remainingStoreIds = remainingSubs.keys.toList();
    final newItems =
        order.items.where((i) => i.storeId != rejectedStore?.storeId).toList();
    final newProductsTotal = newItems.fold(0.0, (sum, i) => sum + i.subtotal);
    final newCalc = DeliveryFeeCalculator.calculate(storeIds: remainingStoreIds);
    final newGrandTotal = newProductsTotal + newCalc.totalDeliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notification_important, color: colorScheme.secondary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Market Siparişi Reddetti - Kararınız Gerekiyor',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${rejectedStore?.storeName ?? "Bir market"} siparişi reddetti. '
            '5 dakika içinde karar vermezseniz tüm sipariş otomatik iptal edilecektir.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Kalan Karar Süresi: $timerText',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: remainingSecs < 60 ? Colors.red : colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),
          Text(
            'Devam Edilirse Yeni Tutar Hesabı:\n'
            '• Kalan Ürünler Toplamı: ${CurrencyFormatter.format(newProductsTotal)}\n'
            '• Yeni Tek Teslimat (${newCalc.storeCount} market, ${newCalc.routeKm} km): ${CurrencyFormatter.format(newCalc.totalDeliveryFee)}\n'
            '• Yeni Genel Toplam: ${CurrencyFormatter.format(newGrandTotal)}',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Devam Et (${CurrencyFormatter.format(newGrandTotal)})',
                  height: 44,
                  onPressed: rejectedStore != null
                      ? () {
                          context.read<OrderBloc>().add(
                                CustomerContinueDecisionRequested(
                                  orderId: order.id,
                                  rejectedStoreId: rejectedStore.storeId,
                                ),
                              );
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Tümünü İptal Et',
                  height: 44,
                  type: AppButtonType.outlined,
                  onPressed: () {
                    context.read<OrderBloc>().add(
                          OrderCancelRequested(
                            orderId: order.id,
                            reason: 'Müşteri market reddi üzerine siparişi iptal etti.',
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourierSimulationCard extends StatelessWidget {
  final OrderEntity order;

  const _CourierSimulationCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = order.computedStatus;

    final steps = [
      (
        'Kurye Atandı',
        status == OrderStatus.courierAssigned ||
            status == OrderStatus.courierCollecting ||
            status == OrderStatus.courierOnTheWay ||
            status == OrderStatus.delivered
      ),
      (
        'Ürünler Toplanıyor',
        status == OrderStatus.courierCollecting ||
            status == OrderStatus.courierOnTheWay ||
            status == OrderStatus.delivered
      ),
      (
        'Kurye Yolda',
        status == OrderStatus.courierOnTheWay || status == OrderStatus.delivered
      ),
      ('Teslim Edildi', status == OrderStatus.delivered),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bike, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Kurye ve Teslimat Takibi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Canlı Takip',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tüm marketler siparişleri hazırladı. Kurye ürünleri marketlerden toplayarak tek seferde adresinize ulaştırıyor.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // Stepper indicators
          Column(
            children: List.generate(steps.length, (index) {
              final (name, isDone) = steps[index];
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          size: isDone ? 14 : 8,
                          color: isDone ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 24,
                          color: isDone ? colorScheme.primary : colorScheme.outline,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                        color: isDone ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

