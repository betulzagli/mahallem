import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahallem/core/utils/delivery_fee_calculator.dart';
import 'package:mahallem/core/constants/app_constants.dart';
import 'package:mahallem/core/services/theme_service.dart';
import 'package:mahallem/core/services/address_service.dart';
import 'package:mahallem/core/constants/sample_data.dart';
import 'package:mahallem/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mahallem/features/product/domain/entities/product_entity.dart';
import 'package:mahallem/features/order/domain/entities/order_entity.dart';
import 'package:mahallem/features/order/data/repositories/order_repository_impl.dart';
import 'package:mahallem/features/product/data/repositories/product_repository_impl.dart';
import 'package:mahallem/features/customer/domain/entities/address_entity.dart';
import 'package:mahallem/core/utils/search_filter_helper.dart';

void main() {
  group('1. Kesinleşen Teslimat Ücreti Kuralları', () {
    test('1 market için teslimat ücreti formülü: 20 + (1 * 5) + (1.5 * 3) = 29.5 TL', () {
      final calc = DeliveryFeeCalculator.calculate(storeIds: ['store_1']);
      expect(calc.storeCount, 1);
      expect(calc.routeKm, 1.5);
      expect(calc.baseFee, 20.0);
      expect(calc.storeFee, 5.0);
      expect(calc.distanceFee, 4.5);
      expect(calc.totalDeliveryFee, 29.5);
    });

    test('2 market için teslimat ücreti formülü: 20 + (2 * 5) + (2.8 * 3) = 38.4 TL', () {
      final calc = DeliveryFeeCalculator.calculate(storeIds: ['store_1', 'store_2']);
      expect(calc.storeCount, 2);
      expect(calc.routeKm, 2.8);
      expect(calc.baseFee, 20.0);
      expect(calc.storeFee, 10.0);
      expect(calc.distanceFee, 8.4);
      expect(calc.totalDeliveryFee, 38.4);
    });

    test('3 market için teslimat ücreti formülü: 20 + (3 * 5) + (4.2 * 3) = 47.6 TL', () {
      final calc = DeliveryFeeCalculator.calculate(storeIds: ['store_1', 'store_2', 'store_3']);
      expect(calc.storeCount, 3);
      expect(calc.routeKm, 4.2);
      expect(calc.baseFee, 20.0);
      expect(calc.storeFee, 15.0);
      expect(calc.distanceFee, 12.6);
      expect(calc.totalDeliveryFee, 47.6);
    });
  });

  group('2. En Fazla 3 Market Kuralı ve Sepet Sınırı', () {
    test('4. marketten ürün ekleme denendiğinde sepet engellemeli ve uyarı vermelidir', () async {
      final cartBloc = CartBloc();

      const p1 = ProductEntity(
        id: 'p1',
        storeId: 'store_1',
        storeName: 'Bakkal',
        name: 'Süt',
        description: '',
        category: 'Temel Gıda',
        price: 30,
        stock: 10,
        sampleImageKey: 'milk',
      );
      const p2 = ProductEntity(
        id: 'p2',
        storeId: 'store_2',
        storeName: 'Manav',
        name: 'Elma',
        description: '',
        category: 'Meyve',
        price: 40,
        stock: 10,
        sampleImageKey: 'apple',
      );
      const p3 = ProductEntity(
        id: 'p3',
        storeId: 'store_3',
        storeName: 'Kasap',
        name: 'Kıyma',
        description: '',
        category: 'Et',
        price: 200,
        stock: 10,
        sampleImageKey: 'meat',
      );
      const p4 = ProductEntity(
        id: 'p4',
        storeId: 'store_4',
        storeName: 'Fırın',
        name: 'Ekmek',
        description: '',
        category: 'Fırın',
        price: 15,
        stock: 10,
        sampleImageKey: 'bread',
      );

      // Add 3 products from 3 distinct stores
      cartBloc.add(const CartItemAdded(product: p1));
      await Future.delayed(Duration.zero);
      cartBloc.add(const CartItemAdded(product: p2));
      await Future.delayed(Duration.zero);
      cartBloc.add(const CartItemAdded(product: p3));
      await Future.delayed(Duration.zero);

      expect(cartBloc.state.cart.storeCount, 3);

      // Try adding 4th store product
      cartBloc.add(const CartItemAdded(product: p4));
      await Future.delayed(Duration.zero);

      // Should not add, storeCount must remain 3
      expect(cartBloc.state.cart.storeCount, 3);
      expect(cartBloc.state.warningMessage, isNotNull);
      expect(cartBloc.state.warningMessage, contains('en fazla 3 marketten'));
    });
  });

  group('3. Stok Yönetimi ve Sipariş İptal Kuralları', () {
    test('Sipariş verildiğinde stok ayrılır, iptal edildiğinde stok yalnızca 1 kez geri verilir', () async {
      final productRepo = ProductRepositoryImpl();
      final orderRepo = OrderRepositoryImpl(productRepository: productRepo);

      final initialProduct = await productRepo.getProductById('prod_1_1');
      expect(initialProduct, isNotNull);
      final initialStock = initialProduct!.stock;

      final testOrder = OrderEntity(
        id: 'test_order_1',
        orderNumber: 'MHL-TEST1',
        customerId: 'cust_1',
        customerName: 'Ahmet',
        customerPhone: '05551234567',
        deliveryAddress: const AddressEntity(
          id: 'addr_1',
          userId: 'cust_1',
          title: 'Ev',
          fullAddress: 'Gültepe Mah.',
        ),
        items: [
          OrderItemEntity(
            productId: 'prod_1_1',
            storeId: 'store_1',
            storeName: 'Gültepe Bakkalı',
            productName: initialProduct.name,
            unitPrice: initialProduct.price,
            quantity: 3,
            sampleImageKey: initialProduct.sampleImageKey,
          ),
        ],
        subOrders: {
          'store_1': SubOrderEntity(
            storeId: 'store_1',
            storeName: 'Gültepe Bakkalı',
            items: const [],
            subtotal: initialProduct.price * 3,
            status: SubOrderStatus.pending,
            responseDeadline: DateTime.now().add(AppConstants.storeResponseDuration),
          ),
        },
        status: OrderStatus.pendingResponse,
        productsTotal: initialProduct.price * 3,
        deliveryFee: 29.5,
        grandTotal: (initialProduct.price * 3) + 29.5,
        createdAt: DateTime.now(),
      );

      // 1. Create order -> Stock must decrease by 3
      final created = await orderRepo.createOrder(testOrder);
      final stockAfterOrder = (await productRepo.getProductById('prod_1_1'))!.stock;
      expect(stockAfterOrder, initialStock - 3);

      // 2. Cancel before prep -> Stock must be restored
      await orderRepo.cancelOrder(orderId: created.id, reason: 'Müşteri iptali');
      final stockAfterCancel = (await productRepo.getProductById('prod_1_1'))!.stock;
      expect(stockAfterCancel, initialStock);

      // 3. Repeated cancellation -> Stock must NOT increase second time (idempotent)
      try {
        await orderRepo.cancelOrder(orderId: created.id, reason: 'Tekrar iptal denemesi');
      } catch (_) {}
      final stockAfterSecondCancel = (await productRepo.getProductById('prod_1_1'))!.stock;
      expect(stockAfterSecondCancel, initialStock);
    });

    test('Hazırlık başladıktan sonra müşteri iptali engellenmelidir', () async {
      final productRepo = ProductRepositoryImpl();
      final orderRepo = OrderRepositoryImpl(productRepository: productRepo);

      final p = (await productRepo.getProductById('prod_1_2'))!;
      final order = OrderEntity(
        id: 'test_order_prep',
        orderNumber: 'MHL-PREP1',
        customerId: 'cust_1',
        customerName: 'Ahmet',
        customerPhone: '05551234567',
        deliveryAddress: const AddressEntity(id: 'a', userId: 'c', title: 'Ev', fullAddress: 'Gültepe'),
        items: [
          OrderItemEntity(
            productId: p.id,
            storeId: 'store_1',
            storeName: 'Gültepe Bakkalı',
            productName: p.name,
            unitPrice: p.price,
            quantity: 1,
            sampleImageKey: p.sampleImageKey,
          ),
        ],
        subOrders: {
          'store_1': SubOrderEntity(
            storeId: 'store_1',
            storeName: 'Gültepe Bakkalı',
            items: const [],
            subtotal: p.price,
            status: SubOrderStatus.pending,
            responseDeadline: DateTime.now().add(AppConstants.storeResponseDuration),
          ),
        },
        status: OrderStatus.pendingResponse,
        productsTotal: p.price,
        deliveryFee: 29.5,
        grandTotal: p.price + 29.5,
        createdAt: DateTime.now(),
      );

      await orderRepo.createOrder(order);

      // Store accepts order -> transitions to preparing
      await orderRepo.updateSubOrderStatus(
        orderId: order.id,
        storeId: 'store_1',
        status: SubOrderStatus.accepted,
      );

      // Attempt cancellation after preparation started -> Should throw exception
      expect(
        () async => await orderRepo.cancelOrder(orderId: order.id, reason: 'İptal'),
        throwsException,
      );
    });
  });

  group('4. Kurye Simülasyonu Zaman Çizelgesi Hesabı', () {
    test('Başlangıç zamanına göre kurye aşamaları deterministik hesaplanmalıdır', () {
      final start = DateTime.now().subtract(const Duration(seconds: 20)); // 20s ago

      final order = OrderEntity(
        id: 'courier_test',
        orderNumber: 'MHL-C1',
        customerId: 'cust_1',
        customerName: 'Ahmet',
        customerPhone: '0555',
        deliveryAddress: const AddressEntity(id: 'a', userId: 'c', title: 'Ev', fullAddress: 'Gültepe'),
        items: const [],
        subOrders: const {},
        status: OrderStatus.courierAssigned,
        productsTotal: 50,
        deliveryFee: 29.5,
        grandTotal: 79.5,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        courierStartTimestamp: start,
      );

      // 20s elapsed: Stage 1 (0-15s) is passed, so it must be courierCollecting (15-45s)
      expect(order.computedStatus, OrderStatus.courierCollecting);
    });
  });

  group('5. Kullanıcı Talepleri ve İyileştirmeler Doğrulama Testleri', () {
    test('Aynı üründen 4 adet eklendiğinde sepet rozet sayısı ürün çeşidine (1) eşit olmalıdır', () async {
      final cartBloc = CartBloc();
      const p = ProductEntity(
        id: 'domates',
        storeId: 'store_1',
        storeName: 'Manav',
        name: 'Domates',
        description: 'Taze',
        category: 'Sebze',
        price: 38.0,
        stock: 50,
        sampleImageKey: 'tomato',
        unit: 'kg',
        allowedUnits: ['kg', 'adet'],
      );

      // Add 4 units of same product
      cartBloc.add(const CartItemAdded(product: p, quantity: 4, unit: 'kg'));
      await Future.delayed(const Duration(milliseconds: 20));

      // Total quantity is 4, but unique product varieties count must be 1
      expect(cartBloc.state.cart.totalItemCount, 4);
      expect(cartBloc.state.cart.uniqueItemCount, 1);
      expect(cartBloc.state.cart.items.length, 1);
    });

    test('Ürünlerin kg ile adet fiyatları farklı olmalı ve seçilen birime göre fiyat uygulanmalıdır', () {
      final tomato = SampleData.products.firstWhere((p) => p.id == 'prod_2_1');
      expect(tomato.allowedUnits.contains('kg'), isTrue);
      expect(tomato.allowedUnits.contains('adet'), isTrue);

      final kgPrice = tomato.priceForUnit('kg');
      final adetPrice = tomato.priceForUnit('adet');

      expect(kgPrice, 38.0);
      expect(adetPrice, 6.50);
      expect(kgPrice, isNot(equals(adetPrice))); // Must be different!
    });

    test('Açık ve koyu tema geçişi ThemeService üzerinden anında değiştirilebilmelidir', () {
      ThemeService.setTheme(ThemeMode.light);
      expect(ThemeService.isDarkMode, isFalse);

      ThemeService.toggleTheme();
      expect(ThemeService.isDarkMode, isTrue);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.dark);

      ThemeService.toggleTheme();
      expect(ThemeService.isDarkMode, isFalse);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.light);
    });

    test('Varsayılan adres değiştirme işlemi tek bir adresi varsayılan yapmalı ve diğerlerini güncellemelidir', () {
      final addresses = AddressService.addressesNotifier.value;
      expect(addresses.length, greaterThanOrEqualTo(2));

      final firstId = addresses[0].id;
      final secondId = addresses[1].id;

      // Set second address as default
      AddressService.setDefaultAddress(secondId);
      final updated = AddressService.addressesNotifier.value;

      expect(updated.firstWhere((a) => a.id == secondId).isDefault, isTrue);
      expect(updated.firstWhere((a) => a.id == firstId).isDefault, isFalse);
      expect(AddressService.defaultAddress.id, secondId);

      // Restore first address
      AddressService.setDefaultAddress(firstId);
      expect(AddressService.defaultAddress.id, firstId);
    });

    test('Sipariş iptal edildiğinde isCompleted true olmalı ve aktif sipariş filtresinden çıkarılmalıdır', () async {
      final productRepo = ProductRepositoryImpl();
      final orderRepo = OrderRepositoryImpl(productRepository: productRepo);

      final initialOrder = OrderEntity(
        id: 'test_order_cancel',
        orderNumber: 'MHL-TEST1',
        customerId: SampleData.sampleCustomer.id,
        customerName: 'Ahmet',
        customerPhone: '0555',
        deliveryAddress: const AddressEntity(id: 'a1', userId: 'u1', title: 'Ev', fullAddress: 'Gültepe'),
        items: const [],
        subOrders: {
          'store_1': SubOrderEntity(
            storeId: 'store_1',
            storeName: 'Gültepe Bakkalı',
            items: const [],
            subtotal: 50.0,
            status: SubOrderStatus.pending,
            responseDeadline: DateTime.now().add(const Duration(minutes: 10)),
          ),
        },
        status: OrderStatus.pendingResponse,
        productsTotal: 50.0,
        deliveryFee: 29.5,
        grandTotal: 79.5,
        createdAt: DateTime.now(),
      );

      final order = await orderRepo.createOrder(initialOrder);

      // Initially active
      expect(order.isCompleted, isFalse);

      // Cancel the order
      await orderRepo.cancelOrder(orderId: order.id, reason: 'Test iptal');
      final orders = await orderRepo.getCustomerOrders(SampleData.sampleCustomer.id);
      final cancelled = orders.firstWhere((o) => o.id == order.id);

      expect(cancelled.status, OrderStatus.cancelled);
      expect(cancelled.isCompleted, isTrue); // Must be marked completed so it drops off active list!
    });

    test('İşletmeye yeni ürün ekleme ve güncelleme işlemi mağaza ürün listesine başarıyla yansımalıdır', () async {
      final productRepo = ProductRepositoryImpl();
      final initialStore1Products = await productRepo.getProductsByStore('store_1');
      final initialCount = initialStore1Products.length;

      final newProduct = ProductEntity(
        id: 'test_new_prod_1',
        storeId: 'store_1',
        storeName: 'Gültepe Bakkalı',
        name: 'Taze Köy Ekmeği',
        description: 'Taş fırında pişmiş ekmek',
        price: 25.0,
        stock: 30,
        category: 'Ekmek & Fırın',
        sampleImageKey: 'bread',
        unit: 'adet',
        unitPrices: const {'adet': 25.0},
        isActive: true,
      );

      await productRepo.addProduct(newProduct);
      final updatedProducts = await productRepo.getProductsByStore('store_1');

      expect(updatedProducts.length, initialCount + 1);
      final added = updatedProducts.firstWhere((p) => p.id == 'test_new_prod_1');
      expect(added.name, 'Taze Köy Ekmeği');
      expect(added.price, 25.0);
      expect(added.stock, 30);
    });

    test('Varsayılan adres değiştiğinde AddressService dinleyicilerine anında bildirim gitmelidir', () {
      bool notificationReceived = false;
      void listener() {
        notificationReceived = true;
      }

      AddressService.addressesNotifier.addListener(listener);

      final addresses = AddressService.addressesNotifier.value;
      if (addresses.length > 1) {
        final targetId = addresses.last.id;
        AddressService.setDefaultAddress(targetId);

        expect(notificationReceived, isTrue);
        expect(AddressService.defaultAddress.id, targetId);
      }

      AddressService.addressesNotifier.removeListener(listener);
    });

    test('Arama filtresi Türkçe karakter duyarsız ve küçük/büyük harf uyumlu çalışmalıdır', () {
      expect(SearchFilterHelper.matchesQuery('Salkım Domates', 'salkim'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Dana Kıyma', 'kiyma'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Rize Çayı', 'cayi'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Taş Fırın Ekmeği', 'tas firin'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Tam Yağlı Süt', 'sut'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Gültepe Bakkalı', 'gultepe'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Özlem Manavı', 'ozlem'), isTrue);
      expect(SearchFilterHelper.matchesQuery('Salkım Domates', 'muz'), isFalse);
    });

    test('Kategori filtresi esnaf ve ürün kategorilerini semantik olarak doğru eşleştirmelidir', () {
      final stores = SampleData.stores;
      final products = SampleData.products;

      // Manav category should match tomato, cucumber, apple, banana
      final manavProducts = products.where(
        (p) => SearchFilterHelper.matchesProductCategory(
          product: p,
          selectedCategory: 'Manav',
          stores: stores,
        ),
      ).toList();

      expect(manavProducts.any((p) => p.name.contains('Domates')), isTrue);
      expect(manavProducts.any((p) => p.name.contains('Elma')), isTrue);
      expect(manavProducts.any((p) => p.name.contains('Kıyma')), isFalse);

      // Kasap category should match minced meat, meat
      final kasapProducts = products.where(
        (p) => SearchFilterHelper.matchesProductCategory(
          product: p,
          selectedCategory: 'Kasap',
          stores: stores,
        ),
      ).toList();

      expect(kasapProducts.any((p) => p.name.contains('Kıyma')), isTrue);
      expect(kasapProducts.any((p) => p.name.contains('Domates')), isFalse);

      // Store category matching
      final manavStore = stores.firstWhere((s) => s.category == 'Manav');
      expect(SearchFilterHelper.matchesStoreCategory(store: manavStore, selectedCategory: 'Manav'), isTrue);
      expect(SearchFilterHelper.matchesStoreCategory(store: manavStore, selectedCategory: 'Kasap'), isFalse);
    });
  });

  group('10. Yeni Ürün Fotoğrafı Ekleme ve Güncelleme', () {
    test('Yeni ürün fotoğraf URL\'si ile kaydedilmeli ve repository üzerinden okunabilmelidir', () async {
      final repo = ProductRepositoryImpl();
      const testImageUrl = 'https://images.unsplash.com/photo-1550583724-b2692b85b150';

      final newProduct = ProductEntity(
        id: 'prod_test_photo',
        storeId: 'store_1',
        storeName: 'Gültepe Bakkalı',
        name: 'Doğal Köy Sütü',
        description: 'Taze günlük süt',
        category: 'Süt & Kahvaltılık',
        price: 45.0,
        stock: 15,
        sampleImageKey: 'milk',
        imageUrl: testImageUrl,
      );

      await repo.addProduct(newProduct);

      final retrieved = await repo.getProductById('prod_test_photo');
      expect(retrieved, isNotNull);
      expect(retrieved!.imageUrl, testImageUrl);
      expect(retrieved.sampleImageKey, 'milk');

      // Update photo
      const updatedImageUrl = 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d';
      final updatedProduct = retrieved.copyWith(imageUrl: updatedImageUrl);
      await repo.updateProduct(updatedProduct);

      final updatedRetrieved = await repo.getProductById('prod_test_photo');
      expect(updatedRetrieved!.imageUrl, updatedImageUrl);

      // Clear photo
      final clearedProduct = updatedRetrieved.copyWith(clearImageUrl: true);
      expect(clearedProduct.imageUrl, isNull);
      await repo.updateProduct(clearedProduct);

      final clearedRetrieved = await repo.getProductById('prod_test_photo');
      expect(clearedRetrieved!.imageUrl, isNull);
    });
  });
}
