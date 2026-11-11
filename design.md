# Mahallem – Design System

**Proje:** Mahallem
**Tasarım yaklaşımı:** Modern, Minimalist, User-Friendly
**UI Framework:** Flutter
**Design System:** Material 3
**Primary Brand Color:** Blue
**Secondary Brand Color:** Coral

---

## 1. Design Philosophy

Mahallem, mahalle işletmelerini ve müşterileri tek bir dijital pazar platformunda buluşturan bir alışveriş uygulamasıdır.

Tasarım dili aşağıdaki prensiplere dayanmalıdır:

- Modern ve minimalist arayüz.
- Kolay anlaşılabilir navigasyon.
- Güven veren marka kimliği.
- Ürün ve işletme odaklı görsel hiyerarşi.
- Gereksiz görsel karmaşadan kaçınma.
- Tutarlı açık ve koyu tema deneyimi.
- Erişilebilir ve okunabilir arayüz bileşenleri.

Tasarımda Material 3 prensipleri esas alınmalıdır.

## 2. Brand Identity

Mahallem'in marka kimliği mavi ve mercan renkleri üzerine kuruludur.

### 2.1 Primary Brand Color

| Özellik | Değer |
|---|---|
| Name | Mahallem Blue |
| HEX | `#3158C9` |
| Usage | Primary actions, navigation, selected states |
| Brand perception | Trust, technology, reliability |

### 2.2 Secondary Brand Color

| Özellik | Değer |
|---|---|
| Name | Mahallem Coral |
| HEX | `#FF795E` |
| Usage | Campaigns, discounts, promotional elements |
| Brand perception | Energy, friendliness, attention |

**Renk kullanım oranları:**

- %60 Neutral colors
- %30 Blue brand colors
- %10 Coral accent colors

Mercan rengi ana marka rengiyle rekabet etmemelidir. Kampanya, indirim ve özel vurgu alanlarında kullanılmalıdır.

---

## 3. Color System

Renkler merkezi olarak tanımlanmalı ve uygulamanın hiçbir yerinde rastgele HEX değerleri kullanılmamalıdır.

### 3.1 Light Theme

| Token | HEX | Description |
|---|---|---|
| Primary | `#3158C9` | Ana marka rengi |
| Primary Hover | `#2749AC` | Etkileşim durumu |
| Primary Container | `#E5EBFF` | Seçili alanlar |
| On Primary | `#FFFFFF` | Primary üzerindeki metin |
| Secondary | `#FF795E` | Vurgu rengi |
| Secondary Container | `#FFF0EB` | Kampanya arka planı |
| Background | `#F7F8FC` | Ana sayfa arka planı |
| Surface | `#FFFFFF` | Kartlar ve modal |
| Surface Variant | `#EEF1F7` | İkincil yüzeyler |
| On Surface | `#20283A` | Ana metin |
| On Surface Variant | `#687386` | İkincil metin |
| Outline | `#D9DFEA` | Kenarlıklar |
| Error | `#D64545` | Hata durumu |
| Success | `#23845B` | Başarılı işlem |
| Warning | `#D98A20` | Uyarı |

### 3.2 Dark Theme

| Token | HEX | Description |
|---|---|---|
| Primary | `#A9BCFF` | Ana marka rengi |
| Primary Hover | `#C0CDFF` | Etkileşim durumu |
| Primary Container | `#243A78` | Seçili alanlar |
| On Primary | `#17264D` | Primary üzerindeki metin |
| Secondary | `#FFAA96` | Vurgu rengi |
| Secondary Container | `#57342F` | Kampanya arka planı |
| Background | `#111827` | Ana sayfa arka planı |
| Surface | `#1A2435` | Kartlar ve modal |
| Surface Variant | `#263247` | İkincil yüzeyler |
| On Surface | `#F1F4FA` | Ana metin |
| On Surface Variant | `#B1BCD0` | İkincil metin |
| Outline | `#3C4960` | Kenarlıklar |
| Error | `#FF8585` | Hata durumu |
| Success | `#66D6A0` | Başarılı işlem |
| Warning | `#FFC16D` | Uyarı |

---

## 4. Component Color Rules

Uygulama içerisindeki bütün bileşenler merkezi renk tokenlarını kullanmalıdır.

| Component | Light Theme | Dark Theme |
|---|---|---|
| Primary Button | Primary | Primary |
| Primary Button Text | On Primary | On Primary |
| Secondary Button | Primary Container | Primary Container |
| Secondary Button Text | Primary | Primary |
| Product Card | Surface | Surface |
| Search Field | Surface Variant | Surface Variant |
| Bottom Navigation | Surface | Surface |
| Selected Navigation | Primary | Primary |
| Inactive Navigation | On Surface Variant | On Surface Variant |
| Campaign Badge | Secondary Container | Secondary Container |
| Campaign Text | `#B84934` | Secondary |
| Border | Outline | Outline |
| Main Text | On Surface | On Surface |
| Secondary Text | On Surface Variant | On Surface Variant |

### 4.1 Button Rules

**Primary Button**
- Ana işlemler için kullanılmalıdır.
- Arka plan Primary olmalıdır.
- Metin On Primary rengini kullanmalıdır.
- Sepete ekleme, sipariş verme ve ödeme işlemleri bu gruptadır.

**Secondary Button**
- İkincil işlemlerde kullanılmalıdır.
- Primary Container arka planı kullanılmalıdır.
- Primary metin rengi kullanılmalıdır.

**Promotional Button**
- Kampanya odaklı işlemlerde kullanılmalıdır.
- Secondary arka planı kullanılmalıdır.
- Koyu metin tercih edilmelidir.

**Disabled Button**
- Pasif görünüm kullanılmalıdır.
- Kullanıcının işlemi gerçekleştiremeyeceği açıkça anlaşılmalıdır.

### 4.2 Product Card Rules

Ürün kartları aşağıdaki özelliklere sahip olmalıdır:

- Arka plan Surface olmalıdır.
- Köşe yuvarlaklığı 12–16 px arasında olmalıdır.
- Ürün görseli standart bir alan içerisinde gösterilmelidir.
- Ürün adı en fazla iki satır olmalıdır.
- Ürün fiyatı görsel hiyerarşide belirgin olmalıdır.
- İndirim etiketi Secondary renk ailesini kullanmalıdır.
- Sepete ekleme butonu Primary rengini kullanmalıdır.
- Favori ikonu seçili olduğunda Coral rengini kullanmalıdır.

### 4.3 Input and Search Field Rules

- Input arka planı Surface Variant olmalıdır.
- Input metni On Surface olmalıdır.
- Placeholder On Surface Variant kullanmalıdır.
- Focus border Primary rengini kullanmalıdır.
- Error durumunda Error rengi kullanılmalıdır.
- Border radius 12 px olmalıdır.

### 4.4 Navigation Rules

Bottom Navigation aşağıdaki prensiplere uymalıdır:

- Arka plan Surface olmalıdır.
- Aktif ikon ve metin Primary kullanmalıdır.
- Pasif ikon ve metin On Surface Variant kullanmalıdır.
- Seçili sekme görsel olarak ayırt edilmelidir.
- Navigasyon bileşeni açık ve koyu temada aynı yapıyı korumalıdır.

---

## 5. Typography

Uygulamanın temel font ailesi **Inter** olmalıdır.

| Element | Font Size | Weight |
|---|---:|---|
| Display / Large Title | 28 px | Bold |
| Screen Title | 24 px | SemiBold |
| Section Title | 20 px | SemiBold |
| Card Title | 16 px | Medium |
| Product Name | 14–16 px | Medium |
| Body | 14 px | Regular |
| Caption | 12 px | Regular |
| Button | 14–16 px | SemiBold |

Tipografi kuralları:

- Başlıklar net ve kısa olmalıdır.
- Ürün fiyatları kolay fark edilmelidir.
- Yardımcı metinler ana metinlerden daha düşük görsel öneme sahip olmalıdır.
- Metinler ekran genişliğine göre taşma kontrolüne sahip olmalıdır.

---

## 6. Spacing and Shape System

### 6.1 Spacing

| Token | Value |
|---|---:|
| XS | 4 px |
| SM | 8 px |
| MD | 12 px |
| LG | 16 px |
| XL | 24 px |
| XXL | 32 px |
| XXXL | 48 px |

Standart ekran yatay padding değeri 16 px olmalıdır.

### 6.2 Border Radius

| Component | Radius |
|---|---:|
| Small Elements | 8 px |
| Input Fields | 12 px |
| Buttons | 12 px |
| Product Cards | 16 px |
| Modal / Bottom Sheet | 20 px |
| Large Containers | 20 px |

### 6.3 Component Dimensions

| Component | Height |
|---|---:|
| Primary Button | 48–52 px |
| Input Field | 48–52 px |
| Bottom Navigation | Platform ve içerik gereksinimlerine uygun |
| Icon Button | 40–48 px |

---

## 7. Visual Design Rules

- Gereksiz gradient kullanımından kaçınılmalıdır.
- Ağır gölgeler yerine ince border tercih edilmelidir.
- Ürün görselleri mümkün olduğunca standart oranlarda gösterilmelidir.
- Bileşenlerde tutarlı ikon stili kullanılmalıdır.
- Animasyonlar kısa ve işlevsel olmalıdır.
- Gereksiz renk çeşitliliği oluşturulmamalıdır.
- Her ekran aynı tasarım sistemini takip etmelidir.
- Renkler dışında ikon ve metinlerle de durum bilgisi verilmelidir.

---

## 8. Accessibility

WCAG AA kontrast standartları hedeflenmelidir.

- Normal metinlerde minimum 4.5:1 kontrast oranı hedeflenmelidir.
- Büyük metinlerde minimum 3:1 kontrast oranı hedeflenmelidir.
- Coral rengi beyaz metinle kullanılmamalıdır.
- Hata, başarı ve uyarı durumları yalnızca renkle ifade edilmemelidir.
- Dokunmatik alanlar yeterli büyüklükte olmalıdır.
- Metin boyutları sistem erişilebilirlik ayarlarına uyum sağlamalıdır.

---

## 9. Flutter Theme Architecture

Tema altyapısı merkezi ve genişletilebilir olmalıdır.

### 9.1 Folder Structure

```text
lib/
└── core/
    └── theme/
        ├── app_colors.dart
        ├── app_theme.dart
        ├── light_theme.dart
        └── dark_theme.dart
```

### 9.2 File Responsibilities

**app_colors.dart**
- Light ve Dark tema renk sabitlerini içermelidir.
- Marka renkleri merkezi olarak tanımlanmalıdır.
- Renkler tekrar kullanılabilir olmalıdır.

**light_theme.dart**
- Açık tema ThemeData tanımını içermelidir.
- Material 3 desteklenmelidir.
- ColorScheme tanımlanmalıdır.
- Component theme tanımları burada yönetilmelidir.

**dark_theme.dart**
- Koyu tema ThemeData tanımını içermelidir.
- Light Theme ile aynı bileşen standartlarını korumalıdır.
- Dark ColorScheme kullanılmalıdır.

**app_theme.dart**
- Light ve Dark temaları bir araya getirmelidir.
- Uygulamanın tema yönetimini merkezi olarak sağlamalıdır.

### 9.3 MaterialApp Configuration

Uygulama Material 3 kullanmalıdır.

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
);
```

Tema yönetimi:

- `ThemeMode.system` varsayılan olmalıdır.
- Sistem açık tema kullanıyorsa Light Theme uygulanmalıdır.
- Sistem koyu tema kullanıyorsa Dark Theme uygulanmalıdır.
- İleride kullanıcıya manuel tema seçimi sunulabilmelidir.

### 9.4 Flutter Implementation Rules

- `ThemeData` kullanılmalıdır.
- `ColorScheme` kullanılmalıdır.
- Material 3 etkin olmalıdır.
- Widget içerisinde doğrudan HEX renk tanımlanmamalıdır.
- Renkler `Theme.of(context).colorScheme` üzerinden alınmalıdır.
- Ortak stiller merkezi olarak yönetilmelidir.
- Tema değişikliği tüm ekranlara yansımalıdır.
- Light ve Dark tema bileşenleri görsel tutarlılığı korumalıdır.

---

## 10. Final Design Decisions

| Category | Decision |
|---|---|
| Brand Name | Mahallem |
| Design Style | Modern & Minimalist |
| Primary Color | Blue `#3158C9` |
| Secondary Color | Coral `#FF795E` |
| UI Framework | Flutter |
| Design System | Material 3 |
| Font Family | Inter |
| Default Theme | System |
| Light Theme | Supported |
| Dark Theme | Supported |
| Theme Architecture | Centralized |
| Responsive Design | Required |

**Core Principle:** Mahallem'in tüm ekranları aynı marka kimliğini ve tasarım sistemini takip etmelidir. Yeni geliştirilen her bileşen mevcut renk, tipografi, spacing ve component kurallarına uygun olmalıdır.

---

# Ek Kararlar — 11 Kasım 2026

Bu bölüm, proje değerlendirmesinde kabul edilen güncel kararları içerir. Önceki içerik tarihçe korunması amacıyla aynen bırakılmıştır. Önceki bölümlerle çelişki olduğunda bu ek bölüm esas alınır. Açık kararlar, kesinleşmiş gereksinim sayılmaz.

## Güncel Kapsama Uygun Arayüz

- Giriş ekranları e-posta ve şifre ile giriş sunacaktır; telefon/SMS ile giriş sunulmayacaktır.
- Ürün ve işletme görsel alanları hazır görsellerden seçim sunacaktır; gerçek dosya yükleme beklentisi oluşturulmayacaktır.
- Ödeme ve iade ekranlarında işlemlerin simülasyon olduğu açıkça belirtilecek; gerçek kart bilgisi istenmeyecektir.
- Kurye ve teslimat takibinde demo niteliği belirtilecek; gerçek konum takibi izlenimi verilmeyecektir.
- Yeni işletme bildirimlerine ait arayüz ilk sürüm kapsamından çıkarılmıştır.
- Market çıkarıldığında güncellenen ürün toplamı, teslimat ücreti ve genel toplam müşteri devam onayından önce gösterilecektir.
- Hazırlık öncesi iptal işlemi erişilebilir olacak; hazırlık başladıktan sonra doğrudan iptalin mümkün olmadığı anlaşılır biçimde belirtilecektir.

## Erişilebilirlik Düzeltmeleri

- Açık temada On Surface Variant (#687386) ile Surface Variant (#EEF1F7) eşleşmesi yaklaşık 4,23:1 kontrast sağlar; normal metin için 4,5:1 hedefini karşılamaz. İlgili metin tokenı koyulaştırılarak veya arka plan değiştirilerek hedef sağlanmalıdır.
- Açık temada Error (#D64545) ile beyaz eşleşmesi yaklaşık 4,38:1 kontrast sağlar; normal metin için hedefi karşılamaz. İlgili kullanım için hata metni/zemin eşleşmesi düzeltilmelidir.
- Yeni renk değerleri henüz seçilmemiştir. Düzeltilen eşleşmeler uygulanmadan önce kontrastları doğrulanacaktır.
- Başarı, uyarı ve kampanya kullanımları için metin/arka plan tokenları merkezi olarak tamamlanacak; widget içinde yeni HEX değerleri tanımlanmayacaktır.
- Etkileşimli bileşenlerin dokunma hedefi en az 48 × 48 mantıksal piksel olacaktır. Görsel ikon boyutu bu hedefin içinde daha küçük olabilir.
- Tasarım ölçüleri Flutter uygulamasında mantıksal piksel olarak yorumlanacak

## Kesinleşen Kuralların Ekranlara Yansıması

- Sepette en fazla 3 market sınırı açıklanacak; sınır aşımı anlaşılır mesajla bildirilecektir.
- Adres ve market seçimleri örnek hizmet mahallesiyle sınırlı olacaktır.
- Teslimat ücreti özette tek kalem olarak gösterilecektir.
- Demo hesaplama:
  20 TL + (market sayısı × 5 TL) + (örnek rota kilometresi × 3 TL).
- Market çıkarıldığında güncel ürün toplamı, teslimat ücreti ve genel toplam devam onayından önce gösterilecektir.
- Market reddi sonrası karar ekranı, 5 dakikalık süreyi ve yanıt verilmezse siparişin iptal edileceğini açıklayacaktır.
- Kalan süre yalnızca renkle anlatılmayacaktır.
- Sipariş öncesi fiyat değişikliğinde yeni fiyat ve toplam için yeniden onay istenecektir.
- Kurye simülasyonu bütün kalan marketler hazır olduğunda başlayacaktır.
- Atanma, toplama, yolda ve teslim edildi aşamaları gösterilecektir.
- Simülasyon yeniden açılışta kayıtlı zaman çizelgesinden devam edecektir.
- Gerçek canlı konum takibi izlenimi verilmeyecektir.