import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../../../../core/constants/sample_data.dart';

/// [StoreRepository] arayüzünün somut implementasyonu.
///
/// Cloud Firestore ve bellek içi örnek esnaf verilerini eşzamanlı destekler.
class StoreRepositoryImpl implements StoreRepository {
  final bool _isFirebaseReady;
  final FirebaseFirestore? _firestore;

  final List<StoreEntity> _memoryStores = List.from(SampleData.stores);
  final _storesStreamController = StreamController<List<StoreEntity>>.broadcast();

  StoreRepositoryImpl({
    bool isFirebaseReady = false,
    FirebaseFirestore? firestore,
  })  : _isFirebaseReady = isFirebaseReady,
        _firestore = firestore {
    _storesStreamController.add(_memoryStores);
  }

  @override
  Future<List<StoreEntity>> getStores() async {
    if (_isFirebaseReady && _firestore != null) {
      final snapshot = await _firestore.collection('stores').get();
      return snapshot.docs.map((doc) => _fromFirestore(doc.id, doc.data())).toList();
    }
    return List.unmodifiable(_memoryStores);
  }

  @override
  Future<StoreEntity?> getStoreById(String storeId) async {
    if (_isFirebaseReady && _firestore != null) {
      final doc = await _firestore.collection('stores').doc(storeId).get();
      if (!doc.exists) return null;
      return _fromFirestore(doc.id, doc.data()!);
    }
    try {
      return _memoryStores.firstWhere((s) => s.id == storeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<StoreEntity?> watchStore(String storeId) {
    if (_isFirebaseReady && _firestore != null) {
      return _firestore.collection('stores').doc(storeId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return _fromFirestore(doc.id, doc.data()!);
      });
    }
    return _storesStreamController.stream.map((list) {
      try {
        return list.firstWhere((s) => s.id == storeId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> updateStore(StoreEntity store) async {
    if (_isFirebaseReady && _firestore != null) {
      await _firestore.collection('stores').doc(store.id).update({
        'name': store.name,
        'description': store.description,
        'category': store.category,
        'phoneNumber': store.phoneNumber,
        'address': store.address,
        'isOpen': store.isOpen,
        'isPaused': store.isPaused,
        'autoReopenOnNextSchedule': store.autoReopenOnNextSchedule,
        'openingHours': store.openingHours,
      });
    }
    final index = _memoryStores.indexWhere((s) => s.id == store.id);
    if (index != -1) {
      _memoryStores[index] = store;
      _storesStreamController.add(_memoryStores);
    }
  }

  @override
  Future<void> toggleStoreOpenStatus(String storeId, bool isOpen, bool autoReopen) async {
    final store = await getStoreById(storeId);
    if (store == null) return;
    final updated = store.copyWith(
      isOpen: isOpen,
      autoReopenOnNextSchedule: autoReopen,
    );
    await updateStore(updated);
  }

  @override
  Future<void> toggleStorePauseStatus(String storeId, bool isPaused) async {
    final store = await getStoreById(storeId);
    if (store == null) return;
    final updated = store.copyWith(isPaused: isPaused);
    await updateStore(updated);
  }

  StoreEntity _fromFirestore(String id, Map<String, dynamic> data) {
    return StoreEntity(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      neighborhood: data['neighborhood'] ?? SampleData.neighborhood,
      isOpen: data['isOpen'] ?? true,
      isPaused: data['isPaused'] ?? false,
      autoReopenOnNextSchedule: data['autoReopenOnNextSchedule'] ?? true,
      openingHours: data['openingHours'] ?? '08:00 - 21:00',
      sampleImageKey: data['sampleImageKey'] ?? 'grocery',
      sampleRouteDistanceKm: (data['sampleRouteDistanceKm'] as num?)?.toDouble() ?? 1.5,
    );
  }
}

