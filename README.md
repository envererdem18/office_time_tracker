# Ofis Giriş-Çıkış Takip Uygulaması

Bu uygulama, Flutter ile geliştirilmiş modern ve kullanıcı dostu bir ofis giriş-çıkış takip sistemidir.

## ✨ Özellikler

### 🏠 Ana Sayfa
- **Giriş/Çıkış Butonları**: Büyük, görsel butonlarla kolay giriş-çıkış işlemleri
- **Durum Takibi**: Günlük giriş-çıkış durumunuzun anlık görünümü
- **Akıllı Bildirimler**: Durumunuza göre özelleştirilmiş mesajlar

### 📊 Geçmiş Kayıtları
- **Tarih Filtresi**: Esnek tarih aralığı seçimi
- **Detaylı Liste**: Giriş/çıkış saatleri ve toplam çalışma süreleri
- **Özet İstatistikler**: Toplam gün, saat ve ortalama çalışma süreleri
- **Kayıt Detayları**: Tıklayarak detaylı bilgi görüntüleme

### 📈 İstatistikler
- **Çalışma Saatleri Grafiği**: Günlük çalışma saatlerinizin çizgi grafiği
- **Giriş Saatleri Grafiği**: Ofise giriş saatlerinizin trend analizi
- **Dağılım Grafiği**: Çalışma saatlerinizin kategorik dağılımı
- **Esnek Filtreleme**: Tarih aralığı veya tüm zamanlar seçeneği

## 🛠 Kullanılan Teknolojiler

- **Flutter**: Modern mobil uygulama geliştirme framework'ü
- **Riverpod**: Güçlü state management çözümü
- **Hive**: Hızlı ve hafif yerel veritabanı
- **FL Chart**: Profesyonel grafik ve chart widget'ları
- **Go Router**: Gelişmiş navigasyon yönetimi

## 📱 Kurulum

### Gereksinimler
- Flutter SDK (3.9.0 veya üzeri)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator (iOS için) / Android Emulator (Android için)

### Adımlar
1. Projeyi klonlayın:
   ```bash
   git clone [repo-url]
   cd office_time_tracker
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Hive code generation çalıştırın:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## 📐 Mimari

Uygulama, temiz mimari prensipleri gözetilerek geliştirilmiştir:

```
lib/
├── models/          # Veri modelleri (Hive objects)
├── services/        # İş mantığı servisleri
├── providers/       # Riverpod state management
├── pages/          # UI sayfaları
├── widgets/        # Yeniden kullanılabilir UI bileşenleri
├── theme/          # Uygulama teması ve stilleri
├── router/         # Navigasyon yapılandırması
└── main.dart       # Ana giriş noktası
```

## 🎨 Tasarım

- **Pastel Renk Paleti**: Göze hoş, modern pastel renkler
- **Material 3 Design**: Google'ın en son tasarım dili
- **Responsive Layout**: Farklı ekran boyutlarına uyumlu
- **Accessibility**: Erişilebilirlik standartlarına uygun

## 🔧 Özelleştirme

### Tema Değişiklikleri
`lib/theme/app_theme.dart` dosyasından renkleri ve stilleri özelleştirebilirsiniz.

### Yeni Özellikler Ekleme
1. Model değişiklikleri: `lib/models/`
2. İş mantığı: `lib/services/`
3. State management: `lib/providers/`
4. UI: `lib/pages/` ve `lib/widgets/`

## 📊 Veri Yönetimi

Uygulama, tüm verileri cihazda yerel olarak Hive veritabanında saklar:
- **Güvenli**: Veriler sadece cihazınızda kalır
- **Hızlı**: Yerel veritabanı ile anlık erişim
- **Çevrimdışı**: İnternet bağlantısı gerektirmez

## 🚀 Gelecek Özellikler

- [ ] Veri dışa aktarma (Excel, PDF)
- [ ] Bildirim sistemi
- [ ] Dark mode desteği
- [ ] Çoklu dil desteği
- [ ] Bulut senkronizasyonu
- [ ] Takım yönetimi

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📞 İletişim

Sorularınız için issue açabilir veya doğrudan iletişime geçebilirsiniz.
