# Frontend Workspace

Bu klasor sadece istemci uygulamalarini icerir.

## Dizin Yapisi
- `mobile/app`: Flutter mobil istemci (Android simdi, iOS sonraki asama)

## Lokal Calistirma (Flutter)
1. Flutter SDK kurulu oldugunu dogrula.
2. `cd mobile/app`
3. `flutter pub get`
4. `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Ayrik Deploy Yaklasimi
- Frontend deploy'u backend'den bagimsiz yapilir.
- Build artifact:
  - Android: `flutter build apk` veya `flutter build appbundle`
  - iOS: `flutter build ios` (macOS + Xcode)
