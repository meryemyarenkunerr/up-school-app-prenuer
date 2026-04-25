# Eurovision Fan Ecosystem Monorepo

Bu repo frontend ve backend katmanlarini ayrik yonetmek icin düzenlenmistir.

## Klasorler
- `frontend/`: istemci uygulamalari (Flutter mobil)
- `backend/`: Supabase tabanli backend (DB + Edge Functions)
- `docs/`: user story tabanli teknik implementasyon dokumanlari

## Frontend Kurulum
- `cd frontend/mobile/app`
- `flutter pub get`
- `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Backend Kurulum
- `cd backend/supabase`
- `supabase start`
- `supabase db reset`
- `supabase functions serve social-login --env-file ../.env.backend`

## Deploy Modeli
- Frontend ve backend deployment surecleri birbirinden bagimsizdir.
- iOS ve Android uygulamalari ayni backend API yapisini kullanir.
