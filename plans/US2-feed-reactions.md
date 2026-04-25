# US2 - Haber Akisi, Ozet Icerik, Emoji Reaksiyon

## Hedef
Kullanici haberin ana fikrini hizlica gorebilmeli ve karta emoji reaksiyon verebilmeli.

## Teknik Kapsam
- Feed endpoint'i ile 15 kayitlik sayfalama
- Kartlarda AI ozet (`summary_json`) ve kategori
- Infinite scroll + lazy load
- Emoji reaksiyonlarinda optimistic UI + rollback

## Veri Modeli
- `news_articles.id` (uuid)
- `news_articles.external_url` (text, unique)
- `news_articles.summary_json` (jsonb: `title`, `bullets[]`)
- `news_articles.category` (enum)
- `news_reactions` (onerilen yeni tablo)
  - `user_id`, `article_id`, `emoji`, `created_at`
  - `UNIQUE(user_id, article_id, emoji)` ile cift sayim engeli

## API / Servis Sozlesmesi
- `GET /news?cursor=<id>&limit=15`
  - Response: `items[]`, `next_cursor`
- `POST /news/:id/reactions`
  - Request: `emoji`
  - Response: `accepted`, `reaction_totals`

## Uygulama Adimlari
1. Feed sorgusunu cursor-based pagination ile kurgula.
2. Flutter tarafinda list virtualization ve prefetch esigi ekle.
3. Reaksiyon butonlarini debounced event ile bagla.
4. Optimistic state guncelle; hata donerse local rollback yap.
5. Offline cache'e son yuklenen feed sayfalarini yaz.
6. Duplicate reaction denemelerinde idempotent cevap don.

## Test Plani
- Birim: feed mapper, summary parser, reaction state reducer.
- Entegrasyon: pagination sonu, ayni emoji tekrar gonderimi.
- E2E: scroll -> yeni sayfa -> reaksiyon -> rollback senaryosu.
- Performans: buyuk feed listesinde frame drop olcumleri.

## Definition of Done
- 15'li pagination sorunsuz calisir
- Infinite scroll janksiz deneyim verir
- Emoji reaksiyonlari cift sayim uretmez
- Optimistic UI + rollback mekanizmasi dogru calisir
