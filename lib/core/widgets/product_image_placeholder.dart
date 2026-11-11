import 'package:flutter/material.dart';

/// Ürün veya mağaza anahtarına (`imageKey`) göre uygun ikon ve renk tonunu belirleyen çözümleyici.
class SampleVisualResolver {
  SampleVisualResolver._();

  /// Verilen anahtar için Material ikonu döndürür.
  static IconData getIcon(String key) {
    return switch (key) {
      'grocery' => Icons.storefront,
      'produce' => Icons.eco,
      'meat' => Icons.restaurant,
      'bakery' => Icons.bakery_dining,
      'milk' => Icons.local_drink,
      'eggs' => Icons.egg,
      'cheese' => Icons.lunch_dining,
      'tea' => Icons.coffee,
      'tomato' => Icons.agriculture,
      'cucumber' => Icons.spa,
      'apple' => Icons.apple,
      'banana' => Icons.nature,
      'minced_meat' => Icons.dinner_dining,
      'cubed_meat' => Icons.set_meal,
      'chicken' => Icons.kebab_dining,
      'bread' => Icons.breakfast_dining,
      'simit' => Icons.donut_large,
      'pastry' => Icons.cake,
      _ => Icons.shopping_basket,
    };
  }

  static Color getTint(String key, ColorScheme scheme) {
    return switch (key) {
      'grocery' || 'milk' || 'tea' => scheme.primary,
      'produce' || 'cucumber' || 'apple' => Colors.green.shade700,
      'meat' || 'minced_meat' || 'cubed_meat' || 'chicken' => scheme.secondary,
      'bakery' || 'bread' || 'simit' || 'pastry' => Colors.orange.shade700,
      'tomato' => Colors.red.shade700,
      'eggs' || 'cheese' => Colors.amber.shade800,
      _ => scheme.primary,
    };
  }
}

/// Ürün fotoğrafı veya kategori ikonunu gösteren görsel rozet bileşeni.
///
/// Eğer geçerli bir [imageUrl] varsa ağ üzerinden görseli yükler; yüklenemezse veya
/// URL verilmemişse tematik arka plan ve ikona zarif bir şekilde geri düşer (fallback).
class ProductVisualBadge extends StatelessWidget {
  final String imageKey;
  final String? imageUrl;
  final double size;
  final double iconSize;
  final double borderRadius;

  const ProductVisualBadge({
    super.key,
    required this.imageKey,
    this.imageUrl,
    this.size = 64,
    this.iconSize = 32,
    this.borderRadius = 12,
  });

  Widget _buildFallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = SampleVisualResolver.getTint(imageKey, scheme);
    final icon = SampleVisualResolver.getIcon(imageKey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: SizedBox(
                  width: iconSize * 0.5,
                  height: iconSize * 0.5,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildFallback(context);
  }
}

