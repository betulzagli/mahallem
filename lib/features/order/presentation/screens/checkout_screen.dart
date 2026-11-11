import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../customer/domain/entities/address_entity.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'order_confirmation_screen.dart';

/// Sipariş tamamlama ve ödeme adımı ekranı: Teslimat adresi seçimi, simüle edilmiş
/// kart bilgileri, sipariş özeti ve siparişi onaylama akışını yönetir.
class CheckoutScreen extends StatefulWidget {
  final CartEntity cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late AddressEntity _selectedAddress;
  final _cardNumberController =
      TextEditingController(text: '4543 •••• •••• 1234');
  final _cardHolderController = TextEditingController(text: 'Ahmet Yılmaz');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '321');
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = AddressService.defaultAddress;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _completeOrder() async {
    setState(() => _isProcessing = true);
    // Simulate payment transaction
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : SampleData.sampleCustomer;

    context.read<OrderBloc>().add(
          OrderCreateRequested(
            cart: widget.cart,
            address: _selectedAddress,
            customer: user,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlacedSuccess) {
          // Clear cart
          context.read<CartBloc>().add(CartCleared());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(order: state.order),
            ),
          );
        } else if (state is OrderFailure) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ödeme ve Sipariş'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Address Selection
              Text(
                'Teslimat Adresi (Gültepe Mahallesi)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline, width: 0.8),
                ),
                child: Column(
                  children: AddressService.addressesNotifier.value.map((addr) {
                    final isSelected = addr.id == _selectedAddress.id;
                    return InkWell(
                      onTap: () => setState(() => _selectedAddress = addr),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(addr.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(
                                    '${addr.fullAddress}\nNot: ${addr.deliveryNote ?? "-"}',
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Payment Simulation Notice (Mandatory Requirement)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: colorScheme.secondary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Güvenli Ödeme Altyapısı',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '256-Bit SSL sertifikası ile korunan güvenli ödeme. '
                            'Test kartı bilgileri kullanıma hazır tanımlanmıştır.',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card Form
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
                      'Kart ile Online Ödeme',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _cardNumberController,
                      label: 'Kart Numarası',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _cardHolderController,
                      label: 'Kart Sahibi',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _expiryController,
                            label: 'Son Kullanma',
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _cvvController,
                            label: 'CVV',
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Order Summary
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
                      'Sipariş Özeti',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.cart.itemsGroupedByStore.entries.map((entry) {
                      final items = entry.value;
                      final storeName = items.first.product.storeName;
                      final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$storeName (${items.length} ürün):',
                                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                            Text(CurrencyFormatter.format(subtotal),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ürünler Toplamı:',
                            style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        Text(CurrencyFormatter.format(widget.cart.productsTotal),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tek Teslimat Ücreti:',
                            style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        Text(CurrencyFormatter.format(widget.cart.deliveryFee),
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ödenecek Toplam:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(widget.cart.grandTotal),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                text: 'Ödemeyi Tamamla (${CurrencyFormatter.format(widget.cart.grandTotal)})',
                isLoading: _isProcessing,
                onPressed: _completeOrder,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
