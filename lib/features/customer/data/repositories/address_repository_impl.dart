import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../../../../core/constants/sample_data.dart';

/// [AddressRepository] arayüzünün bellek içi (in-memory) implementasyonu.
class AddressRepositoryImpl implements AddressRepository {
  final List<AddressEntity> _memoryAddresses = List.from(SampleData.sampleAddresses);

  @override
  Future<List<AddressEntity>> getAddresses(String userId) async {
    return _memoryAddresses.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> addAddress(AddressEntity address) async {
    if (address.isDefault) {
      for (int i = 0; i < _memoryAddresses.length; i++) {
        if (_memoryAddresses[i].userId == address.userId) {
          _memoryAddresses[i] = _memoryAddresses[i].copyWith(isDefault: false);
        }
      }
    }
    _memoryAddresses.add(address);
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    final index = _memoryAddresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        for (int i = 0; i < _memoryAddresses.length; i++) {
          if (_memoryAddresses[i].userId == address.userId && i != index) {
            _memoryAddresses[i] = _memoryAddresses[i].copyWith(isDefault: false);
          }
        }
      }
      _memoryAddresses[index] = address;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    _memoryAddresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    for (int i = 0; i < _memoryAddresses.length; i++) {
      if (_memoryAddresses[i].userId == userId) {
        _memoryAddresses[i] = _memoryAddresses[i].copyWith(
          isDefault: _memoryAddresses[i].id == addressId,
        );
      }
    }
  }
}

