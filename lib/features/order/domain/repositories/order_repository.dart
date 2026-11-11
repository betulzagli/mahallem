import '../entities/order_entity.dart';

/// Sipariş ve alt sipariş operasyonlarının soyut depo arayüzü.
abstract class OrderRepository {
  /// Yeni bir sipariş oluşturur ve stokları rezerve eder.
  Future<OrderEntity> createOrder(OrderEntity order);

  /// Müşterinin geçmiş ve aktif tüm siparişlerini getirir.
  Future<List<OrderEntity>> getCustomerOrders(String customerId);

  /// Belirli bir işletmeye gelen tüm alt siparişleri getirir.
  Future<List<OrderEntity>> getStoreOrders(String storeId);

  /// Müşteri siparişlerini gerçek zamanlı dinleyen akış (stream).
  Stream<List<OrderEntity>> watchCustomerOrders(String customerId);

  /// İşletme siparişlerini gerçek zamanlı dinleyen akış (stream).
  Stream<List<OrderEntity>> watchStoreOrders(String storeId);

  /// Tekil bir siparişi gerçek zamanlı dinleyen akış (stream).
  Stream<OrderEntity?> watchOrder(String orderId);
  
  /// İlgili marketin alt sipariş durumunu günceller (kabul, ret, hazır vb.).
  Future<void> updateSubOrderStatus({
    required String orderId,
    required String storeId,
    required SubOrderStatus status,
    String? reason,
  });

  /// Bir veya daha fazla market siparişi reddettiğinde müşterinin kalan marketlerle devam etmesini sağlar.
  Future<void> customerContinueAfterRejection({
    required String orderId,
    required String rejectedStoreId,
  });

  /// Siparişi iptal eder ve varsa ayrılan stokları iade eder.
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  });

  /// Market yanıt (10 dk) veya müşteri karar (5 dk) zaman aşımlarını değerlendirir.
  Future<void> evaluateTimeouts(String orderId);
}

