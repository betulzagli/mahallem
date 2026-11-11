import 'package:flutter/foundation.dart';
import '../../features/customer/domain/entities/address_entity.dart';
import '../constants/sample_data.dart';

/// Müşteri adreslerinin uygulama genelinde reaktif senkronizasyonunu sağlayan servis.
///
/// [ValueNotifier] yapısı sayesinde varsayılan adres değiştirildiğinde veya yeni adres
/// eklendiğinde ana sayfa, sepet ve adres yönetimi ekranları anında güncellenir.
class AddressService {
  AddressService._();

  /// Dinlenebilir adres listesi. Değişiklikler anında UI'ya yansıtılır.
  static final ValueNotifier<List<AddressEntity>> addressesNotifier =
      ValueNotifier<List<AddressEntity>>(List.from(SampleData.sampleAddresses));

  /// Aktif olarak seçili olan varsayılan teslimat adresini döner.
  static AddressEntity get defaultAddress {
    final list = addressesNotifier.value;
    if (list.isEmpty) {
      return const AddressEntity(
        id: 'addr_default',
        userId: 'user_customer_demo',
        title: 'Evim',
        neighborhood: SampleData.neighborhood,
        fullAddress: 'Gültepe Mah. Lale Sokak No: 14 Daire: 5',
        isDefault: true,
      );
    }
    return list.firstWhere(
      (a) => a.isDefault,
      orElse: () => list.first,
    );
  }

  /// Belirtilen adresi varsayılan adres yapar, diğer adreslerin `isDefault` değerini `false` yapar.
  static void setDefaultAddress(String addressId) {
    final updated = addressesNotifier.value.map((addr) {
      return addr.copyWith(isDefault: addr.id == addressId);
    }).toList();

    addressesNotifier.value = updated;
    SampleData.sampleAddresses
      ..clear()
      ..addAll(updated);
  }

  /// Yeni bir adres ekler. Eğer ilk adres ise veya `isDefault` seçildiyse varsayılan yapar.
  static void addAddress(AddressEntity address) {
    final list = List<AddressEntity>.from(addressesNotifier.value);
    // If this is set as default or is the first address, make others non-default
    final isFirst = list.isEmpty;
    final makeDefault = address.isDefault || isFirst;

    final updated = list.map((a) => makeDefault ? a.copyWith(isDefault: false) : a).toList();
    updated.add(address.copyWith(isDefault: makeDefault));

    addressesNotifier.value = updated;
    SampleData.sampleAddresses
      ..clear()
      ..addAll(updated);
  }

  /// Belirtilen kimliğe sahip adresi siler. Silinen adres varsayılan ise ilk kalanı varsayılan yapar.
  static void deleteAddress(String addressId) {
    final list = List<AddressEntity>.from(addressesNotifier.value);
    list.removeWhere((a) => a.id == addressId);
    if (list.isNotEmpty && !list.any((a) => a.isDefault)) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    addressesNotifier.value = list;
    SampleData.sampleAddresses
      ..clear()
      ..addAll(list);
  }
}

