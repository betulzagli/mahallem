import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/store/domain/repositories/store_repository.dart';
import 'features/store/data/repositories/store_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/order/domain/repositories/order_repository.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/customer/domain/repositories/address_repository.dart';
import 'features/customer/data/repositories/address_repository_impl.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/store/presentation/bloc/store_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/order/presentation/bloc/order_bloc.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/presentation/customer_navigation_shell.dart';
import 'features/navigation/presentation/business_navigation_shell.dart';

/// Uygulama giriş noktası (entry point).
///
/// Firebase servislerini güvenli şekilde başlatmayı dener. Firebase yapılandırması
/// henüz mevcut değilse veya hata oluşursa uygulama kesintisiz olarak bellek içi
/// (in-memory) demo verileriyle çalışacak şekilde yapılandırılır.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseReady = false;
  fb_auth.FirebaseAuth? firebaseAuth;
  FirebaseFirestore? firestore;

  try {
    // Attempt Firebase initialization if options or configuration is present
    await Firebase.initializeApp();
    firebaseAuth = fb_auth.FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    isFirebaseReady = true;
  } catch (_) {
    // Graceful fallback to demo mode when Firebase config files are not yet provided
    isFirebaseReady = false;
  }

  // Repositories initialization
  final authRepository = AuthRepositoryImpl(
    isFirebaseReady: isFirebaseReady,
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );

  final storeRepository = StoreRepositoryImpl(
    isFirebaseReady: isFirebaseReady,
    firestore: firestore,
  );

  final productRepository = ProductRepositoryImpl(
    isFirebaseReady: isFirebaseReady,
    firestore: firestore,
  );

  final orderRepository = OrderRepositoryImpl(
    isFirebaseReady: isFirebaseReady,
    firestore: firestore,
    productRepository: productRepository,
  );

  final addressRepository = AddressRepositoryImpl();

  runApp(
    MahallemApp(
      authRepository: authRepository,
      storeRepository: storeRepository,
      productRepository: productRepository,
      orderRepository: orderRepository,
      addressRepository: addressRepository,
    ),
  );
}

/// Mahallem uygulamasının kök widget'ı.
///
/// Clean Architecture prensiplerine uygun olarak tüm repository ve BLoC'ları
/// [MultiRepositoryProvider] ve [MultiBlocProvider] aracılığıyla widget ağacına enjekte eder.
/// Ayrıca [ThemeService] ile dinamik açık/koyu tema yönetimini dinler.
class MahallemApp extends StatelessWidget {
  final AuthRepository authRepository;
  final StoreRepository storeRepository;
  final ProductRepository productRepository;
  final OrderRepository orderRepository;
  final AddressRepository addressRepository;

  const MahallemApp({
    super.key,
    required this.authRepository,
    required this.storeRepository,
    required this.productRepository,
    required this.orderRepository,
    required this.addressRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<StoreRepository>.value(value: storeRepository),
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<OrderRepository>.value(value: orderRepository),
        RepositoryProvider<AddressRepository>.value(value: addressRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)
              ..add(AuthCheckRequested()),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(),
          ),
          BlocProvider<StoreBloc>(
            create: (context) => StoreBloc(storeRepository: storeRepository)
              ..add(StoresLoadRequested()),
          ),
          BlocProvider<ProductBloc>(
            create: (context) =>
                ProductBloc(productRepository: productRepository)
                  ..add(const ProductsLoadRequested()),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(orderRepository: orderRepository),
          ),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'Mahallem',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const AppRootRouter(),
            );
          },
        ),
      ),
    );
  }
}

/// Kimlik doğrulama durumuna ([AuthState]) göre kullanıcıyı doğru ekrana yönlendiren kök yönlendirici.
///
/// - Kullanıcı giriş yapmış ve esnaf ise -> [BusinessNavigationShell]
/// - Kullanıcı giriş yapmış ve müşteri ise -> [CustomerNavigationShell]
/// - İlk durum başlatılıyorsa -> Yükleme göstergesi
/// - Oturum kapalı ise -> [LoginScreen]
class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.user.isBusiness) {
            return const BusinessNavigationShell();
          } else {
            return const CustomerNavigationShell();
          }
        }
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
