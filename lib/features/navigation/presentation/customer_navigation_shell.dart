import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../customer/presentation/screens/home_screen.dart';
import '../../customer/presentation/screens/explore_screen.dart';
import '../../cart/presentation/screens/cart_screen.dart';
import '../../order/presentation/screens/order_list_screen.dart';
import '../../customer/presentation/screens/profile_screen.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';

/// Müşteri arayüzü ana gezinme kabuğu (Ana Sayfa, Keşfet, Sepet, Siparişler, Profil).
///
/// [IndexedStack] kullanarak ekran durumlarını korur ve sepet rozetini dinamik günceller.
class CustomerNavigationShell extends StatefulWidget {
  const CustomerNavigationShell({super.key});

  @override
  State<CustomerNavigationShell> createState() => _CustomerNavigationShellState();
}

class _CustomerNavigationShellState extends State<CustomerNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),
    OrderListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          // Badge shows the count of unique product varieties
          final cartCount = cartState.cart.items.length;

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Keşfet',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                activeIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Sepet',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Siparişlerim',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}
