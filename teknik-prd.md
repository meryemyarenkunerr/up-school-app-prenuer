# Eurovision Fan Ekosistemi Teknik PRD v2.0

**Proje:** Eurovision Fan Ekosistemi (The Predictive Core)  
**Doküman Sürümü:** 2.0 (Geliştirici Odaklı Tam Teknik Şartname)  
**Hedef Platform:** Android (Flutter Framework)  
**Backend:** Supabase (PostgreSQL)  
**Cache:** Upstash Redis

---

## 1. Mimari Vizyon ve Teknoloji Yığını

Sistem, Mayıs ayındaki yarışma haftasında oluşacak aşırı yükü (spike) yönetmek üzere sunucusuz (serverless) ve olay güdümlü (event-driven) bir yapıda tasarlanmıştır.

| Katman | Seçilen Teknoloji | Teknik Gerekçe |
| :--- | :--- | :--- |
| Mobil İstemci | Flutter | Tek kod tabanı ile hızlı geliştirme ve gelecekteki iOS uyumluluğu. |
| Durum Yönetimi | Riverpod | Modern, test edilebilir ve düşük boilerplate kod yapısı. |
| Veritabanı / Auth | Supabase | PostgreSQL gücü, yerleşik Auth ve Edge Functions desteği. |
| Önbellek (Cache) | Upstash Redis | Yüksek trafik anlarında veritabanı yazma yükünü hafifletme. |
| Yapay Zeka | OpenAI GPT-4o-mini | Haber özetleme ve kategorizasyon süreçlerinde düşük maliyet ve yüksek hız. |
| Hata İzleme | Firebase Crashlytics | Gerçek zamanlı hata raporlama ve uygulama kararlılığı takibi. |

---

## 2. Ekran ve Kullanıcı Deneyimi Detayları

### 2.1. Splash ve Kimlik Doğrulama
* **Splash Screen:** Uygulama açılışında Riverpod üzerinden oturum durumu (authProvider) kontrol edilir. Token geçerli ise ana ekrana, değilse giriş ekranına yönlendirilir.
* **Authentication:** Sadece Google ve Apple üzerinden sosyal giriş imkanı sunulur. Başarılı girişte cihazın hash bilgisi (device_hash) alınarak profil tablosuna kaydedilir.

### 2.2. Ana Haber Akışı (Home) - Tab 1
* **İstatistik Paneli:** Ekranın üst kısmında oylama sonuçlarını yansıtan dinamik, borsa tipi grafikler yer alır.
* **Haber Akışı:** AI tarafından özetlenmiş haber kartları sonsuz kaydırma (Infinite Scroll) ile sunulur. Tek seferde 15 kayıt çekilir (Pagination).
* **Etkileşim:** Haber kartları üzerinde bulunan reaksiyon butonları ile anlık oylama yapılır.

### 2.3. Tahmin Turnuvası (Predictions) - Tab 2
* **Sıralama Arayüzü:** Kullanıcılar sürükle-bırak (Drag & Drop) yöntemiyle 26 ülkeyi favori sıralamalarına göre dizerler.
* **Kilit Mekanizması:** Final saati geldiğinde sıralama özelliği sunucu taraflı ve istemci taraflı (read-only state) olarak kilitlenir.

### 2.4. Liderlik Tablosu (Leaderboard) - Tab 3
* **Sıralama Mantığı:** Global sıralama listesinde kullanıcının kendi sırası en üstte sabit (Sticky Header) olarak gösterilir.

---

## 3. Veritabanı Şeması (PostgreSQL)

### 3.1. Tablo: profiles
* `id` (uuid): Primary Key.
* `device_hash` (varchar): Anti-fraud ve cihaz banlama takibi.
* `nationality` (varchar): ISO 3166-1 alpha-2 kodu.
* `total_score` (int): Turnuva puan birikimi.
* `role` (enum): 'free', 'premium' rolleri.

### 3.2. Tablo: news_articles
* `id` (uuid): Primary Key.
* `external_url` (text): Benzersiz haber linki.
* `summary_json` (jsonb): Haber başlığı ve özet maddeleri.
* `category` (enum): Haber türü (Resmi, Dedikodu vb.).

### 3.3. Tablo: predictions
* `user_id` (uuid): Foreign Key.
* `event_year` (int): Yarışma yılı.
* `ordered_list` (jsonb): Ülke kodlarını içeren sıralı dizi.

---

## 4. Kritik Servisler ve İş Kuralları

### 4.1. RSS Scraper ve AI İşleme
Supabase Edge Function üzerinden çalışan cron-job, haber kaynaklarını saatlik tarar. Yeni içerikler OpenAI API'sine gönderilerek JSON formatında özetlenir ve veritabanına yazılır.

### 4.2. Güvenlik ve Anti-Fraud (Shadowban)
Kullanıcının IP adresi üzerinden konumu doğrulanır. Eğer kullanıcı kayıtlı ülkesi dışından veya şüpheli bir IP (VPN/Proxy) üzerinden oy kullanmaya çalışırsa, oyları veritabanında `is_valid: false` olarak işaretlenir. Kullanıcı arayüzünde herhangi bir hata mesajı verilmez.

### 4.3. Yük Yönetimi (Batch Processing)
Final gecesi oluşacak yoğunlukta oylar doğrudan veritabanına yazılmaz. Veriler Upstash Redis üzerinde toplanır (Increment). Her 15 saniyede bir çalışan worker, Redis'teki toplamları ana veritabanına toplu (bulk) şekilde aktarır.

---

## 5. Kullanıcı Hikayeleri ve Kabul Kriterleri

### US 1: Güvenli Reaksiyon Verme
* **GIVEN:** Kullanıcı haber akışı ekranındadır.
* **WHEN:** Beğeni butonuna saniyede 3'ten fazla tıklama yapılır.
* **THEN:** İstemci tarafındaki debouncing mekanizması fazla istekleri yutar ve sunucuya sadece limit dahilinde istek gönderilir.

### US 2: Tahmin Kilitleme
* **GIVEN:** Sistem saati resmi final saatini geçmiştir.
* **WHEN:** Kullanıcı tahmin listesini değiştirmeye çalışır.
* **THEN:** Liste elemanları sürüklenemez hale gelir ve veritabanı yazma yetkisi sunucu tarafından (RLS politikası ile) reddedilir.

---

## 6. Hata Yönetimi
* **Offline Mod:** İnternet yoksa yerel önbellekteki veriler gösterilir.
* **Optimistic UI:** Oylama butonuna basıldığında sonuç beklenmeden başarılı animasyonu gösterilir. Sunucudan hata dönerse durum eski haline getirilir (Rollback).