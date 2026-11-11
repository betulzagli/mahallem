import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../../../core/constants/sample_data.dart';

/// [AuthRepository] arayüzünün somut implementasyonu.
///
/// Firebase Authentication ve Cloud Firestore servislerini kullanır; Firebase bağlı değilse
/// veya yapılandırma eksikse bellek içi demo kullanıcıları ve verileriyle çalışır.
class AuthRepositoryImpl implements AuthRepository {
  final bool _isFirebaseReady;
  final fb_auth.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  final _userController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  // In-memory demo users map
  final Map<String, ({UserEntity user, String password})> _demoUsers = {
    SampleData.sampleCustomer.email: (
      user: SampleData.sampleCustomer,
      password: 'password123',
    ),
    SampleData.sampleBusinessUser.email: (
      user: SampleData.sampleBusinessUser,
      password: 'password123',
    ),
  };

  AuthRepositoryImpl({
    bool isFirebaseReady = false,
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _isFirebaseReady = isFirebaseReady,
        _firebaseAuth = firebaseAuth,
        _firestore = firestore {
    // Start unauthenticated so app opens on LoginScreen
    _currentUser = null;
    _userController.add(null);

    if (_isFirebaseReady && _firebaseAuth != null) {
      _firebaseAuth.authStateChanges().listen((fbUser) async {
        if (fbUser == null) {
          _currentUser = null;
          _userController.add(null);
        } else {
          final doc = await _firestore?.collection('users').doc(fbUser.uid).get();
          if (doc != null && doc.exists) {
            final data = doc.data()!;
            _currentUser = UserEntity(
              id: fbUser.uid,
              email: fbUser.email ?? '',
              fullName: data['fullName'] ?? '',
              phoneNumber: data['phoneNumber'],
              role: data['role'] == 'business' ? UserRole.business : UserRole.customer,
              storeId: data['storeId'],
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
            _userController.add(_currentUser);
          }
        }
      });
    }
  }

  @override
  bool get isLiveFirebase => _isFirebaseReady;

  @override
  Stream<UserEntity?> get authStateChanges => _userController.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_isFirebaseReady && _firebaseAuth != null && _firestore != null) {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('Kullanıcı profili veritabanında bulunamadı.');
      }
      final data = doc.data()!;
      _currentUser = UserEntity(
        id: uid,
        email: cleanEmail,
        fullName: data['fullName'] ?? '',
        phoneNumber: data['phoneNumber'],
        role: data['role'] == 'business' ? UserRole.business : UserRole.customer,
        storeId: data['storeId'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      _userController.add(_currentUser);
      return _currentUser!;
    } else {
      // Demo / Mock Mode
      await Future.delayed(const Duration(milliseconds: 300));
      final record = _demoUsers[cleanEmail];
      if (record == null) {
        throw Exception('Kullanıcı bulunamadı. Lütfen kayıt olun veya örnek hesabı deneyin.');
      }
      if (record.password != password) {
        throw Exception('Hatalı şifre girdiniz.');
      }
      _currentUser = record.user;
      _userController.add(_currentUser);
      return _currentUser!;
    }
  }

  @override
  Future<UserEntity> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_isFirebaseReady && _firebaseAuth != null && _firestore != null) {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserEntity(
        id: uid,
        email: cleanEmail,
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).set({
        'email': cleanEmail,
        'fullName': user.fullName,
        'phoneNumber': user.phoneNumber,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _currentUser = user;
      _userController.add(_currentUser);
      return user;
    } else {
      // Demo / Mock Mode
      await Future.delayed(const Duration(milliseconds: 300));
      if (_demoUsers.containsKey(cleanEmail)) {
        throw Exception('Bu e-posta adresiyle zaten kayıtlı bir hesap var.');
      }
      final user = UserEntity(
        id: 'user_cust_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );
      _demoUsers[cleanEmail] = (user: user, password: password);
      _currentUser = user;
      _userController.add(_currentUser);
      return user;
    }
  }

  @override
  Future<UserEntity> registerBusiness({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
    required String category,
    required String phone,
    required String address,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_isFirebaseReady && _firebaseAuth != null && _firestore != null) {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final uid = credential.user!.uid;
      final storeRef = _firestore.collection('stores').doc();
      final storeId = storeRef.id;

      await _firestore.runTransaction((transaction) async {
        transaction.set(_firestore.collection('users').doc(uid), {
          'email': cleanEmail,
          'fullName': fullName.trim(),
          'phoneNumber': phone.trim(),
          'role': 'business',
          'storeId': storeId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(storeRef, {
          'ownerId': uid,
          'name': storeName.trim(),
          'description': '$storeName kaliteli ve taze ürünleriyle hizmetinizdedir.',
          'category': category,
          'phoneNumber': phone.trim(),
          'address': address.trim(),
          'neighborhood': SampleData.neighborhood,
          'isOpen': true,
          'isPaused': false,
          'openingHours': '08:00 - 21:00',
          'sampleImageKey': 'grocery',
          'sampleRouteDistanceKm': 1.5,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      final user = UserEntity(
        id: uid,
        email: cleanEmail,
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        role: UserRole.business,
        storeId: storeId,
        createdAt: DateTime.now(),
      );
      _currentUser = user;
      _userController.add(_currentUser);
      return user;
    } else {
      // Demo / Mock Mode
      await Future.delayed(const Duration(milliseconds: 300));
      if (_demoUsers.containsKey(cleanEmail)) {
        throw Exception('Bu e-posta adresiyle zaten kayıtlı bir hesap var.');
      }
      final storeId = 'store_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserEntity(
        id: 'user_biz_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        role: UserRole.business,
        storeId: storeId,
        createdAt: DateTime.now(),
      );

      final newStore = StoreEntity(
        id: storeId,
        ownerId: user.id,
        name: storeName.trim(),
        description: '$storeName taze ve yerel ürünleriyle mahallenizde.',
        category: category,
        phoneNumber: phone.trim(),
        address: address.trim(),
        neighborhood: SampleData.neighborhood,
        isOpen: true,
        isPaused: false,
        sampleImageKey: 'grocery',
        sampleRouteDistanceKm: 1.5,
      );
      SampleData.stores.add(newStore);

      _demoUsers[cleanEmail] = (user: user, password: password);
      _currentUser = user;
      _userController.add(_currentUser);
      return user;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_isFirebaseReady && _firebaseAuth != null) {
      await _firebaseAuth.sendPasswordResetEmail(email: cleanEmail);
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      // In offline / mock mode, allow any valid email address to receive mock reset
    }
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseReady && _firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
    _currentUser = null;
    _userController.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    if (_isFirebaseReady && _firebaseAuth != null && _firestore != null) {
      final uid = _currentUser!.id;
      await _firestore.collection('users').doc(uid).delete();
      await _firebaseAuth.currentUser?.delete();
    } else {
      _demoUsers.remove(_currentUser!.email);
    }
    await signOut();
  }
}
