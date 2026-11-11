import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../store/presentation/bloc/store_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/search_filter_helper.dart';
import 'market_detail_screen.dart';
import 'product_detail_screen.dart';

/// Keşfet ve arama ekranı: Türkçe karakter duyarsız arama, kategori filtreleme
/// ve ürünler/dükkanlar sekmeleri ile kapsamlı arama deneyimi sunar.
class ExploreScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const ExploreScreen({
    super.key,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _searchController;
  late String _searchQuery;
  late String _selectedCategory;
  String _sortOption = 'Varsayılan';

  final List<String> _categories = [
    'Tümü',
    'Market & Bakkal',
    'Manav',
    'Kasap',
    'Fırın & Unlu Mamül',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchQuery = widget.initialQuery ?? '';
    _selectedCategory = widget.initialCategory ?? 'Tümü';
    _searchController = TextEditingController(text: _searchQuery);

    context.read<ProductBloc>().add(const ProductsLoadRequested());
    context.read<StoreBloc>().add(StoresLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet ve Ara'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Ürünler'),
            Tab(text: 'Esnaflar'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ürün veya esnaf adı ile arayın...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Category dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategory,
                            items: _categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v ?? 'Tümü'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortOption,
                          items: const [
                            DropdownMenuItem(value: 'Varsayılan', child: Text('Varsayılan', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Fiyat (Artan)', child: Text('Fiyat (Artan)', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Fiyat (Azalan)', child: Text('Fiyat (Azalan)', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => _sortOption = v ?? 'Varsayılan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Products Tab
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductsLoaded) {
                      final storeState = context.watch<StoreBloc>().state;
                      final stores = storeState is StoreLoaded ? storeState.stores : <StoreEntity>[];

                      var list = state.products.where((p) {
                        final matchesQuery = _searchQuery.isEmpty ||
                            SearchFilterHelper.matchesQuery(p.name, _searchQuery) ||
                            SearchFilterHelper.matchesQuery(p.storeName, _searchQuery) ||
                            SearchFilterHelper.matchesQuery(p.category, _searchQuery);

                        final matchesCat = SearchFilterHelper.matchesProductCategory(
                          product: p,
                          selectedCategory: _selectedCategory,
                          stores: stores,
                        );

                        return matchesQuery && matchesCat;
                      }).toList();

                      if (_sortOption == 'Fiyat (Artan)') {
                        list.sort((a, b) => a.price.compareTo(b.price));
                      } else if (_sortOption == 'Fiyat (Azalan)') {
                        list.sort((a, b) => b.price.compareTo(a.price));
                      }

                      if (list.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.search_off,
                          title: 'Arama Sonucu Bulunamadı',
                          message: 'Aradığınız kriterlere uygun ürün bulunamadı. Lütfen filtrelerinizi kontrol edin.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = list[index];
                          return _ProductListItem(product: p);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // 2. Stores Tab
                BlocBuilder<StoreBloc, StoreState>(
                  builder: (context, state) {
                    if (state is StoreLoaded) {
                      final stores = state.stores.where((s) {
                        final matchesQuery = _searchQuery.isEmpty ||
                            SearchFilterHelper.matchesQuery(s.name, _searchQuery) ||
                            SearchFilterHelper.matchesQuery(s.category, _searchQuery);

                        final matchesCat = SearchFilterHelper.matchesStoreCategory(
                          store: s,
                          selectedCategory: _selectedCategory,
                        );

                        return matchesQuery && matchesCat;
                      }).toList();

                      if (stores.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'Esnaf Bulunamadı',
                          message: 'Aradığınız kriterlere uygun mahalle esnafı bulunamadı.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: stores.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return _StoreListItem(store: store);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatefulWidget {
  final ProductEntity product;

  const _ProductListItem({required this.product});

  @override
  State<_ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<_ProductListItem> {
  int _quantity = 1;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.product.allowedUnits.isNotEmpty
        ? widget.product.allowedUnits.first
        : widget.product.unit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.product;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProductVisualBadge(
              imageKey: product.sampleImageKey,
              imageUrl: product.imageUrl,
              size: 60,
              iconSize: 30,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.storeName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(product.priceForUnit(_selectedUnit)),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' / $_selectedUnit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (product.allowedUnits.length > 1) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: product.allowedUnits.map((u) {
                        final isSel = _selectedUnit == u;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedUnit = u),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSel ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                u,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Stepper and Add button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: _quantity > 1 ? colorScheme.onSurface : colorScheme.outline,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                      InkWell(
                        onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: _quantity < product.stock ? colorScheme.onSurface : colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: product.isInStock
                      ? () {
                          context.read<CartBloc>().add(
                                CartItemAdded(
                                  product: product,
                                  quantity: _quantity,
                                  unit: _selectedUnit,
                                ),
                              );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$_quantity $_selectedUnit ${product.name} sepete eklendi.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: product.isInStock
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ekle',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreListItem extends StatelessWidget {
  final StoreEntity store;

  const _StoreListItem({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketDetailScreen(storeId: store.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.8),
        ),
        child: Row(
          children: [
            ProductVisualBadge(
              imageKey: store.sampleImageKey,
              imageUrl: store.imageUrl,
              size: 56,
              iconSize: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.canAcceptOrders
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.canAcceptOrders ? 'Açık' : 'Kapalı',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: store.canAcceptOrders
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        store.openingHours,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.route, size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${store.sampleRouteDistanceKm} km rota',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
