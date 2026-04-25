# US5 - Liderlik Tablosu ve Puanlama

## Hedef
Gercek final sonucuna gore deterministik puan hesaplamak ve kullanicinin kendi sirasini en ustte gostermek.

## Teknik Kapsam
- Final ranking ingest (resmi sonuc)
- Tahmin vs gercek sonuc karsilastirma
- Global leaderboard + pinned current user satiri

## Veri Modeli
- `results` (onerilen yeni tablo)
  - `event_year`, `ordered_list`, `published_at`
- `profiles.total_score` (kumulatif skor)
- `prediction_scores` (onerilen yeni tablo)
  - `user_id`, `event_year`, `score`, `computed_at`

## Skorlama Kurali (Taslak)
- Her ulke icin `abs(predicted_rank - actual_rank)` cezasi hesapla.
- Toplam ceza ne kadar dusukse skor o kadar yuksek olsun.
- Esitlikte tie-break:
  1) Top 3 tam eslesme sayisi
  2) Son guncelleme zamani (erken kaydeden ustte)

## API / Servis Sozlesmesi
- `POST /admin/results/:year`
  - Final sonucunu sisteme alir ve batch score job tetikler
- `GET /leaderboard/:year?cursor=<id>&limit=50`
  - Response: `pinned_me`, `items[]`, `next_cursor`

## Uygulama Adimlari
1. Sonuc ingest isini idempotent hale getir.
2. Batch scorer worker ile tum kullanicilar icin skor hesapla.
3. Leaderboard sorgusunda `pinned_me` + sayfali listeyi birlestir.
4. Mobilde pinned satiri listeden gorsel olarak ayir.

## Test Plani
- Birim: skor algoritmasi ornek veri setleri.
- Entegrasyon: sonuc ingest -> score batch -> leaderboard cikti.
- Yuk testi: buyuk kullanici setinde sorgu gecikmesi.

## Definition of Done
- Skorlama deterministik ve tekrar edilebilir
- Kullanici kendi sirasini en ustte gorur
- Leaderboard sayfalama yuk altinda stabil kalir
