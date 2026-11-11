---
name: Mahallem - Dijital Pazar Uygulaması Geliştirme Becerisi (Core Development Skill)
description: Bu yetenek, dijital pazar uygulamasında yeni bir özellik, ekran veya model geliştirirken proje standartlarına (Clean Architecture, Bloc, Material 3) ve katı UI kurallarına tam uyulmasını garanti altına alır.
---

# Dijital Pazar Uygulaması Geliştirme Becerisi (Core Development Skill)
Bu yetenek, dijital pazar uygulamasında yeni bir özellik, ekran veya model geliştirirken proje standartlarına (Clean Architecture, Bloc, Material 3) ve katı UI kurallarına tam uyulmasını garanti altına alır.

## İlgili Dosyalar ve Referanslar
- **Proje Genel Standartları:** `project.md`
- **Ekran Gereksinimleri:** `screens.md`
* **Tasarım Kuralları:** `design.md`



## Geliştirme Çıktı ve Doğrulama Kuralları
- Ajan kod yazarken sadece değiştirilen veya eklenen satırları diff formatında göstermelidir (tüm dosyayı basmak yasaktır).
- Geliştirme bittiğinde ajanın mutlaka şu komutlarla sistemi test etmesi ve kullanıcıya bildirmesi gerekir:
  ```bash
  flutter analyze
  flutter test
  flutter run
  ```


## 2. Geliştirme Kuralları
- Kod okunabilir ve modüler olmalı.

- Her ekran ayrı bir dosyada tutulmalı

- Widget'lar gereksiz yere karmaşıklaştırılmamalı.

- Kod yapısını anlaşılır ve bakımı kolay olmalı.

- Gereksiz paketlerden ve karmaşık mimarilerden kaçınılmalı.

- kodlar kesinlikle tek bir yerde toplanmayacaktır. her modül feature klasöründe kodlanacaktır.

Flutter'ın yerleşik özellikleri yeterli olduğunda öncelikle bu özellikler kullanılmalıdır.Onay alınmadan yeni bir durum yönetimi paketi eklenmemeli veya kalıcı veri saklama yöntemi kesinleştirilmemelidir.


## 6. Mimari Kurallar
- Uygulama küçük ve anlaşılır bir dosya yapısına sahip olmalıdır.

- Her ekran kendi dosyasında bulunmalıdır.

- Aynı veri farklı ekranlarda birbirinden bağımsız kopyalar olarak tutulmamalıdır.

- Uygulamada BloC yapısı en temel ve basit hali ile proje gereksinimlerini kapsayacak şekilde kullanılmalıdır.

## 8. Geliştirme Analiz ve Test Komutları
Ajan yaptığı herhangi bir kod değişikliğinden sonra mutlaka alttaki komutların çalıştığını doğrulamalıdır. 

* **Statik kod analizi (0 uyarı ve 0 hata şart):**
```bash
flutter anaylze 
```

* **Birim ve widget testleri:**
```bash
flutter test
```

* **Projeyi Çalıştırma:**
```bash
flutter run
```

## 9. Ajanın çıktı verme ve yanıt verme standartları
**Açıklamalar:** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.

**Değişiklik sunumları:** örnek 500 satırlık bir dosyada 3 satır değiştiyse tüm dosyayı baştan sona basma; hedef satırları ve diff yapısını göster.

**Dosya yolları:** Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanabilir link ver.

**Doğrulama:** Kod yazdıktan sonra kullanıcıya "Şimdi flutter analiz ile kontrol edebilirsin" şeklinde doğrulama yönergeleri ver.

---

# Ek Kararlar — 11 Kasım 2026

Bu bölüm, proje değerlendirmesinde kabul edilen güncel kararları içerir. Önceki içerik tarihçe korunması amacıyla aynen bırakılmıştır. Önceki bölümlerle çelişki olduğunda bu ek bölüm esas alınır. Açık kararlar, kesinleşmiş gereksinim sayılmaz.

## Güncel Geliştirme Kapsamı

- project.md, screens.md ve design.md sonundaki Ek Kararlar bölümleri, önceki çelişen ifadelerden önceliklidir. Açık kararlar onaylanmış gereksinim gibi uygulanmaz.
- Özel backend, Firebase dışı harici API ve ücretli servis entegrasyonu yapılmaz.
- Firebase Authentication e-posta/şifre, Cloud Firestore ise ortak iş verileri ve gerçek zamanlı güncellemeler için kullanılır.
- Firebase Spark planında kalınır; faturalandırma hesabı bağlanmaz. Cloud Functions, Firebase Storage ve SMS doğrulaması kapsam dışıdır.
- Ödeme, iade, kurye ve teslimat simülasyondur. Gerçek kart bilgisi alınmaz. Görseller uygulama içindeki örneklerden seçilir.
- Yeni işletme bildirimleri uygulanmaz.

## Mimari ve Güvenlik Açıklamaları

- Feature bazlı klasörleme içinde gerekli data/domain/presentation katmanları kullanılır. BLoC ve Clean Architecture korunur; ortak altyapı core altında tutulur.
- Firestore ortak verilerin kaynağıdır. Hive kullanımı zorunlu değildir; ek yerel kalıcı depolama ihtiyacı ayrıca değerlendirilir.
- Rol bazlı yönlendirme tek başına yetkilendirme değildir. Firestore Security Rules ile kullanıcı ve mağaza sahipliği, izin verilen veri erişimleri ve durum değişiklikleri korunur.
- Firebase istemci yapılandırması ve mobil .env dosyaları güvenlik sınırı kabul edilmez; sunucu sırları mobil uygulamaya konulmaz.
- Kullanılacak Flutter sürümü geliştirme başlangıcında sabitlenir.

## Doğrulama Kurallarının Açıklanması

- Önceki flutter anaylze yazımı hatalıdır; geçerli komut flutter analyze olacaktır.
- Kod değişikliğinin kapsamına uygun flutter analyze ve flutter test kontrolleri çalıştırılır. Sipariş durumları, stok ve erişim kuralları gibi kritik davranışlar anlamlı testlerle doğrulanır.
- Çalıştırma doğrulaması, mevcut ve desteklenen bir cihaz/emülatör hedefi seçilerek flutter run ile yapılır. Her küçük değişiklikten sonra uzun süreli yeni bir çalıştırma oturumu açılması zorunlu değildir; ilgili akış değiştiğinde yeniden doğrulanır.
- Gerekli SDK veya cihaz bulunmuyorsa çalıştırma başarılı gibi raporlanmaz; engel açıkça belirtilir.
- Doğrulama sonucunda çalıştırılan kontroller ve sonuçları bildirilir; yalnızca kullanıcıya komut önerilmesi tamamlanmış doğrulama sayılmaz.
- Bu turdaki yalnızca belge güncellemeleri için Flutter komutlarının çalıştırılması gerekmez.
- Ek kararlar uygulanırken tasarım erişilebilirliği ve Firestore yetkilendirmesi de doğrulanır. Henüz kesinleşmeyen sayılar, ücretler ve simülasyon süreleri sessizce varsayılan gereksinime dönüştürülmez.

## Kesinleşmiş Kuralların Uygulanması ve Doğrulanması

- Tek örnek mahalle ve sipariş başına en fazla 3 market kuralı uygulanır.
- Demo teslimat ücreti:
  20 TL + (market sayısı × 5 TL) + (örnek rota kilometresi × 3 TL).
- Market çıkarıldığında kalan marketlere göre örnek rota ve ücret yeniden hesaplanır; güncel toplam müşteri onayına sunulur.
- Market yanıt süresi 10 dakika; ret sonrası müşteri karar süresi karar talebinden itibaren 5 dakikadır.
- Müşteri karar vermezse tüm sipariş iptal edilir.
- Süre sonları Firestore'da tutulur; süresi geçmiş işlemler kurallarla engellenir.
- Uygulamalar kapalıyken tam zamanında veritabanı güncellemesi vaat edilmez.
- Stok sipariş oluşturulurken ayrılır.
- Ret veya iptalde yalnızca ilgili miktar, yalnızca bir kez geri verilir.
- Sipariş öncesinde fiyat ve stok kontrol edilir; değişen fiyat için yeniden müşteri onayı alınır.
- Bütün market yanıtları ve gereken müşteri kararı tamamlanmadan hazırlık başlatılmaz.
- Hazırlık başladıktan sonra doğrudan müşteri iptali engellenir.
- Kurye simülasyonu bütün kalan marketler hazır olduğunda başlar.
- Aşamalar merkezi örnek süreler ve kayıtlı başlangıç zamanı üzerinden hesaplanır.
- Yeniden açılış ve farklı cihazlar aynı zaman çizelgesini esas alır.
- Gerçek kurye paneli veya canlı konum servisi geliştirilmez.

### Kritik Doğrulama Senaryoları

- Dördüncü marketten ürün ekleme sınırı.
- Sipariş öncesi fiyat değişikliği.
- Yetersiz stok ve eşzamanlı siparişler.
- Tekrarlanan iptalde stoğun ikinci kez artırılmaması.
- Market yanıt ve müşteri karar sürelerinin dolması.
- Market çıkarıldığında mesafe ve ücretin yeniden hesaplanması.
- Hazırlık başlamadan iptal ve hazırlık sonrası iptal yasağı.
- Uygulama yeniden açıldığında kurye simülasyonunun devam etmesi.
- Yetkisiz kullanıcıların başka kullanıcı veya işletme verilerine erişememesi.