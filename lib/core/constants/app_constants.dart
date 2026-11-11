/// Uygulama genelinde kullanılan sabitleri, iş kuralı parametrelerini ve sürelerini barındıran sınıf.
class AppConstants {
  AppConstants._();

  static const String appName = 'Mahallem';
  static const String appTagline = 'Dijital Pazar';

  /// Tek örnek mahalle kuralı
  static const String defaultNeighborhood = 'Gültepe Mahallesi';

  /// Sipariş başına maksimum market sınırı
  static const int maxMarketsPerOrder = 3;

  /// Market yanıt süresi (dakika) - Kesinleşen kural: 10 dakika
  static const Duration storeResponseDuration = Duration(minutes: 10);

  /// Ret sonrası müşteri karar süresi (dakika) - Kesinleşen kural: 5 dakika
  static const Duration customerDecisionDuration = Duration(minutes: 5);

  /// Demo kurye aşama süreleri (saniye cinsinden yapılandırılabilir)
  static const Duration courierAssignedDuration = Duration(seconds: 15);
  static const Duration courierCollectingDuration = Duration(seconds: 30);
  static const Duration courierOnTheWayDuration = Duration(seconds: 30);

  /// Demo teslimat ücreti bileşenleri
  static const double baseDeliveryFee = 20.0;
  static const double perMarketFee = 5.0;
  static const double perKilometerFee = 3.0;

  /// Örnek rota kilometreleri (Market kombinasyonlarına göre deterministik mesafe)
  static double getRouteKmForStores(List<String> storeIds) {
    if (storeIds.isEmpty) return 0.0;
    if (storeIds.length == 1) return 1.5;
    if (storeIds.length == 2) return 2.8;
    return 4.2; // 3 market
  }
}

