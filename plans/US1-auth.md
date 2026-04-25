# US1 - Hesap Olusturma ve Giris (Google/Apple)

## Hedef
Kullanici 1-2 dokunusla oturum acmali, ilk giriste profili otomatik olusmali.

## Teknik Kapsam
- Flutter: Google Sign-In ve Sign in with Apple akislari
- Supabase Auth: provider token dogrulama ve session olusturma
- PostgreSQL `profiles`: ilk giriste kayit acma/guncelleme
- Guvenlik: `device_hash` kaydi, token guvenli saklama

## Veri Modeli
- `profiles.id` (uuid, auth user id ile birebir)
- `profiles.device_hash` (varchar)
- `profiles.nationality` (varchar, opsiyonel ilk surumde)
- `profiles.role` (enum: `free`, `premium`)
- `profiles.total_score` (int, default 0)

## API / Servis Sozlesmesi
- `POST /auth/social-login`
  - Request: `provider`, `id_token`, `device_hash`
  - Response: `access_token`, `refresh_token`, `profile`
- `GET /me`
  - Auth zorunlu
  - Kullanici profilini dondurur

## Uygulama Adimlari
1. Flutter auth katmaninda provider secimi + token alma.
2. Backend'de provider token verify ve user upsert akisi.
3. Ilk giriste `profiles` tablosuna default alanlarla insert.
4. Session tokenlarini secure storage'a kaydetme.
5. Splash ekraninda auth kontrolu ve route yonlendirme.
6. Hata durumlari (iptal, gecersiz token, network) icin ayrik state.

## Test Plani
- Birim: auth service, token parser, secure storage adaptoru.
- Entegrasyon: mock provider -> backend verify -> profile upsert.
- E2E: ilk giris, tekrar giris, cikis+giris, provider iptal.

## Definition of Done
- Google ve Apple ile basarili login
- Ilk login sonrasi profil olusur
- Tekrar login'de ayni profile baglanir
- Basarisiz provider durumlari kullanıcıya kontrollu mesajla doner
