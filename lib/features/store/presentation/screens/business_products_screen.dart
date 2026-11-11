import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/store_bloc.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/add_edit_product_dialog.dart';

/// Esnafın ürün ve stok kataloğu ekranı: Ürün arama, stok takibi, aktif/pasif durumu,
/// ürün silme, düzenleme ve fotoğrafı ile yeni ürün ekleme özelliklerini sunar.
class BusinessProductsScreen extends StatefulWidget {
  const BusinessProductsScreen({super.key});

  @override
  State<BusinessProductsScreen> createState() => _BusinessProductsScreenState();
}

class _BusinessProductsScreenState extends State<BusinessProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final storeId = (authState is Authenticated && authState.user.storeId != null)
        ? authState.user.storeId!
        : 'store_1';
    context.read<ProductBloc>().add(ProductsLoadRequested(storeId: storeId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.read<AuthBloc>().state;
    final storeId = (authState is Authenticated && authState.user.storeId != null)
        ? authState.user.storeId!
        : 'store_1';

    final storeState = context.watch<StoreBloc>().state;
    final stores = storeState is StoreLoaded ? storeState.stores : SampleData.stores;
    final currentStore = stores.firstWhere((s) => s.id == storeId, orElse: () => stores.first);
    final storeName = currentStore.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Ürün Ekle',
            onPressed: () => showAddEditProductDialog(
              context: context,
              storeId: storeId,
              storeName: storeName,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürünlerinizde arayın...',
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
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductsLoaded) {
                  final list = state.products.where((p) {
                    return _searchQuery.isEmpty ||
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.category.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (list.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.inventory_2_outlined,
                      title: 'Ürün Bulunamadı',
                      message: 'Yeni ürün ekleyerek mahalle sakinlerinin erişimine açabilirsiniz.',
                      actionText: 'Ürün Ekle',
                      onAction: () => showAddEditProductDialog(
                        context: context,
                        storeId: storeId,
                        storeName: storeName,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = list[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outline, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            ProductVisualBadge(
                              imageKey: product.sampleImageKey,
                              imageUrl: product.imageUrl,
                              size: 50,
                              iconSize: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.format(product.price)} • Stok: ${product.stock} adet',
                                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                  ),
                                  Text(
                                    product.isActive ? 'Satışta Açık' : 'Pasif (Satış Dışı)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product.isActive ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => showAddEditProductDialog(
                                context: context,
                                existingProduct: product,
                                storeId: storeId,
                                storeName: storeName,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Ürünü Sil'),
                                    content: Text('${product.name} silinecek. Emin misiniz?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Vazgeç'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () {
                                          context.read<ProductBloc>().add(
                                                ProductDeleteRequested(
                                                  productId: product.id,
                                                  storeId: storeId,
                                                ),
                                              );
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Sil', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditProductDialog(
          context: context,
          storeId: storeId,
          storeName: storeName,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ürün'),
      ),
    );
  }
}
