import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahallem/core/theme/app_theme.dart';
import 'package:mahallem/core/theme/app_colors.dart';
import 'package:mahallem/core/widgets/app_button.dart';
import 'package:mahallem/core/widgets/product_image_placeholder.dart';
import 'package:mahallem/main.dart';
import 'package:mahallem/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mahallem/features/store/data/repositories/store_repository_impl.dart';
import 'package:mahallem/features/product/data/repositories/product_repository_impl.dart';
import 'package:mahallem/features/order/data/repositories/order_repository_impl.dart';
import 'package:mahallem/features/customer/data/repositories/address_repository_impl.dart';

void main() {
  testWidgets('MahallemApp başlatma ve temel arayüz duman testi', (WidgetTester tester) async {
    final authRepo = AuthRepositoryImpl();
    final storeRepo = StoreRepositoryImpl();
    final productRepo = ProductRepositoryImpl();
    final orderRepo = OrderRepositoryImpl(productRepository: productRepo);
    final addressRepo = AddressRepositoryImpl();

    await tester.pumpWidget(
      MahallemApp(
        authRepository: authRepo,
        storeRepository: storeRepo,
        productRepository: productRepo,
        orderRepository: orderRepo,
        addressRepository: addressRepo,
      ),
    );

    await tester.pumpAndSettle();

    // App starts on LoginScreen as requested
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text('Müşteri Olarak Gir'), findsOneWidget);

    // Scroll to and tap 'Müşteri Olarak Gir' to enter HomeScreen
    await tester.ensureVisible(find.text('Müşteri Olarak Gir'));
    await tester.tap(find.text('Müşteri Olarak Gir'));
    await tester.pumpAndSettle();

    // Verify neighborhood title is displayed
    expect(find.text('Gültepe Mahallesi'), findsOneWidget);
    // Verify bottom nav items exist
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Sepet'), findsOneWidget);

    // Tap 'Profil'
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Scroll to 'İşletme (Esnaf) Paneline Geç' and tap
    await tester.ensureVisible(find.text('İşletme (Esnaf) Paneline Geç'));
    await tester.tap(find.text('İşletme (Esnaf) Paneline Geç'));
    await tester.pumpAndSettle();

    // Verify BusinessHomeScreen is displayed
    expect(find.text('İşletme Paneli'), findsOneWidget);

    // Switch back to Customer: Tap 'Mağazam' tab (business settings)
    await tester.tap(find.text('Mağazam'));
    await tester.pumpAndSettle();

    // Scroll to and tap 'Müşteri Paneline Geç'
    await tester.ensureVisible(find.text('Müşteri Paneline Geç'));
    await tester.tap(find.text('Müşteri Paneline Geç'));
    await tester.pumpAndSettle();

    // Verify back to Customer HomeScreen
    expect(find.text('Gültepe Mahallesi'), findsOneWidget);
  });

  test('Material 3 Tema ve WCAG AA Kontrast renk tokenları doğrulama', () {
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
    expect(AppTheme.darkTheme.useMaterial3, isTrue);

    // Primary Brand Color #3158C9
    expect(AppColors.mahallemBlue, const Color(0xFF3158C9));
    // Secondary Brand Color #FF795E
    expect(AppColors.mahallemCoral, const Color(0xFFFF795E));

    // Light Theme ColorScheme
    expect(AppTheme.lightTheme.colorScheme.primary, const Color(0xFF3158C9));
    expect(AppTheme.lightTheme.colorScheme.secondary, const Color(0xFFFF795E));
  });

  testWidgets('AppButton minimum 48px dokunma hedefi testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Buton',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    final size = tester.getSize(buttonFinder);
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('ProductVisualBadge görsel render testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: ProductVisualBadge(imageKey: 'milk'),
          ),
        ),
      ),
    );

    expect(find.byType(ProductVisualBadge), findsOneWidget);
    expect(find.byIcon(Icons.local_drink), findsOneWidget);
  });

  testWidgets('Şifremi unuttum akışı dönen loader olmadan altta SnackBar göstermelidir', (WidgetTester tester) async {
    final authRepo = AuthRepositoryImpl();
    final storeRepo = StoreRepositoryImpl();
    final productRepo = ProductRepositoryImpl();
    final orderRepo = OrderRepositoryImpl(productRepository: productRepo);
    final addressRepo = AddressRepositoryImpl();

    await tester.pumpWidget(
      MahallemApp(
        authRepository: authRepo,
        storeRepository: storeRepo,
        productRepository: productRepo,
        orderRepository: orderRepo,
        addressRepository: addressRepo,
      ),
    );

    await tester.pumpAndSettle();

    // Tap "Şifremi Unuttum"
    await tester.tap(find.text('Şifremi Unuttum'));
    await tester.pumpAndSettle();

    expect(find.text('Şifrenizi mi Unuttunuz?'), findsOneWidget);

    // Enter email
    await tester.enterText(find.byType(TextFormField).first, 'test@mahallem.com');
    await tester.pumpAndSettle();

    // Tap "Sıfırlama Bağlantısı Gönder"
    await tester.tap(find.text('Sıfırlama Bağlantısı Gönder'));
    await tester.pump(); // Start async work
    await tester.pump(const Duration(milliseconds: 400)); // Complete mock delay
    await tester.pumpAndSettle();

    // Verify SnackBar appears
    expect(find.text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'), findsOneWidget);

    // Verify back to LoginScreen and not stuck on loader
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
