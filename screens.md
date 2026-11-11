# screens.md - Ekran Gereksinimleri

# 1. Dosyanın Amacı:
Bu dosyanın amacı uygulama içerisindeki rolleri ve ekran özelliklerini tanımlamaktır.

# 2. Kullanıcı Rolleri

İlk sürümde iki temel kullanıcı rolü bulunacaktır.

## 2.1. Müşteri

Müşteri:
- Marketleri görüntüleyebilir.
- Marketlerin ürünlerini inceleyebilir.
- Farklı marketlerden ürünleri sepetine ekleyebilir.
- Tek sipariş oluşturabilir.
- Siparişini ve marketlerin hazırlık durumlarını takip edebilir.
- Sipariş geçmişini görüntüleyebilir.
- Favori market ve ürünlerini kaydedebilir.
- Adreslerini yönetebilir.
- Profil ve hesap ayarlarını düzenleyebilir.

## 2.2. İşletme Sahibi

İşletme sahibi:
- İşletme hesabı oluşturabilir.
- İşletme hesabına giriş yapabilir.
- İşletme bilgilerini düzenleyebilir.
- Mağazasının açık veya kapalı durumunu yönetebilir.
- Ürün ekleyebilir, düzenleyebilir ve silebilir.
- Kendisine iletilen siparişleri görüntüleyebilir.
- Siparişleri kabul veya reddedebilir.
- Kabul ettiği siparişlerin hazırlık durumunu güncelleyebilir.
---

# 3. Müşteri Paneli

## 3.1. Giriş Ekranı

- E-posta veya telefon numarası ile giriş.
- Şifre alanı.
- Şifreyi göster/gizle.
- Şifremi unuttum bağlantısı.
- Giriş yap butonu.
- Hesap oluşturma bağlantısı.

## 3.2. Kayıt Ekranı

- Ad ve soyad.
- E-posta adresi.
- Telefon numarası.
- Şifre.
- Şifre doğrulama.
- Kullanım koşulları onayı.
- Hesap oluşturma butonu.

Alanlar uygun şekilde doğrulanmalı ve kullanıcıya anlaşılır hata mesajları gösterilmelidir.

## 3.3. Ana Sayfa

Ana sayfa müşterinin alışverişe başlayacağı merkez olacaktır.

İçerik:
- Arama alanı.
- Öne çıkan marketler.
- Kategoriler.
- Popüler ürünler.
- Kampanyalar veya önerilen ürünler.
- Kullanıcının konumuna/adresine göre marketler.

## 3.4. Keşfet ve Arama

- Market arama.
- Ürün arama.
- Kategoriye göre filtreleme.
- Market kategorisine göre filtreleme.
- Fiyat veya popülerliğe göre sıralama.
- Arama sonucu bulunamadığında boş durum ekranı.

## 3.5. Market Detayları

- Market adı ve logosu.
- Market kategorisi.
- Açıklama.
- Adres.
- Çalışma saatleri.
- Açık/kapalı durumu.
- Ürün kategorileri.
- Ürün listesi.

Kapalı marketlerin sipariş kabul edip edemediği açıkça belirtilmelidir.

## 3.6. Ürün Detayları

- Ürün görseli.
- Ürün adı.
- Açıklama.
- Fiyat.
- Ürün kategorisi.
- Stok durumu.
- Adet seçimi.
- Sepete ekleme butonu.

## 3.7. Sepet

Sepet, birden fazla marketten seçilmiş ürünleri tek ekranda gösterecektir.

- Ürünler marketlerine göre gruplandırılmalıdır.
- Ürün miktarları değiştirilebilmelidir.
- Ürünler sepetten çıkarılabilmelidir.
- Her marketin ara toplamı gösterilmelidir.
- Genel ürün toplamı gösterilmelidir.
- Tahmini teslimat ücreti ve toplam tutar gösterilmelidir.

## 3.8. Ödeme ve Sipariş Oluşturma

- Teslimat adresi seçimi.
- Sipariş özeti.
- Marketlere göre ürünlerin özeti.
- Ürün toplamı.
- Tek teslimat ücreti.
- Genel toplam.
- Online ödeme adımı.
- Siparişi onaylama.

İlk prototipte ödeme işlemi simüle edilecektir.

## 3.9. Sipariş Onayı

- Sipariş numarası.
- Sipariş özeti.
- Ödeme sonucu.
- Siparişin başlangıç durumu.
- Sipariş detayına gitme bağlantısı.

## 3.10. Siparişlerim

- Aktif siparişler.
- Geçmiş siparişler.
- Sipariş durumu.
- Sipariş tarihi.
- Sipariş tutarı.

## 3.11. Sipariş Detayı ve Takip

Müşteri tek sipariş ekranında:
- Genel sipariş durumunu,
- Siparişin toplam tutarını,
- Marketlere ait alt siparişleri,
- Her marketin sipariş durumunu,
- Ürünleri ve miktarlarını,
- Teslimat bilgilerini

görüntüleyebilmelidir.

Bir siparişteki marketlerin hazırlık durumları birbirinden bağımsız ilerleyebilir.

## 3.12. Favoriler

- Favori marketler.
- Favori ürünler.
- Favorilerden çıkarma.

## 3.13. Profil

- Kullanıcı bilgileri.
- Adreslerim.
- Favorilerim.
- Hesap ayarları.
- Çıkış yap.

## 3.14. Adreslerim

- Adres ekleme.
- Adres düzenleme.
- Adres silme.
- Varsayılan adres belirleme.
- Adres açıklaması ve teslimat notu.

---

# 4. İşletme Paneli

## 4.1. İşletme Giriş Ekranı

Giriş ekranında yalnızca işletme hesabına giriş için gerekli bilgiler bulunacaktır.

- E-posta veya telefon numarası.
- Şifre.
- Şifreyi göster/gizle.
- Şifremi unuttum.
- Giriş yap butonu.
- İşletme hesabı oluşturma bağlantısı.

Başvuru durumu bu ekranda gösterilmeyecektir.

Başarılı girişte işletme ana sayfasına yönlendirme yapılmalıdır. Hatalı girişlerde anlaşılır hata mesajları gösterilmelidir.

## 4.2. İşletme Hesabı Oluşturma

İşletme hesabı oluşturma sürecinde gerekli hesap ve işletme bilgileri alınmalıdır.

İlk prototipte gerçek kimlik veya resmi belge doğrulaması yapılmayacaktır. Gerçek işletme doğrulaması backend gerektiren sonraki bir aşamadır.

## 4.3. İşletme Bilgileri

- İşletme adı.
- İşletme logosu.
- İşletme kategorisi.
- Açıklama.
- Telefon numarası.
- Açık adres.
- Harita konumu.
- Çalışma günleri ve saatleri.

## 4.4. İşletme Ana Sayfası

- Günlük sipariş özeti.
- Yeni sipariş sayısı.
- Hazırlanan sipariş sayısı.
- Tamamlanan sipariş sayısı.
- Mağaza açık/kapalı durumu.
- Son siparişler.

## 4.5. Sipariş Yönetimi

Sipariş listesi ve seçilen siparişin detayları aynı ekran içerisinde yönetilecektir.

Siparişler durumlarına göre filtrelenebilmelidir:
- Yeni siparişler.
- Hazırlanıyor.
- Hazır.
- Geçmiş siparişler.

İşletme yalnızca kendi marketine ait ürünleri ve alt sipariş bilgilerini görebilmelidir.

Başka marketlerin ürünleri, fiyatları ve satış bilgileri işletmeye gösterilmemelidir.

## 4.6. Ürün Yönetimi

- Ürün listesi.
- Ürün arama.
- Kategoriye göre filtreleme.
- Ürün ekleme.
- Ürün düzenleme.
- Ürün silme.
- Stok durumu.
- Ürün aktif/pasif durumu.

## 4.7. Ürün Ekleme ve Düzenleme

- Ürün adı.
- Açıklama.
- Fiyat.
- Kategori.
- Görsel.
- Stok miktarı veya stok durumu.
- Ürünün satışta olup olmadığı.

## 4.8. Mağaza Ayarları

İşletme sahibi aşağıdaki bilgileri yönetebilmelidir:

**Mağaza bilgileri**
- Mağaza adı.
- Logo.
- Kategori.
- Açıklama.
- Telefon.
- Adres

**Çalışma saatleri**
- Haftanın günlerine göre açılış ve kapanış saatleri.
- Kapalı günler.
- Çalışma saatleri dışında otomatik kapanma.

**Mağaza durumu**
- Mağazayı manuel açma.
- Mağazayı manuel kapatma.
- Siparişleri geçici olarak duraklatma.

Manuel kapatma sırasında iki seçenek bulunmalıdır:
1. Bir sonraki planlı açılış saatinde otomatik açıl.
2. Ben açana kadar kapalı tut.

**Hesap ayarları**
- Şifre değiştirme.
- Oturumu kapatma.
- hesap silme

## 4.9. İşletme Alt Navigasyonu

Alt navigasyonda dört bölüm bulunacaktır:

1. Ana Sayfa
2. Siparişler
3. Ürünler
4. Mağazam

---

# 5. Temel İş Kuralları

## 5.1. Çoklu Market Siparişi

Bir müşteri farklı marketlerden ürünleri tek bir siparişte birleştirebilir.

Ana sipariş, marketlere ait alt siparişlerden oluşmalıdır.

Örnek:

- Ana sipariş: 3 marketten toplam 8 ürün.
- Market A alt siparişi: 3 ürün.
- Market B alt siparişi: 2 ürün.
- Market C alt siparişi: 3 ürün.

Her market yalnızca kendisine ait alt siparişi görüntüler ve yönetir.

Müşteri ise bütün alt siparişleri tek sipariş üzerinden takip eder.

## 5.2. Siparişin Market Tarafından İşlenmesi

Her market kendi alt siparişi için aşağıdaki süreci izler:

1. Yeni sipariş.
2. Siparişi kabul veya reddetme.
3. Kabul edilen siparişin hazırlanması.
4. Siparişin hazır olarak işaretlenmesi.

Bir marketin hazırlık durumu diğer marketlerin durumundan bağımsızdır.

## 5.3. Market Siparişinin Reddedilmesi

Bir market siparişi reddederse müşteriye bilgi verilir.

Müşteri iki seçenek arasından karar verir:

1. Reddedilen marketin ürünlerini siparişten çıkararak diğer marketlerle devam etmek.
2. Tüm siparişi iptal etmek.

Müşteri devam etmeyi seçerse siparişin ürün toplamı yeniden hesaplanır.

Tüm sipariş iptal edilirse ödeme iade süreci başlatılır.

Diğer marketlerin sipariş durumları, müşterinin kararı sonuçlanana kadar korunmalıdır.

## 5.4. Marketin Yanıt Vermemesi

Marketin siparişi kabul veya reddetmesi için 10 dakika süre olacaktır.

- Süre içinde yanıt verilmezse sipariş otomatik reddedilir.
- Müşteriye marketin yanıt vermediği bildirilir.
- Müşteri, reddedilen marketin ürünlerini çıkararak devam edebilir veya tüm siparişi iptal edebilir.


İlk prototipte bu süre yapılandırılabilir bir sabit değer olarak tutulabilir.

## 5.5. Ürün Hazırlama Süresi

Market siparişi kabul ettiğinde sistem tahmini hazırlama süresi oluşturacaktır.

Tahmin:
- Marketin geçmiş sipariş hazırlama sürelerine dayanmalıdır.
- Yeterli geçmiş veri yoksa varsayılan bir süre kullanılmalıdır.
- Müşteriye tahmini hazırlık süresi gösterilmelidir.
- Gerçek hazırlık süresi kaydedilerek gelecekteki tahminlerde kullanılmalıdır.

İlk prototipte geçmiş veriler yerel Hive kayıtlarıyla sınırlıdır. Farklı işletmelerin ortak verilerinden öğrenen bir tahmin sistemi backend gerektirir.

## 5.6. Stokta Olmayan Ürünler

Müşteri sipariş sırasında stokta bulunmayan ürünlerle ilgili tercih belirleyebilmelidir.

Tercihler:
1. Alternatif ürün kullanılması.
2. Ürünün siparişten çıkarılması.
3. İşleme devam etmeden önce müşteriye sorulması.

Alternatif ürünün fiyatı farklıysa fiyat farkı müşteriye açıkça gösterilmelidir.

Ürün siparişten çıkarıldığında sipariş toplamı yeniden hesaplanmalıdır.

## 5.7. Sipariş İptali

Müşteri, kurye marketlerden ürün toplamaya başlamadan önce tüm siparişi iptal edebilir.

Kurye toplama sürecine başladıktan sonra müşteri tarafından doğrudan iptal işlemi yapılamaz.

Yanlış, eksik veya hasarlı ürün gibi istisnai durumlar için destek ve iade süreçleri ileride ayrıca tanımlanmalıdır.

## 5.8. Teslimat Ücreti

Uygulamanın temel iş modellerinden biri, birden fazla marketten yapılan alışveriş için tek teslimat ücreti almaktır.

Diğer uygulamalarda her market için ayrı teslimat ücreti ve farklı kurye süreci bulunabilir. Bu projede amaç, tek kuryenin gerçekleştireceği toplama ve teslimat süreci için daha makul bir toplam ücret sunmaktır.

Teslimat ücreti siparişe göre dinamik hesaplanacaktır.

Hesaplamada dikkate alınması gereken faktörler:
- Toplam rota mesafesi.
- Siparişte bulunan market sayısı.
- Marketler arasında kat edilecek mesafe.
- Müşteriye teslimat mesafesi.
- Kurye için ödenecek ücret.
- Operasyonel maliyetler.
- Minimum teslimat ücreti.

Müşteriye tek bir teslimat ücreti gösterilmelidir.

Ücretin hedefi, ayrı ayrı market teslimat ücretlerinin toplamından daha uygun olmaktır. Ancak işletme ve kurye maliyetlerini karşılamayan bir fiyatlandırma yapılmamalıdır.

İlk prototipte gerçek rota ve maliyet optimizasyonu yerine örnek verilerle hesaplama simüle edilebilir.

## 5.9. Ödeme

İlk sürümün hedeflediği ödeme yöntemi yalnızca online kart ödemesidir.

- Kredi kartı ve banka kartı desteklenmesi hedeflenir.
- Kapıda nakit ödeme bulunmayacaktır.
- Kapıda POS ödeme bulunmayacaktır.
- Başarılı ödeme sonrasında sipariş onaylanır.
- Başarısız ödeme durumunda kullanıcıya hata gösterilir ve tekrar deneme imkânı sunulur.

İlk prototipte gerçek ödeme alınmayacaktır.

---

# 6. Navigasyon Yapısı

## 6.1. Müşteri Alt Navigasyonu

- Ana Sayfa
- Keşfet
- Sepet
- Siparişlerim
- Profil

Favoriler ve adres yönetimi Profil bölümünden erişilebilir olmalıdır.

## 6.2. İşletme Alt Navigasyonu

- Ana Sayfa
- Siparişler
- Ürünler
- Mağazam

## 6.3. Rol Bazlı Yönlendirme

Giriş yapan kullanıcının rolüne göre ilgili panel açılmalıdır.

- Müşteri hesabı müşteri paneline.
- İşletme hesabı işletme paneline yönlendirilmelidir.

Yetkisiz kullanıcıların diğer role ait ekranlara erişmesi engellenmelidir.

İlk prototipte bu kontrol yerel oturum ve rol bilgisiyle simüle edilecektir.

---
## 7. Durum Ekranları

Gerekli ekranlarda aşağıdaki durumlar tasarlanmalıdır:

- Yükleniyor.
- Hata.
- Boş liste.
- Başarılı işlem.
- Form doğrulama hatası.
- İnternet bağlantısı gerektiren işlemlerde bağlantı hatası.

Butonlar ve etkileşimli alanlar işlevsiz bırakılmamalıdır.

---

# Ek Kararlar — 11 Kasım 2026

Bu bölüm, proje değerlendirmesinde kabul edilen güncel kararları içerir. Önceki içerik tarihçe korunması amacıyla aynen bırakılmıştır. Önceki bölümlerle çelişki olduğunda bu ek bölüm esas alınır. Açık kararlar, kesinleşmiş gereksinim sayılmaz.

## Kimlik Doğrulama ve Görseller

- Müşteri ve işletme girişleri Firebase Authentication üzerinden e-posta ve şifreyle yapılacaktır. Telefon numarası giriş yöntemi değildir; iletişim bilgisi olarak tutulabilir.
- Şifre sıfırlama e-posta üzerinden yapılacaktır. SMS doğrulaması kullanılmayacaktır.
- Rol ve mağaza sahipliği Firestore erişim kurallarıyla korunacaktır. İşletme yalnızca kendi mağazasının yetkili verilerine erişebilir.
- Ürün ve işletme görsellerinde dosya yüklemek yerine uygulamadaki hazır görsellerden seçim yapılacaktır.
- İlk sürümde yeni işletme bildirimi bulunmayacaktır.

## Kabul, Ret ve Hazırlık Sırası

1. Simüle ödeme başarılı olduğunda ana sipariş ve marketlere ait alt siparişler oluşturulur; market yanıtları beklenir.
2. Bir marketin kabulü tek başına hazırlığı başlatmaz. Bütün marketlerin kabul/ret yanıtları veya yanıt süresi sonuçları beklenir.
3. Bütün marketler kabul ederse hazırlık aşamasına geçilir.
4. Bir veya daha fazla market reddederse müşteri, kalan marketlerle devam etmeye veya tüm siparişi iptal etmeye karar verir. Bu karar verilmeden hazırlık başlamaz.
5. Müşteri devam etmeden önce reddedilen marketler çıkarılır; ürün toplamı, teslimat ücreti ve genel toplam yeniden hesaplanıp gösterilir. Müşteri güncel tutarı onayladığında hazırlık başlar.
6. Bütün marketler reddederse ana sipariş otomatik iptal edilir ve simüle ödeme iadesi kaydedilir.
7. Hazırlık başladıktan sonra marketlerin hazırlama ve hazır olma durumları birbirinden bağımsız ilerler.

## İptal Sınırı

- Müşteri hazırlık başlamadan önce tüm siparişi doğrudan iptal edebilir.
- Hazırlık başladıktan sonra müşteri tarafından doğrudan iptal işlemi yapılamaz. Önceki kurye toplamaya başlayana kadar iptal kuralının yerine bu kural geçerlidir.
- Hazırlık sonrası istisnai iptal, destek ve gerçek iade operasyonları ilk sürüm kapsamı dışındadır.
- İptalde ödeme iadesi yalnızca simüle edilir; gerçek finansal işlem yapılmaz.

## Market Yanıt Süresi

- Market yanıt süresi 10 dakikadır; prototip/demo için yapılandırılabilir tutulabilir.
- Son yanıt zamanı Firestore'da saklanır. Uygulama açıkken veya yeniden açıldığında süre kontrol edilir; süre dolmuş ve yanıtlanmamış alt sipariş ret olarak sonuçlandırılır.
- Süresi dolan siparişlerin geç kabulü Firestore Security Rules ile engellenir; yalnızca cihaz saati ve arayüz kontrolüne güvenilmez.
- Zamanlanmış backend işlemi olmadığı için bütün uygulamalar kapalıyken Firestore kaydının tam onuncu dakikada güncellenmesi garanti edilmez.

## Ürün, Stok ve Geçmiş Kayıtlar

- İlk sürüm ürünleri adet bazlı, sabit birim fiyatlı ve sayısal stoklu olacaktır.
- Tartılı ürünler ve alternatif ürün seçimi ilk sürüm kapsamı dışındadır.
- Sipariş oluşturulurken güncel fiyat ve stok uygunluğu yeniden kontrol edilir. Sepette bulunmak fiyat veya stok garantisi değildir.
- Fiyat değişmişse yeni fiyat ve toplam gösterilir; yeniden müşteri onayı alınır.
- Stok sipariş oluşturulurken ayrılır.
- Ret veya iptalde yalnızca ilgili miktar, yalnızca bir kez geri verilir.
- Eşzamanlı siparişler ve tekrar denemeler dikkate alınır. Aynı işlemin tekrarlanması stoğu ikinci kez azaltmamalı veya artırmamalıdır.
- Bir işletme hesabı tek mağaza yönetir.
- Kapalı mağaza görüntülenebilir; yeni sipariş alamaz. Kapanması daha önce kabul edilmiş siparişlerini iptal etmez.
- Sipariş anındaki ürün adı, birim fiyat, miktar ve teslimat adresi sipariş kaydında korunur.
- Sonraki ürün veya adres düzenlemeleri geçmiş siparişleri değiştirmez.
- Hesap veya ürün silme işlemi geçmiş sipariş kayıtlarını bozmamalıdır.
- Hesap silme ve geçmiş verilerin kişisel bilgilerden arındırılması ayrıntıları ayrıca tanımlanmalıdır.

## Teslimat ve Kurye

- Siparişten market çıkarıldığında teslimat ücreti yeniden hesaplanır. Müşteriye yine tek teslimat ücreti gösterilir.
- Gerçek harita, rota servisi veya maliyet optimizasyonu kullanılmaz; örnek veriler ve yerel hesaplama kullanılır.
- İlk sürümde kurye paneli bulunmayacaktır. Kurye çalışması ve teslimat aşamaları simüle edilecektir; gerçek kurye ataması veya canlı konum takibi yapılmayacaktır.
- Simülasyon, müşteri takibinde açıkça demo olarak belirtilmelidir.

## Kesinleşen Bölge, Ücret ve Simülasyon Kuralları

### Hizmet Bölgesi ve Market Sınırı

- Hizmet alanı tek örnek mahalledir.
- Yalnızca bu bölgedeki adresler ve marketler kullanılır.
- Sipariş başına en fazla 3 market bulunabilir.
- Dördüncü marketten ürün ekleme denemesinde sınır anlaşılır bir mesajla açıklanır.

### Teslimat Ücreti

- Demo hesaplama:
  20 TL + (market sayısı × 5 TL) + (örnek rota kilometresi × 3 TL).
- Rota mesafesi örnek verilerden gelir; harici rota API'si kullanılmaz.
- Market çıkarıldığında kalan marketlere göre rota mesafesi, teslimat ücreti ve genel toplam yeniden hesaplanır.
- Müşteri güncel tutarı onayladıktan sonra hazırlığa geçilir.
- Bu formül gerçek operasyon maliyeti veya rota optimizasyonu iddiası taşımaz.

### Ret Sonrası Müşteri Kararı

- Market yanıtları tamamlandıktan sonra ret nedeniyle karar gerekiyorsa müşteri karar talebi oluşturulur.
- Müşterinin bu andan itibaren 5 dakika içinde devam veya iptal kararı vermesi gerekir.
- Yanıt gelmezse bütün sipariş iptal edilir.
- Bütün marketler reddetmişse müşteri kararı beklenmeden iptal edilir.
- Karar son zamanı Firestore'da saklanır.
- Süre uygulama açıkken veya yeniden açıldığında değerlendirilir.
- Süresi geçmiş devam onayı Firestore Security Rules ile engellenir.
- Bütün uygulamalar kapalıyken kaydın tam beşinci dakikada güncellenmesi garanti edilmez.

### Simüle Ödeme ve İade

- Tam iptalde simüle ödemenin tamamı iade edilir.
- Kısmi devamda simüle ödeme, kesinleşen sipariş toplamıyla uzlaştırılır.
- Gerçek finansal işlem yapılmaz.

### Kurye Simülasyonu

- Bütün kalan marketler hazır olduğunda simülasyon başlar.
- Kurye atanması, ürünlerin toplanması, yolda ve teslim edildi aşamaları gösterilir.
- Aşama süreleri merkezi, yapılandırılabilir örnek değerlerdir.
- Başlangıç zamanı ve gerekli süre bilgileri Firestore'da saklanır.
- Farklı cihazlar ve yeniden açılış aynı zaman çizelgesini esas alır.
- Uygulama yeniden açıldığında geçen süreye göre bulunulan aşama hesaplanır.
- Bu davranış, uygulama kapalıyken çalışan gerçek kurye veya garantili arka plan veritabanı güncellemesi anlamına gelmez.