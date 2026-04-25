# US7 - Cevrimdisi Deneyim ve Dayaniklilik

## Hedef
Baglanti kesintilerinde temel akislar gorulebilir kalmali; final gecesi yukte sistem stabil olmali.

## Teknik Kapsam
- Offline cache (haberler + tahmin listesi)
- Online olunca guvenli senkronizasyon
- Final gecesi yuk yonetimi ve gozlemlenebilirlik

## Mimari Kararlar
- Flutter local store: feed ve prediction snapshot cache
- Redis ile burst trafik absorb etme (increment + batch flush)
- Crashlytics + metrik dashboard ile canli takip

## Offline Stratejisi
- Haberler:
  - Son basarili sayfalar localde tutulur
  - TTL gecince stale etiketiyle gosterilir
- Tahmin listesi:
  - Son kayit localde tutulur
  - Online oldugunda server ile conflict resolution (server lock onceligi)

## Senkronizasyon Kurali
- Queue tabanli retry:
  - Exponential backoff
  - Idempotency key ile cift yazma engeli
- Lock aktifse queue'daki prediction update'leri iptal edilir

## Performans / Operasyon Adimlari
1. Kritik endpoint'ler icin p95/p99 latency hedefleri belirle.
2. Feed ve leaderboard sorgularinda index ve pagination optimizasyonu yap.
3. Final gecesi icin load test senaryolari hazirla (binlerce eszamanli).
4. Alarm kurallari: hata orani, timeout orani, queue backlog.

## Test Plani
- Offline/online toggle testleri.
- Gecikmeli ag ve paket kaybi simulasyonlari.
- Stres testi: ani trafik artisinda hata orani ve yanit suresi.
- Kaos testi: websocket/polling kesintisi ve toparlanma suresi.

## Definition of Done
- Offline durumda son bilinen veriler gorulebilir
- Reconnect sonrasi veri tutarliligi korunur
- Final gecesi hedef hata orani esigi asilmadan sistem calisir
- Operasyon panelleri ve alarm seti aktif durumda
