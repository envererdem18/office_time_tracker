# **Ofis Giriş-Çıkış Takip Uygulaması Görev Listesi**

Bu belge, Flutter ile geliştirilecek olan ofis giriş-çıkış takip uygulamasının adımlarını içermektedir.

## **1\. Proje Kurulumu ve Yapılandırma**
 
* \[ \] pubspec.yaml dosyasına aşağıdaki paketleri ekle:  
  * flutter\_riverpod (State Management)  
  * go\_router (Navigation)  
  * hive & hive\_flutter (Local Storage)  
  * fl\_chart (Charts)  
  * path\_provider (Hive için dosya yolunu bulmak amacıyla)  
* \[ \] main.dart dosyasını ana uygulama yapısını kuracak şekilde düzenle.  
* \[ \] Hive'ı başlatmak için main fonksiyonu içerisinde gerekli konfigürasyonları yap.  
* \[ \] GoRouter için temel rota yapılandırmasını oluştur (ShellRoute ile BottomNavigationBar yapısı).

## **2\. Veri Modeli ve Depolama (Hive)**

* \[ \] Giriş ve çıkış bilgilerini tutacak bir CheckInOut adında bir Hive object'i (data model) oluştur. Model şunları içermeli:  
  * DateTime date (Kaydın ait olduğu gün)  
  * DateTime? checkInTime (Giriş saati)  
  * DateTime? checkOutTime (Çıkış saati)  
* \[ \] Oluşturulan CheckInOut modeli için TypeAdapter generate et.  
* \[ \] Hive üzerinde veri ekleme, okuma, güncelleme ve silme işlemlerini yönetecek bir DatabaseService sınıfı oluştur.

## **3\. State Management (Riverpod)**

* \[ \] DatabaseService'i uygulama genelinde kullanılabilir kılmak için bir Provider oluştur.  
* \[ \] Tüm giriş-çıkış kayıtlarını tutacak ve yönetecek bir checkInOutListProvider (FutureProvider veya NotifierProvider) oluştur.  
* \[ \] Sayfalar arası filtreleme (tarih aralığı gibi) durumlarını yönetecek Provider'lar oluştur.  
* \[ \] O günkü giriş/çıkış durumunu kontrol etmek için bir todayProvider oluştur.

## **4\. Uygulama Mimarisi ve Tasarım**

* \[ \] Uygulama genelinde kullanılacak pastel renk paletini, fontları ve temayı MaterialApp içinde tanımla.  
* \[ \] Minimalist ve şık bir Card widget'ı tasarla (History sayfasındaki listelemeler için).  
* \[ \] Uygulama genelinde kullanılacak standart bir Button widget'ı tasarla.  
* \[ \] Home, History ve Statistics sayfaları arasında geçiş yapacak bir BottomNavigationBar içeren bir ShellRoute (ana iskelet) sayfası oluştur.

## **5\. Home Sayfası**

* \[ \] HomePage UI'ını tasarla.  
* \[ \] Ortada üst üste duracak iki adet büyük, kare şeklinde buton ekle: "Giriş Yap" ve "Çıkış Yap".  
* \[ \] "Giriş Yap" butonunu yeşil, "Çıkış Yap" butonunu kırmızı renkte tasarla.  
* \[ \] Butonların onPressed olaylarını Riverpod provider'ları ile entegre et:  
  * "Giriş Yap": O gün için yeni bir CheckInOut kaydı oluşturur ve checkInTime'ı o anki zaman olarak kaydeder.  
  * "Çıkış Yap": O günkü kaydı bulur ve checkOutTime'ı o anki zaman olarak günceller.  
* \[ \] Butonların durumunu kontrol et:  
  * O gün için checkInTime kaydedilmişse "Giriş Yap" butonunu devre dışı bırak (disable).  
  * O gün için checkOutTime kaydedilmişse "Çıkış Yap" butonunu devre dışı bırak.  
* \[ \] AppBar'a History sayfasına yönlendirme yapacak bir ikon butonu ekle.

## **6\. History Sayfası**

* \[ \] HistoryPage UI'ını tasarla.  
* \[ \] Tarih aralığı seçimi için iki adet Calendar veya DatePicker benzeri (ama dialog olmayan) custom bir filtreleme bileşeni oluştur.  
* \[ \] Hive'dan tüm kayıtları çek ve seçilen tarih aralığına göre filtreleyerek bir ListView içinde listele.  
* \[ \] Her bir liste elemanını (tasarlanan custom card ile) aşağıdaki bilgileri gösterecek şekilde oluştur:  
  * Tarih (ör: 18 Eylül 2025, Perşembe)  
  * Giriş Saati (ör: 09:15)  
  * Çıkış Saati (ör: 18:30)  
  * Ofiste Geçirilen Süre (Duration) (ör: 9 saat 15 dakika)  
* \[ \] Eğer hiç kayıt yoksa veya seçilen aralıkta kayıt bulunmuyorsa, ekranda bilgilendirici bir "Kayıt bulunamadı" mesajı göster.

## **7\. İstatistik Sayfası**

* \[ \] StatisticsPage UI'ını tasarla.  
* \[ \] History sayfasındakine benzer bir tarih aralığı filtresi ve "Tüm Zamanlar" seçeneği ekle.  
* \[ \] Riverpod provider'larını kullanarak filtrelenen veriyi fl\_chart'a hazır hale getir.  
* \[ \] Aşağıdaki grafikleri fl\_chart paketi ile oluştur:  
  * \[ \] **Line Chart:** Günlere göre ofiste geçirilen toplam süreyi gösteren bir çizgi grafik. (X ekseni: Günler, Y ekseni: Saat).  
  * \[ \] **Line Chart:** Günlere göre ofise giriş saatlerinin dağılımını gösteren bir çizgi grafik. (X ekseni: Günler, Y ekseni: Saat).  
  * \[ \] **Pie Chart:** Ofiste geçirilen süreleri kategorilere ayıran bir pasta grafik (ör: "\<8 saat", "8-9 saat", "\>9 saat").  
* \[ \] Tarih filtresi değiştiğinde tüm grafiklerin anlık olarak güncellenmesini sağla.

## **8\. Son Dokunuşlar**

* \[ \] Uygulama ikonunu oluştur ve ekle.  
* \[ \] Splash screen ekle.  
* \[ \] Tüm sayfalarda ve durumlarda (veri yüklenirken, veri yokken vb.) UI'ın düzgün göründüğünü kontrol et.  
* \[ \] Kodun okunabilirliğini artırmak için gerekli yerlere yorum satırları ekle.  
* \[ \] Performans testleri ve optimizasyon yap.