# Phase 1 Plan: Foundation (Altyapı & Kriptografi)

## Objective
Projenin temel veri katmanını ve şifreleme altyapısını oluşturmak. AES-256-GCM ve PBKDF2 kullanarak, donanımsal güvenlik standartlarına uygun bir `CryptoService` inşa edilecek. 

## Tasks

<task type="auto">
  <name>Paketlerin Eklenmesi</name>
  <files>pubspec.yaml</files>
  <action>
    - `cryptography` paketi AES-256 ve PBKDF2 işlemleri için eklenecek.
    - `bip39` paketi Seed Phrase (Kurtarma Kelimeleri) üretimi için eklenecek.
  </action>
  <verify>flutter pub get çalıştırılır ve hata dönmediğinden emin olunur.</verify>
  <done>Paketler başarıyla pubspec.yaml içerisine dahil edilmiştir.</done>
</task>

<task type="auto">
  <name>Kriptografi Servisinin Yazılması (CryptoService)</name>
  <files>lib/services/crypto_service.dart</files>
  <action>
    - `bip39` kullanarak 12 kelimelik rastgele (mnemonic) seed phrase üreten bir fonksiyon yaz.
    - Kullanıcının girdiği (Master Password) ve tuzu (Salt) alarak PBKDF2 ile AES-256 anahtarı türeten (key derivation) bir fonksiyon oluştur.
    - Metinleri/objeleri AES-256-GCM formatında şifreleyen (encrypt) ve çözen (decrypt) metodlar ekle.
  </action>
  <verify>crypto_service_test.dart dosyasında unit test yazılarak encrypt ve decrypt adımları kontrol edilecek.</verify>
  <done>Şifreleme metodları Master Password ile veri bütünlüğünü bozmadan çalışıyor.</done>
</task>

<task type="auto">
  <name>Güvenli Anahtar Depolaması (SecureStorageService)</name>
  <files>lib/services/secure_storage_service.dart</files>
  <action>
    - `flutter_secure_storage` kullanılarak cihazın (Keystore/Keychain) donanımsal kasasına türetilmiş AES Master Key'ini kaydeden okuyan bir sınıf oluştur.
    - Eğer Keychain'den okuma aşamasında işletim sistemi bir exception fırlatırsa bunu `try-catch` ile yakalayıp `StorageError` dönecek şekilde kurgula (ki UI tarafında Master Password sorulabilsin = Hata Yaklaşımı kararı). 
  </action>
  <verify>Cihaz testinde değerlerin secure_storage'a yazılıp okunduğu kontrol edilecek.</verify>
  <done>Keyler işletim sistemi kasasında okunabilir hale geldi.</done>
</task>

<task type="auto">
  <name>Veritabanı Servisi (DatabaseService)</name>
  <files>lib/services/database_service.dart</files>
  <action>
    - Hive veritabanı kurulumu (initFlutter) yapılacak.
    - `secure_storage_service` sisteminden gelen AES şifresi ile `Hive.openBox(encryptionCipher: HiveAesCipher(key))` mantığıyla veritabanı güvenli açılacak.
  </action>
  <verify>Şifresiz okuma denemesinde kutunun veri döndürmediği, şifreli açıldığında çalıştığı görülecek.</verify>
  <done>Hive veritabanı AES şifreli olarak tamamen operasyonel.</done>
</task>

<task type="auto">
  <name>App Lifecycle 1 Dakika Zamanlayıcısı</name>
  <files>lib/services/app_lifecycle_service.dart</files>
  <action>
    - `WidgetsBindingObserver` dinleyicisi kurularak uygulama `paused` / `inactive` durumuna geçtiğinde 60 saniyelik bir `Timer` başlatılacak.
    - 60 saniye dolduğunda kilit state'i (Riverpod provider) true yapılacak (Kasa kilitlendi).
    - Eğer 60 saniye dolmadan kullanıcı uygulamaya `resumed` ile geri dönerse `Timer` iptal edilecek.
  </action>
  <verify>Timer mantığının testleri mock timer kullanılarak yapılacak.</verify>
  <done>App Lifecycle timeout mantığı (1dk) kurgulandı.</done>
</task>
