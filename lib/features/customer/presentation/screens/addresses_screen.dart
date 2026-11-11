import 'package:flutter/material.dart';
import '../../domain/entities/address_entity.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state_view.dart';

/// Teslimat adresleri yönetim ekranı: Adres listeleme, ekleme, silme ve
/// varsayılan adres seçimi işlemlerini yürütür.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  void _showAddAddressDialog() {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();
    bool setAsDefault = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Yeni Adres Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: titleController,
                  label: 'Adres Başlığı',
                  hint: 'Örn: Yazlık Ev, Annemin Evi',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: addressController,
                  label: 'Açık Adres (${SampleData.neighborhood})',
                  hint: 'Gültepe Mah. ... Sokak No: ...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: noteController,
                  label: 'Teslimat Notu (İsteğe bağlı)',
                  hint: 'Örn: Zili çalmayınız, kapıya bırakınız',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Varsayılan adresim olarak kaydet', style: TextStyle(fontSize: 13)),
                  value: setAsDefault,
                  onChanged: (val) {
                    setDialogState(() => setAsDefault = val ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    addressController.text.trim().isNotEmpty) {
                  final newAddr = AddressEntity(
                    id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                    userId: 'user_customer_demo',
                    title: titleController.text.trim(),
                    fullAddress: addressController.text.trim(),
                    deliveryNote: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    isDefault: setAsDefault,
                  );

                  AddressService.addAddress(newAddr);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${newAddr.title}" adresi kaydedildi.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Kaydet'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adreslerim'),
      ),
      body: ValueListenableBuilder<List<AddressEntity>>(
        valueListenable: AddressService.addressesNotifier,
        builder: (context, addresses, _) {
          if (addresses.isEmpty) {
            return const EmptyStateView(
              icon: Icons.location_off_outlined,
              title: 'Kayıtlı Adresiniz Yok',
              message: 'Sipariş verebilmek için lütfen mahallenizdeki teslimat adresinizi ekleyin.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              final isDef = addr.isDefault;

              return InkWell(
                onTap: () {
                  if (!isDef) {
                    AddressService.setDefaultAddress(addr.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${addr.title}" varsayılan teslimat adresi olarak belirlendi.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDef ? colorScheme.primary : colorScheme.outline,
                      width: isDef ? 2.0 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDef ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isDef ? colorScheme.primary : colorScheme.outline,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            addr.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDef ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (isDef)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Varsayılan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                AddressService.setDefaultAddress(addr.id);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${addr.title}" varsayılan adres yapıldı.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Varsayılan Yap'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addr.fullAddress,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      if (addr.deliveryNote != null && addr.deliveryNote!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.notes, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Not: ${addr.deliveryNote}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!isDef) ...[
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Adresi Sil',
                              onPressed: () {
                                AddressService.deleteAddress(addr.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${addr.title}" adresi silindi.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Adres Ekle'),
      ),
    );
  }
}
