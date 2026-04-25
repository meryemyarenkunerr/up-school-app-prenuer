# US3 - Canli Oylama Gostergesi

## Hedef
Ana ekranda ulkelerin oy egilimlerini gecikmesi dusuk bicimde gostermek.

## Teknik Kapsam
- Ust bolumde dinamik trend chart
- Polling veya websocket ile periyodik guncelleme
- Baglanti kopmasinda son bilinen veri fallback'i

## Veri Modeli
- `country_trends` (onerilen yeni tablo/stream)
  - `country_code`
  - `score`
  - `trend_delta`
  - `updated_at`
  - `source_confidence`

## API / Servis Sozlesmesi
- Polling secenegi: `GET /trends/live?since=<timestamp>`
- Websocket secenegi: `ws /trends/live`
  - Event: `trend_snapshot`, `trend_delta`

## Uygulama Adimlari
1. Trend normalizasyon kurali belirle (farkli kaynaklari tek skora cevir).
2. Mobilde chart modeli icin immutable state tasarla.
3. Veri akisi katmanina reconnect + exponential backoff ekle.
4. UI'da loading, stale-data ve error state'lerini ayir.
5. Son gecerli snapshot'i local cache'te tut.

## Test Plani
- Birim: trend normalization fonksiyonlari.
- Entegrasyon: reconnect, stale data, duplicate event handling.
- Gorsel regresyon: chart render ve label hizalamalari.
- Dayaniklilik: zayif ag simulasyonunda donma/cokme testi.

## Definition of Done
- Trend paneli canli veri ile guncellenir
- Baglanti kopmasinda son veri korunur
- Reconnect akisi veri tutarliligini bozmaz
- UI state'leri (loading/error/stale) net ayrilir
