import '../constants/app_constants.dart';

/// Teslimat ücreti hesaplama çıktısını ve alt bileşenlerini tutan model.
class DeliveryFeeCalculation {
  /// Siparişte yer alan tekil market/esnaf sayısı.
  final int storeCount;

  /// Toplam tahmini kurye rota mesafesi (km).
  final double routeKm;

  /// Taban teslimat ücreti (20.0 TL).
  final double baseFee;

  /// Market sayısına bağlı ücret bileşeni (Market başına 5.0 TL).
  final double storeFee;

  /// Rota mesafesine bağlı ücret bileşeni (Km başına 3.0 TL).
  final double distanceFee;

  /// Müşteriye yansıtılan nihai toplam teslimat ücreti.
  final double totalDeliveryFee;

  const DeliveryFeeCalculation({
    required this.storeCount,
    required this.routeKm,
    required this.baseFee,
    required this.storeFee,
    required this.distanceFee,
    required this.totalDeliveryFee,
  });
}

/// Kesinleşen teslimat ücreti kurallarına göre hesaplama yapan yardımcı sınıf.
///
/// Formül:
/// `Toplam Teslimat Ücreti = 20 TL (Taban) + (Market Sayısı × 5 TL) + (Rota Km × 3 TL)`
class DeliveryFeeCalculator {
  DeliveryFeeCalculator._();

  /// Verilen mağaza listesi ve opsiyonel özel mesafe bilgisi ile teslimat ücretini hesaplar.
  static DeliveryFeeCalculation calculate({
    required List<String> storeIds,
    double? customRouteKm,
  }) {
    final count = storeIds.toSet().length;
    if (count == 0) {
      return const DeliveryFeeCalculation(
        storeCount: 0,
        routeKm: 0.0,
        baseFee: 0.0,
        storeFee: 0.0,
        distanceFee: 0.0,
        totalDeliveryFee: 0.0,
      );
    }

    final km = customRouteKm ?? AppConstants.getRouteKmForStores(storeIds);
    final base = AppConstants.baseDeliveryFee;
    final storeComponent = count * AppConstants.perMarketFee;
    final distanceComponent =
        ((km * AppConstants.perKilometerFee) * 100).round() / 100;
    final total =
        ((base + storeComponent + distanceComponent) * 100).round() / 100;

    return DeliveryFeeCalculation(
      storeCount: count,
      routeKm: km,
      baseFee: base,
      storeFee: storeComponent,
      distanceFee: distanceComponent,
      totalDeliveryFee: total,
    );
  }
}
