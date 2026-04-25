# Backend Workspace

Bu klasor sadece backend servislerini icerir.

## Dizin Yapisi
- `supabase/migrations`: DB schema ve RLS migrationlari
- `supabase/functions`: Edge Function kodlari

## Lokal Gelistirme
1. Supabase CLI kur.
2. `cd supabase`
3. `supabase start`
4. Migration uygula: `supabase db reset`
5. Function test: `supabase functions serve social-login --env-file ../.env.backend`

## Deploy
- Migration deploy: `supabase db push`
- Function deploy:
  - `supabase functions deploy social-login`
  - `supabase functions deploy me`

## Ayrik Deploy Notu
- Backend deploy'u frontend release'inden bagimsiz yurutulur.
- Mobil uygulamalar sadece public endpoint ve anon key ile backend'e baglanir.
