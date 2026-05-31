# İslam Dünyam

Flutter tabanlı, Android için optimize edilmiş İslami yardımcı uygulama.

## Özellikler

- **Kıble Pusulası**: Cihaz pusulası ve GPS kullanarak gerçek zamanlı kıble yönü tespiti.
- **En Yakın Cami Bulucu**: Google Maps API entegrasyonu ile konumunuza en yakın camileri listeleyip haritada gösterir.
- **Dijital Zikirmatik**: Pratik ve görsel zikir sayacı. Farklı zikirler ve hedef sayılar seçilebilir.
- **Kazanım & Borç Takibi**: Namaz vakitleri için akıllı bildirim sistemi. Her namaz vaktinden 15 dk sonra "Namazınızı kıldınız mı?" bildirimi gönderir.
  - **Evet** (+10 puan)
  - **Hayır** veya yanıtsız bırakılırsa o namaz vakti için +1 borç kaydedilir.
  - Her namaz vakti (Sabah, Öğle, İkindi, Akşam, Yatsı) bağımsız borç takibine sahiptir.

## Kurulum

### 1. Flutter SDK Kurulumu
Flutter SDK'yı yükleyin: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### 2. Projeyi Klonlayın
```bash
git clone <repo-url>
cd proje-ad-islam-dnyam
```

### 3. Bağımlılıkları İndirin
```bash
flutter pub get
```

### 4. Google Maps API Anahtarı
`lib/services/mosque_service.dart` ve `android/app/src/main/AndroidManifest.xml` dosyalarındaki `BURAYA_GOOGLE_MAPS_API_KEY_YAZILACAK` yer tutucusunu kendi Google Cloud API anahtarınızla değiştirin.

### 5. Android İçin Derleyin
```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

## Android Ayarları

`android/local.properties` dosyasında Flutter SDK yolunuzu ayarlayın:
```properties
flutter.sdk=C:\\flutter
```

## Kullanılan Paketler

| Paket | Amaç |
|-------|------|
| flutter_compass | Manyetik kıble yönü |
| geolocator | GPS konum servisi |
| google_maps_flutter | Harita ve cami gösterimi |
| flutter_local_notifications | Namaz bildirimleri |
| flutter_background_service | Arka plan namaz takibi |
| shared_preferences | Yerel veri saklama |
| permission_handler | Runtime izinleri |
| http | API istekleri |
| flutter_bloc | State management |

## Minimum Gereksinimler

- Android SDK 21+
- Flutter 3.16+
- Dart 3.0+

## Lisans

MIT License
