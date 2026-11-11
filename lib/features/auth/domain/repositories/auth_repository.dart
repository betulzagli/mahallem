import '../entities/user_entity.dart';

/// Kimlik doğrulama işlemlerinin soyut arayüzü (Interface).
///
/// Clean Architecture prensiplerine göre Domain katmanı Data katmanından bağımsızdır.
/// Bu sayede Firebase veya test/demo bellek içi implementasyonları kolayca değiştirilebilir.
abstract class AuthRepository {
  /// Kullanıcı oturum durumu değişikliklerini dinleyen akış (stream).
  Stream<UserEntity?> get authStateChanges;

  /// Şu anki aktif kullanıcı varlığı.
  UserEntity? get currentUser;

  /// Gerçek Firebase bağlantısının etkin olup olmadığını bildirir.
  bool get isLiveFirebase;

  /// E-posta ve şifre ile giriş yapar.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Yeni bir müşteri hesabı oluşturur.
  Future<UserEntity> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  /// Yeni bir esnaf/işletme hesabı ve ilişkili mağazayı oluşturur.
  Future<UserEntity> registerBusiness({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
    required String category,
    required String phone,
    required String address,
  });

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordResetEmail(String email);

  /// Oturumu kapatır.
  Future<void> signOut();

  /// Kullanıcı hesabını ve ilişkili kişisel verileri kalıcı olarak siler.
  Future<void> deleteAccount();
}

