import 'package:flutter/material.dart';
import '../../store/presentation/screens/business_home_screen.dart';
import '../../store/presentation/screens/business_orders_screen.dart';
import '../../store/presentation/screens/business_products_screen.dart';
import '../../store/presentation/screens/business_settings_screen.dart';

/// Mahalle esnafı/işletme paneli gezinme kabuğu (Özet, Siparişler, Ürünler, Ayarlar).
class BusinessNavigationShell extends StatefulWidget {
  const BusinessNavigationShell({super.key});

  @override
  State<BusinessNavigationShell> createState() => _BusinessNavigationShellState();
}

class _BusinessNavigationShellState extends State<BusinessNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BusinessHomeScreen(),
    BusinessOrdersScreen(),
    BusinessProductsScreen(),
    BusinessSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Ürünler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Mağazam',
          ),
        ],
      ),
    );
  }
}

