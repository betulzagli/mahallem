import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../store/presentation/bloc/store_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/utils/search_filter_helper.dart';
import '../../domain/entities/address_entity.dart';
import 'market_detail_screen.dart';
import 'product_detail_screen.dart';
import 'explore_screen.dart';
import 'addresses_screen.dart';

/// Müşteri ana sayfası: Mahalle başlığı, adres seçici, kategori filtreleri,
/// açık dükkanlar vitrini ve popüler ürünler listesi sunar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

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
    context.read<StoreBloc>().add(StoresLoadRequested());
    context.read<ProductBloc>().add(const ProductsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: false,
        title: ValueListenableBuilder<List<AddressEntity>>(
          valueListenable: AddressService.addressesNotifier,
          builder: (context, addresses, child) {
            final defaultAddr = AddressService.defaultAddress;
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          defaultAddr.title.isNotEmpty ? defaultAddr.title : defaultAddr.neighborhood,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            defaultAddr.neighborhood,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                    Text(
                      defaultAddr.fullAddress.isNotEmpty
                          ? defaultAddr.fullAddress
                          : defaultAddr.neighborhood,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StoreBloc>().add(StoresLoadRequested());
          context.read<ProductBloc>().add(const ProductsLoadRequested());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Clickable Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExploreScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(
                          'Ürün veya mahalle esnafı arayın...',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campaign / Promo Banner (Mahallem Coral Accent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.local_shipping_outlined,
                            size: 28, color: colorScheme.secondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 Markete Kadar Tek Teslimat!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bakkal, manav ve kasaptan tek siparişle alın, kurye kapınıza tek seferde getirsin.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Categories Horizontal List
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = (_selectedCategory == null && cat == 'Tümü') ||
                        _selectedCategory == cat;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primary,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? colorScheme.primary : colorScheme.outline,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat == 'Tümü' ? null : cat;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Featured Markets Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mahalle Esnafları',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExploreScreen()),
                        );
                      },
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Stores Horizontal Cards
              BlocBuilder<StoreBloc, StoreState>(
                builder: (context, state) {
                  if (state is StoreLoading) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is StoreLoaded) {
                    final filteredStores = _selectedCategory == null
                        ? state.stores
                        : state.stores
                            .where((s) => SearchFilterHelper.matchesStoreCategory(
                                  store: s,
                                  selectedCategory: _selectedCategory!,
                                ))
                            .toList();

                    if (filteredStores.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Bu kategoride market bulunamadı.'),
                      );
                    }

                    return SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredStores.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final store = filteredStores[index];
                          return _StoreCard(store: store);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 24),

              // Popular Products Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gültepe\'de Popüler Ürünler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExploreScreen()),
                        );
                      },
                      child: const Text('Keşfet'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Products Grid
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductsLoaded) {
                    final storeState = context.watch<StoreBloc>().state;
                    final stores = storeState is StoreLoaded ? storeState.stores : <StoreEntity>[];

                    final products = _selectedCategory == null
                        ? state.products
                        : state.products
                            .where((p) => SearchFilterHelper.matchesProductCategory(
                                  product: p,
                                  selectedCategory: _selectedCategory!,
                                  stores: stores,
                                ))
                            .toList();

                    if (products.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Center(
                          child: Text(
                            'Bu kategoride ürün bulunamadı.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(product: product);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreEntity store;

  const _StoreCard({required this.store});

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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProductVisualBadge(
                  imageKey: store.sampleImageKey,
                  imageUrl: store.imageUrl,
                  size: 40,
                  iconSize: 22,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: store.canAcceptOrders
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    store.canAcceptOrders ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: store.canAcceptOrders ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              store.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions_bike, size: 12, color: colorScheme.primary),
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
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite badge
            Stack(
              children: [
                Center(
                  child: ProductVisualBadge(
                    imageKey: product.sampleImageKey,
                    imageUrl: product.imageUrl,
                    size: 86,
                    iconSize: 42,
                    borderRadius: 14,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesService.favoriteProductIds,
                    builder: (context, favIds, _) {
                      final isFav = favIds.contains(product.id);
                      return InkWell(
                        onTap: () {
                          final added = FavoritesService.toggleProductFavorite(product.id);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(added
                                  ? '${product.name} favorilere eklendi.'
                                  : '${product.name} favorilerden çıkarıldı.'),
                              duration: const Duration(milliseconds: 1200),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? const Color(0xFFFF795E) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              product.storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Price and Unit
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            // Unit selection chips if product supports multiple units (e.g. kg, adet)
            if (product.allowedUnits.length > 1) ...[
              const SizedBox(height: 4),
              Row(
                children: product.allowedUnits.map((u) {
                  final isSelected = _selectedUnit == u;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedUnit = u),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            // Quantity stepper & Add to cart button
            Row(
              children: [
                // Stepper
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
                const SizedBox(width: 4),
                // Add button
                Expanded(
                  child: InkWell(
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
                      height: 30,
                      decoration: BoxDecoration(
                        color: product.isInStock
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 13, color: colorScheme.onPrimary),
                          const SizedBox(width: 2),
                          Text(
                            'Ekle',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
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
