# US4 - Tahmin Turnuvasi (26 Ulke Siralama + Kilit)

## Hedef
Kullanici final oncesi tahminini duzenleyebilmeli, final saatinden sonra degistirememeli.

## Teknik Kapsam
- 26 ulke drag-drop siralama
- Draft kaydetme ve tekrar yukleme
- Server-time bazli lock
- Lock sonrasi istemci read-only + sunucu yazma reddi

## Veri Modeli
- `predictions.user_id` (uuid)
- `predictions.event_year` (int)
- `predictions.ordered_list` (jsonb, 26 eleman)
- Onerilen ek alanlar:
  - `updated_at` (timestamptz)
  - `locked_at` (timestamptz, nullable)

## API / Servis Sozlesmesi
- `GET /predictions/:year`
  - Response: `ordered_list`, `is_locked`, `server_time`, `lock_time`
- `PUT /predictions/:year`
  - Request: `ordered_list`
  - Locked ise `423 Locked` veya esdeger hata kodu

## Is Kurali
- Lock karari yalniz sunucu saatine gore verilir.
- `ordered_list` icinde ulke kodlari:
  - 26 adet olmali
  - tekil olmali
  - whitelist'teki ulkelerden olusmali

## Uygulama Adimlari
1. Drag-drop listeyi local state + local cache ile yonet.
2. Kaydetmede once istemci validasyonu, sonra backend validasyonu yap.
3. Lock penceresi icin final saati konfigunu merkezi tut.
4. RLS/DB policy ile lock sonrasi update'i server tarafinda kapat.
5. UI'da lock badge + read-only durumu goster.

## Test Plani
- Birim: liste validasyonu (uzunluk/tekillik/whitelist).
- Entegrasyon: T-1dk, T, T+1dk update denemeleri.
- E2E: sirala -> kaydet -> lock sonrasi surukleme engeli.

## Definition of Done
- Final oncesi duzenleme ve kaydetme stabil
- Final sonrasi istemci ve sunucu duzeyinde kilit aktif
- Kilit bypass denemeleri basarisiz
