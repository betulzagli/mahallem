import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/sample_data.dart';

// Events
/// Kimlik doğrulama olaylarının temel sınıfı.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Oturum durumunu kontrol etme olayı.
class AuthCheckRequested extends AuthEvent {}

/// Giriş yapma olayı.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

/// Müşteri kaydı oluşturma olayı.
class AuthRegisterCustomerRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  const AuthRegisterCustomerRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });
  @override
  List<Object?> get props => [email, password, fullName, phone];
}

/// Esnaf/İşletme kaydı oluşturma olayı.
class AuthRegisterBusinessRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String storeName;
  final String category;
  final String phone;
  final String address;
  const AuthRegisterBusinessRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.storeName,
    required this.category,
    required this.phone,
    required this.address,
  });
  @override
  List<Object?> get props => [email, password, fullName, storeName, category, phone, address];
}

/// Şifre sıfırlama bağlantısı talep etme olayı.
class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthDeleteAccountRequested extends AuthEvent {}

class AuthSwitchDemoRoleRequested extends AuthEvent {
  final UserRole targetRole;
  const AuthSwitchDemoRoleRequested(this.targetRole);
  @override
  List<Object?> get props => [targetRole];
}

// States
/// Kimlik doğrulama durumlarının temel sınıfı.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu.
class AuthInitial extends AuthState {}

/// İşlem yürütülürken gösterilen yükleme durumu.
class AuthLoading extends AuthState {}

/// Başarılı giriş yapılmış durum.
class Authenticated extends AuthState {
  final UserEntity user;
  final bool isLiveFirebase;
  const Authenticated({required this.user, required this.isLiveFirebase});
  @override
  List<Object?> get props => [user, isLiveFirebase];
}

/// Oturum kapalı durumu.
class Unauthenticated extends AuthState {
  final bool isLiveFirebase;
  final String? message;
  const Unauthenticated({required this.isLiveFirebase, this.message});
  @override
  List<Object?> get props => [isLiveFirebase, message];
}

/// Hata durumu.
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// Kimlik doğrulama durum ve iş mantığını yöneten BLoC.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthRegisterCustomerRequested>(_onRegisterCustomer);
    on<AuthRegisterBusinessRequested>(_onRegisterBusiness);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthSwitchDemoRoleRequested>(_onSwitchDemoRole);
  }

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(Authenticated(user: user, isLiveFirebase: _authRepository.isLiveFirebase));
    } else {
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user, isLiveFirebase: _authRepository.isLiveFirebase));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onRegisterCustomer(
      AuthRegisterCustomerRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerCustomer(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
      );
      emit(Authenticated(user: user, isLiveFirebase: _authRepository.isLiveFirebase));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onRegisterBusiness(
      AuthRegisterBusinessRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerBusiness(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        storeName: event.storeName,
        category: event.category,
        phone: event.phone,
        address: event.address,
      );
      emit(Authenticated(user: user, isLiveFirebase: _authRepository.isLiveFirebase));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onPasswordReset(
      AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(Unauthenticated(
        isLiveFirebase: _authRepository.isLiveFirebase,
        message: 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
      ));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
  }

  Future<void> _onDeleteAccount(
      AuthDeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.deleteAccount();
      emit(Unauthenticated(
        isLiveFirebase: _authRepository.isLiveFirebase,
        message: 'Hesabınız kalıcı olarak silindi.',
      ));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(Unauthenticated(isLiveFirebase: _authRepository.isLiveFirebase));
    }
  }

  Future<void> _onSwitchDemoRole(
      AuthSwitchDemoRoleRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    if (event.targetRole == UserRole.business) {
      emit(Authenticated(
        user: SampleData.sampleBusinessUser,
        isLiveFirebase: _authRepository.isLiveFirebase,
      ));
    } else {
      emit(Authenticated(
        user: SampleData.sampleCustomer,
        isLiveFirebase: _authRepository.isLiveFirebase,
      ));
    }
  }
}

