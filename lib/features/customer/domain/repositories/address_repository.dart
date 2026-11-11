import '../entities/address_entity.dart';

/// Adres işlemlerini tanımlayan soyut depo arayüzü.
abstract class AddressRepository {
  /// Kullanıcının kayıtlı tüm adreslerini getirir.
  Future<List<AddressEntity>> getAddresses(String userId);

  /// Yeni bir teslimat adresi kaydeder.
  Future<void> addAddress(AddressEntity address);

  /// Mevcut bir teslimat adresini günceller.
  Future<void> updateAddress(AddressEntity address);

  /// Belirtilen adresi siler.
  Future<void> deleteAddress(String addressId);

  /// Belirtilen adresi kullanıcının varsayılan teslimat adresi olarak ayarlar.
  Future<void> setDefaultAddress(String userId, String addressId);
}

