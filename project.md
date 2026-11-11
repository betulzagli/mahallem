# Mahallem - Dijital Pazar: Kapsamlı Proje ve Mimari Dokümantasyonu

Bu belge, **Mahallem - Dijital Pazar** uygulamasının mimari yapısını, kullanılan teknolojileri, bu teknolojilerin tercih edilme nedenlerini, tüm klasör ve dosyaların sorumluluklarını, içerisindeki sınıf/fonksiyon/metot yapılarını ve kod içi açıklamalarını eksiksiz olarak detaylandıran ana teknik referans dokümanıdır.

---

## 1. Proje Genel Bakışı ve Temel Vizyon

**Mahallem**, geleneksel mahalle esnafı (bakkal, manav, kasap, fırın vb.) ile mahalle sakinlerini tek bir dijital platformda buluşturan yeni nesil bir yerel pazar yeridir.

### Temel İşleyiş Modeli:
1. **Tek Sepette Çoklu Market**: Müşteri aynı sipariş içerisinde mahallesindeki farklı esnaflardan (örneğin bakkaldan süt, manavdan domates, kasaptan kıyma) ürün ekleyebilir.
2. **Sepet Sınırı**: Operasyonel sürdürülebilirlik ve teslimat verimliliği amacıyla sipariş başına en fazla **3 farklı market** kısıtı uygulanır.
3. **Alt Sipariş Dağıtımı (Sub-Orders)**: Ana sipariş onaylandığında, sepet ilgili işletmelere kendi ürünlerini içeren alt siparişler olarak anında bölünür.
4. **Zaman Damgalı Süreç Yönetimi**:
   - Marketlerin siparişi kabul/ret etmesi için **10 dakika** yanıt süresi bulunur.
   - Bir marketin reddetmesi durumunda, müşteriye kalan marketlerle devam etmesi veya siparişi iptal etmesi için **5 dakika** karar süresi tanınır.
5. **Tek Kurye ve Birleşik Teslimat**: Tüm onaylanan dükkanlar ürünleri hazırladığında tek bir kurye simülasyonu başlar; kurye sırayla esnafları dolaşarak siparişleri toplar ve müşteriye tek teslimatta ulaştırır.
6. **Şeffaf ve Dinamik Teslimat Ücreti**: Formüle dayalı teslimat maliyeti:  
   $$\text{Teslimat Ücreti} = 20\text{ TL (Taban)} + (\text{Market Sayısı} \times 5\text{ TL}) + (\text{Rota Mesafesi (km)} \times 3\text{ TL})$$

---

## 2. Mimari Özellikler ve Tasarım Prensipleri

Proje, yazılım mühendisliğinde yüksek ölçeklenebilirlik, sürdürülebilirlik ve test edilebilirlik sağlayan **Clean Architecture (Temiz Mimari)** ve **Feature-First (Özellik Odaklı)** yaklaşımları temel alınarak geliştirilmiştir.

```mermaid
flowchart TD
    subgraph Presentation_Layer [Presentation Katmanı (UI & State)]
        UI[Screens & Widgets]
        BLoC[BLoC / State Management]
    end

    subgraph Domain_Layer [Domain Katmanı (İş Kuralları - Saf Dart)]
        Entities[Entities (Varlıklar)]
        RepoInterfaces[Repository Interfaces (Arayüzler)]
    end

    subgraph Data_Layer [Data Katmanı (Veri Kaynakları & Uygulama)]
        RepoImpl[Repository Implementations]
        Firebase[(Firebase / Firestore / Auth)]
        Memory[(In-Memory / Sample Data)]
    end

    UI --> BLoC
    BLoC --> RepoInterfaces
    RepoImpl -.->|implements| RepoInterfaces
    RepoImpl --> Firebase
    RepoImpl --> Memory
    BLoC --> Entities
```

### 2.1. Neden Clean Architecture Tercih Edildi?
- **Katmanların Bağımsızlığı**: UI (Flutter widget'ları), iş mantığından (Domain) tamamen ayrılmıştır. Veri kaynakları (Firestore, bellek) değişse bile Domain katmanı bundan etkilenmez.
- **Dependency Inversion Principle (DIP)**: Yüksek seviyeli modüller (BLoC), düşük seviyeli modüllere (Firestore) doğrudan bağımlı değildir; her ikisi de Domain katmanındaki soyut arayüzlere (`Repository`) bağımlıdır.
- **Test Edilebilirlik**: Harici bağımlılıklar soyutlandığı için tüm iş kuralları (stok düşümü, teslimat ücreti, zaman aşımları) Firebase veya sunucu ayağa kaldırılmadan saf birim testleri ile (%100 deterministik) test edilebilir.
- **Çift Çalışma Modu (Graceful Fallback)**: Firebase yapılandırması mevcut olmadığında veya kotalar dolduğunda sistem çökmek yerine `isFirebaseReady: false` bayrağı ile bellek içi (`In-Memory`) depoya geçiş yapar.

### 2.2. Neden Feature-First Klasör Yapısı?
Geleneksel katman bazlı klasörleme yerine her bir özellik (`auth`, `cart`, `customer`, `order`, `product`, `store`, `navigation`) kendi `domain`, `data` ve `presentation` katmanlarını kendi içinde barındırır:
- Bir özellik üzerinde çalışan geliştirici sadece o klasörde odaklanır.
- Kodun bulunabilirliği, okunabilirliği ve modülerliği maksimize edilir.
- Ortak bileşenler, temalar ve genel yardımcı sınıflar ise `core/` klasörü altında merkezileştirilir.

### 2.3. Neden BLoC (Business Logic Component)?
- **Tek Yönlü Veri Akışı (Unidirectional Data Flow)**: UI yalnızca `Event` gönderir; BLoC iş mantığını işletip yeni `State` üretir; UI sadece bu durumu dinleyerek yeniden çizilir.
- **Öngörülebilirlik**: Her durum geçişi açıkça tanımlanmış sınıflardan oluşur (`Loading`, `Loaded`, `Failure`).
- **Gereksiz Render'ların Önlenmesi**: `Equatable` entegrasyonu sayesinde sadece nesne değerleri değiştiğinde widget'lar rebuild edilir.

---

## 3. Kullanılan Teknolojiler ve Tercih Nedenleri

| Teknoloji / Kütüphane | Sürüm | Kullanım Amacı | Tercih Nedeni |
| :--- | :--- | :--- | :--- |
| **Flutter & Dart SDK** | `^3.13.7` | Çapraz Platform İstemci Geliştirme | Tek bir kod tabanıyla hem Android hem iOS platformlarına yüksek performanslı (60/120 FPS), yerel derlenen kod üretir. |
| **flutter_bloc** | `^9.1.1` | Durum Yönetimi (State Management) | İş mantığı ile kullanıcı arayüzünü tamamen ayrıştırır; reaktif `Stream` mimarisiyle öngörülebilir durum takibi sağlar. |
| **equatable** | `^3.0.0` | Değer Eşitliği (Value Equality) | Dart nesnelerinin bellek referansı yerine içerik değerlerine göre karşılaştırılmasını sağlar; gereksiz widget yeniden çizimlerini engeller. |
| **firebase_core** | `^5.1.0` | Firebase Kök Servisleri | Bulut backend servislerinin Flutter ile resmi entegrasyonunu sağlar. |
| **firebase_auth** | `^7.0.1` | Kullanıcı Kimlik Doğrulama | Güvenli e-posta/şifre kaydı, giriş ve şifre sıfırlama işlemlerini sunucusuz yönetir. |
| **cloud_firestore** | `^7.1.0` | Gerçek Zamanlı NoSQL Veritabanı | Müşteri ve işletme panelleri arasında sipariş, ürün ve mağaza verilerini anlık stream ile senkronize eder. |
| **intl** | `^0.20.3` | Uluslararasılaştırma & Formatlama | Para birimi (TL), tarih ve sayı formatlarının Türkçe yerel ayarlara uygun görüntülenmesini sağlar. |
| **flutter_test** | SDK | Otomasyon ve Test | İş kurallarını, BLoC durumlarını ve UI widget davranışlarını otomasyon testleriyle doğrular. |

---

## 4. Klasör Yapısı ve Dosya Amaçları

```text
lib/
├── main.dart                                    # Uygulama giriş noktası ve servis enjeksiyonu
├── core/                                        # Ortak altyapı, temalar, yardımcılar ve servisler
│   ├── constants/
│   │   ├── app_constants.dart                   # Sabitler, kural süreleri, rota formülleri
│   │   └── sample_data.dart                     # Başlangıç mağaza, ürün, kullanıcı ve adres verileri
│   ├── services/
│   │   ├── address_service.dart                 # Reaktif adres yönetimi ve varsayılan adres yayını
│   │   ├── favorites_service.dart               # Favori işletme ve ürünlerin reaktif yönetimi
│   │   └── theme_service.dart                   # Açık/Koyu tema dinleyicisi ve buton kontrolü
│   ├── theme/
│   │   ├── app_colors.dart                      # WCAG AA kontrastlı renk tokenları
│   │   ├── app_theme.dart                       # Tema sağlayıcı sınıf
│   │   ├── light_theme.dart                     # Material 3 Açık Tema tanımı
│   │   └── dark_theme.dart                      # Material 3 Koyu Tema tanımı
│   ├── utils/
│   │   ├── currency_formatter.dart              # Standart TL para formatlayıcı
│   │   ├── delivery_fee_calculator.dart         # Teslimat ücreti algoritması
│   │   ├── search_filter_helper.dart            # Türkçe karakter duyarsız arama & semantik kategori
│   │   └── validators.dart                      # Form doğrulama fonksiyonları
│   └── widgets/
│       ├── app_button.dart                      # Standart 48px erişilebilir buton
│       ├── app_text_field.dart                  # Material 3 standart metin girdi alanı
│       ├── demo_mode_badge.dart                 # Demo rozeti
│       ├── empty_state_view.dart                # Boş durum görünümü
│       ├── error_state_view.dart                # Hata ve yeniden dene görünümü
│       └── product_image_placeholder.dart       # Ağ görseli ve tematik ikon çözümleyici
└── features/                                    # Özellik bazlı modüller
    ├── auth/                                    # Kimlik doğrulama modülü
    ├── cart/                                    # Sepet ve çoklu market denetimi modülü
    ├── customer/                                # Müşteri vitrini, ana sayfa, keşfet, profili
    ├── navigation/                              # Müşteri ve Esnaf alt gezinme kabukları
    ├── order/                                   # Sipariş oluşturma, takip, sayaçlar ve kurye simülasyonu
    ├── product/                                 # Ürün kataloğu ve stok yönetimi
    └── store/                                   # Esnaf paneli, sipariş onaylama, çalışma saatleri
```

---

## 5. Dosyaların Detaylı Görevleri, Sınıf ve Metot Açıklamaları

Aşağıda projedeki tüm dosyalar, içerdikleri sınıflar, fonksiyonlar ve kod içine eklenen açıklamalar detaylı olarak belgelenmiştir:

### 5.1. Kök Dizin & Çekirdek Modüller (`lib/` & `lib/core/`)

#### `lib/main.dart`
- **Görevi**: Uygulamanın giriş noktası (entry point). Firebase başlatmasını güvenli `try-catch` bloğunda dener; yapılandırma eksikse çökmek yerine demo bellek içi depolara geri düşer. `MultiRepositoryProvider` ve `MultiBlocProvider` ile tüm katmanları widget ağacına enjekte eder.
- **Sınıflar & Fonksiyonlar**:
  - `void main() async`: Flutter motorunu başlatır, Firebase'i dener ve bağımlılık enjeksiyonunu kurar.
  - `class MahallemApp extends StatelessWidget`: Kök uygulama bileşeni. `ThemeService.themeModeNotifier` dinleyerek temayı dinamik günceller.
  - `class AppRootRouter extends StatelessWidget`: Kullanıcı oturumuna göre yönlendirme yapar (`Authenticated` -> Rol esnafsa `BusinessNavigationShell`, müşteri ise `CustomerNavigationShell`, oturum kapalıysa `LoginScreen`).

#### `lib/core/constants/app_constants.dart`
- **Görevi**: Uygulama çapındaki kesinleşmiş iş kurallarını, süreleri ve ücret parametrelerini saklar.
- **İçerik**:
  - `defaultNeighborhood`: Gültepe Mahallesi (tek örnek mahalle kuralı).
  - `maxMarketsPerOrder`: 3 (sipariş başına maksimum market sınırı).
  - `storeResponseDuration`: 10 dakika (market yanıt süresi).
  - `customerDecisionDuration`: 5 dakika (ret sonrası müşteri karar süresi).
  - `baseDeliveryFee`, `perMarketFee`, `perKilometerFee`: Teslimat ücreti çarpanları ($20.0, 5.0, 3.0$).
  - `getRouteKmForStores(List<String> storeIds)`: Market sayısına göre deterministik rota mesafesi döner ($1 \to 1.5\text{ km}, 2 \to 2.8\text{ km}, 3 \to 4.2\text{ km}$).

#### `lib/core/constants/sample_data.dart`
- **Görevi**: Firebase çevrimdışıyken veya ilk kurulumda kullanılan zengin ve tutarlı örnek verileri tutar.
- **İçerik**:
  - `sampleCustomer`, `sampleBusinessUser`: Giriş yapılabilir demo kullanıcılar.
  - `stores`: 4 adet mahalle esnafı (Gültepe Bakkalı, Can Kardeşler Manav, Özlem Kasabı, Bereket Fırını).
  - `products`: Yüksek çözünürlüklü Unsplash görsellerine, kg ve adet bazlı birim fiyatlarına sahip ürünler.
  - `sampleAddresses`: Müşteri örnek adresleri.

#### `lib/core/services/address_service.dart`
- **Görevi**: Kullanıcı adreslerini ve varsayılan adres seçimini merkezi reaktif `ValueNotifier` ile yönetir.
- **Metotlar**:
  - `defaultAddress`: Aktif varsayılan adresi döner.
  - `setDefaultAddress(String addressId)`: Seçilen adresi varsayılan yapar, diğerlerini `false` yapar ve dinleyen tüm ekranlara (Ana sayfa, Sepet) anında bildirir.
  - `addAddress(AddressEntity address)`: Yeni adres ekler.
  - `deleteAddress(String addressId)`: Adresi siler; silinen adres varsayılansa ilk kalanı varsayılan yapar.

#### `lib/core/services/favorites_service.dart`
- **Görevi**: Favori mağaza ve ürün kimliklerini reaktif `ValueNotifier<Set<String>>` ile tutar.
- **Metotlar**:
  - `toggleStoreFavorite(String storeId)`, `toggleProductFavorite(String productId)`: Favori durumunu tersine çevirir.
  - `removeStoreFavorite(storeId)`, `removeProductFavorite(productId)`: Doğrudan favoriden çıkarır.

#### `lib/core/services/theme_service.dart`
- **Görevi**: Açık ve koyu tema durumunu yönetir.
- **Sınıflar & Metotlar**:
  - `ThemeService`: `themeModeNotifier` ile `ThemeMode.light` ve `ThemeMode.dark` geçişlerini sağlar.
  - `ThemeToggleButton`: AppBar üzerine yerleştirilebilen dinamik güneş/ay ikonu butonu.

#### `lib/core/theme/app_colors.dart`
- **Görevi**: WCAG AA kontrast standartlarını ($> 4.5:1$) karşılayan merkezi renk tokenlarını barındırır.
- **Önemli Renkler**:
  - `mahallemBlue` (`#3158C9`), `mahallemCoral` (`#FF795E`), `lightBackground` (`#F7F8FC`), `lightOnSurfaceVariant` (`#4A5568`), `lightError` (`#C02626`).

#### `lib/core/theme/app_theme.dart`, `light_theme.dart`, `dark_theme.dart`
- **Görevi**: Material 3 spesifikasyonlarına uygun `ThemeData` yapılarını oluşturur. Buton minimum boyutlarını $64 \times 48\text{ px}$ olarak belirleyerek mobil dokunmatik erişilebilirliğini garanti eder.

#### `lib/core/utils/delivery_fee_calculator.dart`
- **Görevi**: Kesinleşen teslimat ücreti formülünü çalıştırır.
- **Sınıf**: `DeliveryFeeCalculator.calculate({required List<String> storeIds, double? customRouteKm})`
  - Market sayısı 0 ise $0\text{ TL}$ döner.
  - Taban ($20\text{ TL}$), market ücreti ($\text{sayı} \times 5\text{ TL}$) ve mesafe ücretini ($\text{km} \times 3\text{ TL}$) kuruş hassasiyetiyle toplayıp `DeliveryFeeCalculation` nesnesi döner.

#### `lib/core/utils/currency_formatter.dart`
- **Görevi**: Fiyatları iki ondalık basamak ve TL ibaresiyle biçimlendirir (`format(double amount) -> "35.50 TL"`).

#### `lib/core/utils/search_filter_helper.dart`
- **Görevi**: Arama ve filtrelemede Türkçe karakter normalizasyonu ve semantik kategori eşleştirmesi yapar.
- **Metotlar**:
  - `normalize(String text)`: Türkçe karakterleri (`ç, ğ, ı, ö, ş, ü`) İngilizce karşılıklarına ve küçük harfe dönüştürür.
  - `matchesQuery(String text, String query)`: Metin içinde arama sorgusunu arar.
  - `matchesProductCategory(...)`: Ürünün kategorisi ile seçilen filtreyi (Manav $\leftrightarrow$ Sebze & Meyve, Kasap $\leftrightarrow$ Kırmızı Et, Fırın $\leftrightarrow$ Ekmek vb.) semantik olarak bağlar.
  - `matchesStoreCategory(...)`: Dükkan kategorisi ile filtreyi eşleştirir.

#### `lib/core/utils/validators.dart`
- **Görevi**: Form alanlarındaki girdileri doğrular (`validateEmail`, `validatePassword`, `validateRequired`, `validatePhone`, `validatePositiveNumber`, `validateStock`).

#### `lib/core/widgets/product_image_placeholder.dart`
- **Görevi**: Ürünlerin görsel sunumunu yönetir.
- **Sınıflar**:
  - `SampleVisualResolver`: Kategoriye göre Material ikonu ve renk tonunu seçer.
  - `ProductVisualBadge`: Verilen `imageUrl` varsa ağ üzerinden `Image.network` ile yükler; yüklenemezse veya URL boşsa tematik renkli ikon fallback'ine döner.

#### `lib/core/widgets/app_button.dart` & `app_text_field.dart`
- **Görevi**: Tüm uygulamada tutarlı Material 3 buton (`AppButtonType`: primary, secondary, promotional, outlined, text) ve form alanlarını (`AppTextField`) sağlar.

---

### 5.2. Kimlik Doğrulama Modülü (`lib/features/auth/`)

- **`domain/entities/user_entity.dart`**: `UserRole` (`customer`, `business`) ve kullanıcı bilgilerini tutan değişmez (immutable) varlık.
- **`domain/repositories/auth_repository.dart`**: Giriş (`signIn`), müşteri kaydı (`registerCustomer`), esnaf kaydı (`registerBusiness`), şifre sıfırlama (`sendPasswordResetEmail`), çıkış (`signOut`) ve hesap silme (`deleteAccount`) metotlarının soyut arayüzü.
- **`data/repositories/auth_repository_impl.dart`**: Firebase Auth ve Firestore koleksiyonu üzerinden kimlik işlemlerini yürütür; Firebase kapalıyken bellek içi demo kullanıcıları yönetir.
- **`presentation/bloc/auth_bloc.dart`**: Kullanıcı oturum olaylarını (`AuthSignInRequested`, `AuthRegisterCustomerRequested`, `AuthRegisterBusinessRequested`, `AuthPasswordResetRequested`, `AuthSignOutRequested`, `AuthDeleteAccountRequested`) dinler ve `Authenticated`, `Unauthenticated`, `AuthFailure` durumlarını yönetir.
- **`presentation/screens/login_screen.dart`**: E-posta ve şifre ile giriş formu; müşteri/esnaf hızlı geçişi sunar.
- **`presentation/screens/register_screen.dart`**: Müşteri kayıt formu.
- **`presentation/screens/business_register_screen.dart`**: Dükkan adı, adresi ve kategorisi ile esnaf kayıt formu.
- **`presentation/screens/forgot_password_screen.dart`**: Şifre sıfırlama e-postası gönderme ekranı; ekranı kitlemeden SnackBar ile bilgilendirir.

---

### 5.3. Sepet Modülü (`lib/features/cart/`)

- **`domain/entities/cart_entity.dart`**:
  - `CartItemEntity`: Ürün, adet, seçili birim (`kg` veya `adet`) ve birim fiyatı tutar. `subtotal` hesaplar.
  - `CartEntity`:
    - `canAddProductFromStore(String storeId)`: Sepetteki mevcut işletme sayısı 3'e ulaştığında farklı bir 4. işletmeden ürün eklenmesini engeller.
    - `uniqueItemCount`: Sepetteki farklı ürün çeşidi sayısını verir (sepet ikonu üzerindeki rozette adetlerin toplamı değil, çeşit sayısı gösterilir).
    - `itemsGroupedByStore`: Ürünleri işletme kimliğine göre gruplayarak alt siparişlerin altyapısını kurar.
    - `deliveryFeeCalculation`: Çoklu market sayısına ve rota kilometresine göre teslimat ücretini hesaplar.
- **`presentation/bloc/cart_bloc.dart`**:
  - Olaylar: `CartItemAdded`, `CartItemRemoved`, `CartItemQuantityChanged`, `CartCleared`.
  - 4. marketten ürün ekleme denendiğinde `warningMessage: 'En fazla 3 farklı marketten ürün ekleyebilirsiniz.'` durumunu fırlatır.
- **`presentation/screens/cart_screen.dart`**: Ürünleri işletme bazında gruplanmış kartlar olarak listeler; birim fiyatları, ara toplamı, dinamik teslimat ücretini ve genel toplamı gösterir; siparişi tamamlama butonunu barındırır.

---

### 5.4. Müşteri Modülü (`lib/features/customer/`)

- **`domain/entities/address_entity.dart`**: Teslimat adresini (`id`, `title`, `fullAddress`, `deliveryNote`, `isDefault`) temsil eder.
- **`domain/repositories/address_repository.dart`** & **`data/repositories/address_repository_impl.dart`**: Adres CRUD işlemlerini tanımlar ve uygular.
- **`presentation/screens/home_screen.dart`**: Müşteri ana sayfası. Üstte dinamik adres seçici, kategori chipleri, açık dükkanlar yatay listesi ve mahalle ürünleri listesi içerir.
- **`presentation/screens/explore_screen.dart`**: Arama çubuğu, kategori filtreleri ve ürünler/dükkanlar sekmeleri ile anlık arama motoru sunar.
- **`presentation/screens/market_detail_screen.dart`**: Seçilen esnafın çalışma saatleri, açık/kapalı/mola durumu, telefon numarası ("Ara" seçeneği ile modal) ve o dükkana ait ürünleri listeler.
- **`presentation/screens/product_detail_screen.dart`**: Ürünün yüksek çözünürlüklü fotoğrafı, kg ve adet seçim butonları (farklı birim fiyatlarıyla), miktar artırma/azaltma ve sepete ekleme butonunu içerir.
- **`presentation/screens/favorites_screen.dart`**: Favoriye eklenen esnaf ve ürünleri listeler; tek dokunuşla favoriden çıkarma sağlar.
- **`presentation/screens/addresses_screen.dart`**: Kayıtlı adresleri listeler; yeni adres ekleme ve varsayılan adresi değiştirme işlevlerini sunar.
- **`presentation/screens/profile_screen.dart`**: Kullanıcı profil bilgileri, adreslerim, favorilerim, siparişlerim, işletme paneline geçiş, tema değiştirme ve hesabı kalıcı olarak silme butonunu içerir.

---

### 5.5. Gezinme Modülü (`lib/features/navigation/`)

- **`presentation/customer_navigation_shell.dart`**: Müşteri arayüzü alt gezinme çubuğu (Ana Sayfa, Keşfet, Sepetim, Siparişlerim, Profilim). `IndexedStack` ile ekran durumunu korur; sepet rozetini ürün çeşidi sayısına göre dinamik gösterir.
- **`presentation/business_navigation_shell.dart`**: Esnaf arayüzü alt gezinme çubuğu (Özet Paneli, Siparişler, Ürünler, Ayarlar).

---

### 5.6. Sipariş ve Kurye Modülü (`lib/features/order/`)

- **`domain/entities/order_entity.dart`**:
  - `OrderStatus`: `pendingResponse` (10 dk market yanıtı), `pendingCustomerDecision` (5 dk müşteri kararı), `preparing`, `courierAssigned`, `courierCollecting`, `courierOnTheWay`, `delivered`, `cancelled`.
  - `SubOrderStatus`: `pending`, `accepted`, `rejected`, `preparing`, `ready`.
  - `SubOrderEntity`: Belirli bir dükkana ait ürün kalemleri, alt toplam ve durum.
  - `OrderEntity`: Ana sipariş bilgileri, alt sipariş haritası, teslimat ücreti, simüle edilmiş iade tutarı, stok iade bayrağı (`isStockReleased`) ve sayaç metodları (`isDecisionExpired`, `canCustomerCancel`).
- **`domain/repositories/order_repository.dart`**: Sipariş oluşturma, müşteri ve esnaf siparişlerini canlı akışla (`Stream`) izleme, alt sipariş güncelleme, ret sonrası devam etme, iptal etme ve zaman aşımlarını değerlendirme metotları.
- **`data/repositories/order_repository_impl.dart`**:
  - `createOrder`: Maksimum 3 market kuralını doğrular; her ürün için güncel stoğu kontrol edip rezerve eder.
  - `updateSubOrderStatus`: Market yanıt verdiğinde diğer marketlerin durumunu kontrol eder. Hepsi onayladıysa `preparing` aşamasına geçirir; biri reddettiyse `pendingCustomerDecision` durumuna alır ve 5 dakikalık karar süresini başlatır. Hepsi hazır olduğunda kurye zaman damgasını başlatır.
  - `customerContinueAfterRejection`: Reddedilen marketi siparişten çıkarır; teslimat ücretini kalan marketlere göre yeniden hesaplar; çıkarılan marketin tutarını iade tutarına ekler; kalan marketler hazırsa kuryeyi başlatır.
  - `cancelOrder`: Siparişi iptal eder; ayrılan stokları ürün kataloğuna yalnızca **1 kez** (`isStockReleased` kontrolüyle) iade eder.
  - `evaluateTimeouts`: 10 dakikalık yanıt veya 5 dakikalık karar süresi dolduğunda otomatik iptal ve stok iadesini tetikler.
- **`presentation/bloc/order_bloc.dart`**: Sipariş oluşturma ve durum güncellemelerini yönetir.
- **`presentation/screens/checkout_screen.dart`**: Teslimat adresi seçimi, simüle edilmiş kredi kartı formu ve sipariş onay butonunu içerir.
- **`presentation/screens/order_confirmation_screen.dart`**: Başarılı sipariş sonrası sipariş numarası ve takip butonu sunan onay ekranı.
- **`presentation/screens/order_detail_screen.dart`**: Gerçek zamanlı saniyelik sayaç (`Timer.periodic`); market yanıtı ve müşteri kararı geri sayımları; esnaf bazlı alt sipariş kartları; kurye aşamaları simülatörü (Atandı, Toplanıyor, Yolda, Teslim Edildi); sipariş iptal ve ret sonrası devam etme butonları.
- **`presentation/screens/order_list_screen.dart`**: Müşterinin aktif ve geçmiş siparişlerini listeleyen sekmeli ekran.

---

### 5.7. Ürün Modülü (`lib/features/product/`)

- **`domain/entities/product_entity.dart`**: Ürün varlığı. `id`, `name`, `description`, `price`, `stock`, `unit` (`adet`, `kg`, `paket`), `allowedUnits`, `unitPrices` (örnek: `{'kg': 38.0, 'adet': 7.60}`), `sampleImageKey` ve `imageUrl` alanlarını içerir. `copyWith` metodu `clearImageUrl` bayrağı ile fotoğrafı temizleme yeteneğine sahiptir.
- **`domain/repositories/product_repository.dart`** & **`data/repositories/product_repository_impl.dart`**: Ürünlerin listelenmesi, eklenmesi, güncellenmesi, silinmesi ve stok miktarlarının güncellenmesini yönetir. Fotoğraf URL'sini Firestore ve bellek içi depoda eksiksiz saklar.
- **`presentation/bloc/product_bloc.dart`**: `ProductsLoadRequested`, `ProductAddRequested`, `ProductUpdateRequested`, `ProductDeleteRequested` olaylarını yönetir.

---

### 5.8. İşletme ve Esnaf Paneli Modülü (`lib/features/store/`)

- **`domain/entities/store_entity.dart`**: Esnaf varlığı. Çalışma saatleri, açık/kapalı durumu (`isOpen`), sipariş kabulünü geçici duraklatma (yoğunluk molası - `isPaused`), otomatik açılma tercihi (`autoReopenOnNextSchedule`) ve mağaza fotoğrafını içerir.
- **`domain/repositories/store_repository.dart`** & **`data/repositories/store_repository_impl.dart`**: Mağaza profilini okuma, güncelleme, açma/kapatma ve duraklatma fonksiyonlarını sağlar.
- **`presentation/bloc/store_bloc.dart`**: Mağaza durumlarını ve ayarlarını yönetir.
- **`presentation/screens/business_home_screen.dart`**: Esnaf ana sayfası. Günlük ciro, bekleyen sipariş sayısı, dükkan açık/kapalı ve mola anahtarları, hızlı ürün ekleme butonu ve bekleyen sipariş listesini sunar.
- **`presentation/screens/business_orders_screen.dart`**: Gelen alt siparişlerin yönetimi. Bekleyen, Hazırlanan, Tamamlanan ve İptal/Ret sekmeleri; siparişi onaylama, gerekçe belirterek reddetme ve hazır olarak işaretleme butonlarını içerir.
- **`presentation/screens/business_products_screen.dart`**: Esnafın ürün listesi, stok durumu, arama çubuğu, ürün silme ve düzenleme imkanı sunar.
- **`presentation/screens/business_settings_screen.dart`**: Dükkan açılış/kapanış saatleri, sipariş alımını duraklatma, otomatik açılış tercihi, müşteri moduna geçiş ve oturumu kapatma ayarları.
- **`presentation/widgets/add_edit_product_dialog.dart`**:
  - Yeni ürün ekleme ve düzenleme dialogu.
  - Canlı fotoğraf önizleme kartı (`ProductVisualBadge`).
  - Web görsel bağlantısı yapıştırma alanı (`imageUrlController`) ve tek tıkla temizleme butonu.
  - Hazır yüksek çözünürlüklü Unsplash fotoğraf galerisi (Süt, Yumurta, Peynir, Ekmek, Simit, Domates, Salatalık, Elma, Muz, Kıyma, Çay, Genel Bakkal). Bir fotoğrafa tıklandığında URL ve ilgili ikon anahtarı otomatik atanır.
  - Birim seçimi (`adet`, `kg`, `paket`, `gram`, `litre`) ve kg seçildiğinde adet fiyatını otomatik hesaplayan birim fiyat mantığı.

---

## 6. Kesinleşen İş Kuralları ve Doğrulama Matrisi

Uygulamanın tüm iş kuralları `test/business_rules_test.dart` ve `test/widget_test.dart` dosyalarında yer alan **22 adet otomatik test** ile doğrulanmıştır:

| # | İş Kuralı | Beklenen Davranış | Doğrulayan Test |
| :---: | :--- | :--- | :--- |
| **1** | **1 Market Teslimat Ücreti** | $20 + (1 \times 5) + (1.5 \times 3) = 29.50\text{ TL}$ | `business_rules_test.dart` (Grup 1) |
| **2** | **2 Market Teslimat Ücreti** | $20 + (2 \times 5) + (2.8 \times 3) = 38.40\text{ TL}$ | `business_rules_test.dart` (Grup 1) |
| **3** | **3 Market Teslimat Ücreti** | $20 + (3 \times 5) + (4.2 \times 3) = 47.60\text{ TL}$ | `business_rules_test.dart` (Grup 1) |
| **4** | **Maksimum 3 Market Kuralı** | 4. marketten ürün ekleme denendiğinde sepet engellemeli ve uyarı fırlatmalıdır. | `business_rules_test.dart` (Grup 2) |
| **5** | **Stok Rezervasyonu & İade** | Sipariş verilince stok rezerve edilir; iptal edildiğinde stok **yalnızca 1 kez** iade edilir. | `business_rules_test.dart` (Grup 3) |
| **6** | **Müşteri İptal Kısıtı** | Hazırlık başladıktan sonra müşteri iptali engellenmelidir (`canCustomerCancel == false`). | `business_rules_test.dart` (Grup 3) |
| **7** | **Kurye Simülasyonu** | Sipariş başlangıç zamanına göre kurye aşamaları deterministik hesaplanmalıdır. | `business_rules_test.dart` (Grup 4) |
| **8** | **Sepet Rozet Sayısı** | Aynı üründen 4 adet eklendiğinde rozet sayısı adet değil çeşit sayısı (1) olmalıdır. | `business_rules_test.dart` (Grup 5) |
| **9** | **Kg ve Adet Fiyat Ayrımı** | Ürünlerin kg ile adet fiyatları farklı olmalı; sepette seçili birime göre hesaplanmalıdır. | `business_rules_test.dart` (Grup 5) |
| **10** | **Tema Geçişi** | Açık/Koyu tema `ThemeService` üzerinden anında değişmeli ve UI'ya yansımalıdır. | `business_rules_test.dart` (Grup 5) |
| **11** | **Varsayılan Adres Yönetimi** | Yeni bir adres varsayılan yapıldığında diğerleri otomatik `false` olmalı ve dinleyiciler tetiklenmelidir. | `business_rules_test.dart` (Grup 5) |
| **12** | **İptal Edilen Sipariş Filtresi** | İptal edilen sipariş `isCompleted: true` olmalı ve aktif siparişler sekmesinden çıkmalıdır. | `business_rules_test.dart` (Grup 5) |
| **13** | **İşletme Ürün Ekleme/Düzenleme**| İşletme yeni ürün eklediğinde veya güncellediğinde ürün kataloğuna anında yansımalıdır. | `business_rules_test.dart` (Grup 5) |
| **14** | **Türkçe Karakter Duyarsız Arama**| Arama filtresi `sut`, `gultepe`, `ozlem` gibi normalize edilmiş girdileri tam eşleştirmelidir. | `business_rules_test.dart` (Grup 5) |
| **15** | **Semantik Kategori Filtresi** | Manav kategorisi Domates/Elma ürünlerini, Kasap kategorisi Kıyma ürünlerini doğru eşleştirmelidir. | `business_rules_test.dart` (Grup 5) |
| **16** | **Ürün Fotoğrafı Kaydetme** | Yeni ürün fotoğraf URL'si ile kaydedilmeli, güncellenebilmeli ve silinebilmelidir. | `business_rules_test.dart` (Grup 10) |
| **17** | **Erişilebilirlik ve Kontrast** | Material 3 renkleri WCAG AA standardını ($> 4.5:1$) ve $48\text{ px}$ dokunma hedefini sağlamalıdır. | `widget_test.dart` |

---

## 7. Derleme ve Test Talimatları

Projeyi yerel ortamda çalıştırmak, test etmek ve kod kalitesini doğrulamak için aşağıdaki komutlar kullanılır:

```bash
# 1. Bağımlılıkları güncelleme
flutter pub get

# 2. Statik kod analizi (0 hata, 0 uyarı garantisi)
flutter analyze

# 3. Tüm birim ve widget testlerini çalıştırma (22/22 geçiş)
flutter test
```

---
*Belge Son Güncelleme: 12 Kasım 2026 — Mahallem Proje Geliştirme Ekibi*
