import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/product_image_placeholder.dart';

class _PresetProductPhoto {
  final String label;
  final String url;
  final String sampleKey;

  const _PresetProductPhoto({
    required this.label,
    required this.url,
    required this.sampleKey,
  });
}

const List<_PresetProductPhoto> _presetPhotos = [
  _PresetProductPhoto(
    label: 'Süt',
    url: 'assets/images/milk.jpg',
    sampleKey: 'milk',
  ),
  _PresetProductPhoto(
    label: 'Yumurta',
    url: 'assets/images/eggs.jpg',
    sampleKey: 'eggs',
  ),
  _PresetProductPhoto(
    label: 'Peynir',
    url: 'assets/images/cheese.jpg',
    sampleKey: 'cheese',
  ),
  _PresetProductPhoto(
    label: 'Çay',
    url: 'assets/images/tea.jpg',
    sampleKey: 'tea',
  ),
  _PresetProductPhoto(
    label: 'Domates',
    url: 'assets/images/tomato.jpg',
    sampleKey: 'tomato',
  ),
  _PresetProductPhoto(
    label: 'Salatalık',
    url: 'assets/images/cucumber.jpg',
    sampleKey: 'cucumber',
  ),
  _PresetProductPhoto(
    label: 'Elma',
    url: 'assets/images/apple.jpg',
    sampleKey: 'apple',
  ),
  _PresetProductPhoto(
    label: 'Muz',
    url: 'assets/images/banana.jpg',
    sampleKey: 'banana',
  ),
  _PresetProductPhoto(
    label: 'Kıyma',
    url: 'assets/images/minced_meat.jpg',
    sampleKey: 'minced_meat',
  ),
  _PresetProductPhoto(
    label: 'Kuşbaşı Et',
    url: 'assets/images/cubed_meat.jpg',
    sampleKey: 'cubed_meat',
  ),
  _PresetProductPhoto(
    label: 'Tavuk',
    url: 'assets/images/chicken.jpg',
    sampleKey: 'chicken',
  ),
  _PresetProductPhoto(
    label: 'Ekmek',
    url: 'assets/images/bread.jpg',
    sampleKey: 'bread',
  ),
  _PresetProductPhoto(
    label: 'Simit',
    url: 'assets/images/simit.jpg',
    sampleKey: 'simit',
  ),
  _PresetProductPhoto(
    label: 'Su Böreği',
    url: 'assets/images/pastry.jpg',
    sampleKey: 'pastry',
  ),
  _PresetProductPhoto(
    label: 'Bakkal',
    url: 'assets/images/grocery.jpg',
    sampleKey: 'grocery',
  ),
];

/// Yeni ürün ekleme veya mevcut ürünü düzenleme iletişim penceresi (Dialog).
///
/// Fotoğraf URL'si ekleme, canlı önizleme, hazır yüksek çözünürlüklü Unsplash galeri seçimi,
/// birim tipi (kg / adet), fiyat ve stok bilgilerini kaydetmeyi sağlar.
Future<void> showAddEditProductDialog({
  required BuildContext context,
  required String storeId,
  required String storeName,
  ProductEntity? existingProduct,
}) {
  final isEditing = existingProduct != null;
  final nameController = TextEditingController(text: existingProduct?.name ?? '');
  final descController = TextEditingController(text: existingProduct?.description ?? '');
  final priceController = TextEditingController(
    text: existingProduct != null ? existingProduct.price.toStringAsFixed(2) : '',
  );
  final stockController = TextEditingController(
    text: existingProduct != null ? existingProduct.stock.toString() : '20',
  );
  final imageUrlController = TextEditingController(text: existingProduct?.imageUrl ?? '');

  String selectedCategory = existingProduct?.category ?? 'Temel Gıda';
  String selectedImageKey = existingProduct?.sampleImageKey ?? 'grocery';
  String selectedUnit = existingProduct?.unit ?? 'adet';
  bool isActive = existingProduct?.isActive ?? true;
  String? errorMessage;

  final categories = [
    'Temel Gıda',
    'Süt & Kahvaltılık',
    'Sebze',
    'Meyve',
    'Kırmızı Et',
    'Ekmek & Fırın',
  ];

  final units = ['adet', 'kg', 'paket', 'gram', 'litre'];

  final imageKeys = [
    'grocery',
    'milk',
    'eggs',
    'cheese',
    'tea',
    'tomato',
    'cucumber',
    'apple',
    'banana',
    'minced_meat',
    'bread',
    'simit',
  ];

  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final currentImageUrl = imageUrlController.text.trim();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Live Preview Card
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        ProductVisualBadge(
                          imageKey: selectedImageKey,
                          imageUrl: currentImageUrl.isNotEmpty ? currentImageUrl : null,
                          size: 58,
                          iconSize: 28,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameController.text.trim().isEmpty
                                    ? (isEditing ? 'Ürün Adı' : 'Yeni Ürün Önizleme')
                                    : nameController.text.trim(),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentImageUrl.isNotEmpty
                                    ? '✓ Fotoğraf eklendi'
                                    : 'Fotoğrafsız (Hazır ikon aktif)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: currentImageUrl.isNotEmpty
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: currentImageUrl.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentImageUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Fotoğrafı Kaldır',
                            onPressed: () {
                              setDialogState(() {
                                imageUrlController.clear();
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  AppTextField(
                    controller: nameController,
                    label: 'Ürün Adı *',
                    hint: 'Örn: Doğal Günlük Süt (1 L)',
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descController,
                    label: 'Açıklama',
                    hint: 'Örn: Çiftlikten taze günlük süt',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: priceController,
                          label: 'Birim Fiyat (TL) *',
                          hint: '35.50',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: stockController,
                          label: 'Stok Miktarı',
                          hint: '20',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Birim Tipi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: units.contains(selectedUnit) ? selectedUnit : units.first,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: units
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedUnit = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: categories.contains(selectedCategory)
                                  ? selectedCategory
                                  : categories.first,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: categories
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedCategory = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Product Photo Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ürün Fotoğrafı',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      if (currentImageUrl.isNotEmpty)
                        Text(
                          'Fotoğraf Seçildi',
                          style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Image URL Text Field
                  AppTextField(
                    controller: imageUrlController,
                    label: 'Fotoğraf Bağlantısı (URL)',
                    hint: 'https://images.unsplash.com/...',
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setDialogState(() {}),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Veya Hazır Fotoğraflardan Seçin:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),

                  // Preset Real Photos Horizontal List
                  SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetPhotos.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final preset = _presetPhotos[index];
                        final isSelected = currentImageUrl == preset.url;

                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              imageUrlController.text = preset.url;
                              selectedImageKey = preset.sampleKey;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 68,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                width: isSelected ? 2.2 : 1,
                              ),
                              color: isSelected
                                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                                  : colorScheme.surface,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ProductVisualBadge(
                                  imageKey: preset.sampleKey,
                                  imageUrl: preset.url,
                                  size: 44,
                                  iconSize: 24,
                                  borderRadius: 6,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text('Hazır Görsel İkonu (Fotoğrafsız ise)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: imageKeys.map((key) {
                      final isSel = selectedImageKey == key;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedImageKey = key),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSel ? colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ProductVisualBadge(
                            imageKey: key,
                            size: 38,
                            iconSize: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Satışta Açık (Aktif)', style: TextStyle(fontSize: 13)),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final trimmedName = nameController.text.trim();
                final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
                final stock = int.tryParse(stockController.text.trim()) ?? 0;
                final rawImageUrl = imageUrlController.text.trim();
                final imageUrl = rawImageUrl.isNotEmpty ? rawImageUrl : null;

                if (trimmedName.isEmpty) {
                  setDialogState(() => errorMessage = 'Lütfen ürün adını yazınız.');
                  return;
                }

                if (price <= 0) {
                  setDialogState(() => errorMessage = 'Lütfen geçerli bir birim fiyat giriniz (0\'dan büyük).');
                  return;
                }

                if (isEditing) {
                  final updated = existingProduct.copyWith(
                    name: trimmedName,
                    description: descController.text.trim(),
                    price: price,
                    stock: stock > 0 ? stock : 1,
                    category: selectedCategory,
                    sampleImageKey: selectedImageKey,
                    imageUrl: imageUrl,
                    clearImageUrl: imageUrl == null,
                    isActive: isActive,
                    unit: selectedUnit,
                    unitPrices: selectedUnit == 'kg'
                        ? {'kg': price, 'adet': (price / 5).roundToDouble()}
                        : {'adet': price},
                  );
                  context.read<ProductBloc>().add(ProductUpdateRequested(updated));
                } else {
                  final newProduct = ProductEntity(
                    id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                    storeId: storeId,
                    storeName: storeName,
                    name: trimmedName,
                    description: descController.text.trim(),
                    price: price,
                    stock: stock > 0 ? stock : 10,
                    category: selectedCategory,
                    sampleImageKey: selectedImageKey,
                    imageUrl: imageUrl,
                    isActive: isActive,
                    unit: selectedUnit,
                    unitPrices: selectedUnit == 'kg'
                        ? {'kg': price, 'adet': (price / 5).roundToDouble()}
                        : {'adet': price},
                  );
                  context.read<ProductBloc>().add(ProductAddRequested(newProduct));
                }

                Navigator.pop(dialogCtx);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? '$trimmedName başarıyla güncellendi.'
                          : '$trimmedName başarıyla eklendi.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
              child: Text(isEditing ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        );
      },
    ),
  );
}
