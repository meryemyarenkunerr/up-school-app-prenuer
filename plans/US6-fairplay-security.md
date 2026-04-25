# US6 - Adil Oyun ve Guvenlik (Shadowban + Anti-Spam)

## Hedef
Sistem bot/abuse etkisini azaltirken normal kullanici deneyimini bozmamali.

## Teknik Kapsam
- Shadowban karar motoru
- VPN/Proxy ve anormal trafik sinyalleri
- Reaksiyon endpoint'lerinde hizli tiklama filtreleme

## Veri Modeli
- `fraud_events` (onerilen yeni tablo)
  - `user_id`, `ip_hash`, `device_hash`, `signal_type`, `risk_score`, `created_at`
- `votes.is_valid` (bool, default true)
- `reaction_events` (ham event, rate-limit analizine uygun)

## Is Kurallari
- Risk skoru esigi asilirsa oylar `is_valid=false` isaretlenir.
- UI tarafinda hata gostermeden normal akisa devam edilir.
- Saniyede 3 ustu ayni reaction olayi debounced/rate-limited edilir.

## API / Servis Sozlesmesi
- `POST /news/:id/reactions`
  - Abuse middleware: rate limit + device fingerprint kontrolu
- `POST /votes`
  - Fraud evaluator sonucu `accepted=true` olsa da arka planda `is_valid` false olabilir

## Uygulama Adimlari
1. Istek oncesi istemci debouncing ekle.
2. Sunucu tarafinda sliding-window rate limiter kur.
3. Fraud evaluator fonksiyonunu merkezi middleware yap.
4. Shadowban kararlarini audit log'a yaz.
5. Operasyon paneli icin alarm esikleri tanimla.

## Test Plani
- Birim: risk score hesaplamasi.
- Entegrasyon: VPN/proxy isaretli trafik simulasyonu.
- Regresyon: normal kullanicida false positive orani.
- Guvenlik testi: brute click ve replay denemeleri.

## Definition of Done
- Bot benzeri trafik skora anlamli etki edemez
- Hizli tiklamalarda gereksiz istekler filtrelenir
- False positive oranlari izlenebilir seviyede tutulur
