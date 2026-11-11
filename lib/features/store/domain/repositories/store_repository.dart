import '../entities/store_entity.dart';

/// İşletme/mağaza operasyonlarını tanımlayan soyut depo arayüzü.
abstract class StoreRepository {
  /// Mahalledeki tüm işletmeleri listeler.
  Future<List<StoreEntity>> getStores();

  /// Kimliğe göre tek bir işletmeyi getirir.
  Future<StoreEntity?> getStoreById(String storeId);

  /// Belirli bir işletmeyi gerçek zamanlı dinleyen akış (stream).
  Stream<StoreEntity?> watchStore(String storeId);

  /// İşletme profil ve ayarlarını günceller.
  Future<void> updateStore(StoreEntity store);

  /// İşletmenin açık/kapalı durumunu değiştirir.
  Future<void> toggleStoreOpenStatus(String storeId, bool isOpen, bool autoReopen);

  /// İşletmenin sipariş kabulünü geçici duraklatma (yoğunluk molası) durumunu değiştirir.
  Future<void> toggleStorePauseStatus(String storeId, bool isPaused);
}

