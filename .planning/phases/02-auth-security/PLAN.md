# Phase 2 Plan: Auth & Security (Güvenlik)

## Objective
Kullanıcının uygulamaya ilk girişinde "Master Password" oluşturması, bu şifreden üretilen AES anahtarının cihazın güvenli hafızasına yazılması ve sonraki girişlerde (Login) parmak izi/yüz tanıma (local_auth) ve Master Password ile sisteme erişmesi. 

## Tasks

<task type="auto">
  <name>Gerekli Paketlerin Eklenmesi (local_auth, etc.)</name>
  <files>pubspec.yaml</files>
  <action>
    - `local_auth` paketi daha önceden eklendiyse kontrol edilecek.
  </action>
  <verify>flutter pub get ve `local_auth` mevcudiyeti sağlanacak.</verify>
  <done>Paket eklendi.</done>
</task>

<task type="auto">
  <name>Biometric (Local Auth) Servisinin Yazılması</name>
  <files>lib/services/biometric_service.dart</files>
  <action>
    - `local_auth` nesnesinden cihazın biyometrik destek durumunu kontrol eden metod.
    - `authenticate()` ile kullanıcıdan biyometrik girdi talep edilmesi ve boolean sonuç dönmesi.
    - Cihaz bazlı ayarları tutmak (kullanıcı biometrik girmek istiyor mu) için Provider tabanlı LocalStorage servisinden okuyup/yazdırma fonksiyonu eklenebilir. 
  </action>
  <verify>Cihaz yeteneklerinin boolean testini yapan fonksiyon yazılacak ve State yönetiminde kullanılacak.</verify>
  <done>Biometrics hazır.</done>
</task>

<task type="auto">
  <name>Auth State ve Provider'larının Kurulması (Riverpod)</name>
  <files>lib/providers/auth_provider.dart</files>
  <action>
    - `enum AuthState { firstTime, unauthenticated, authenticated }` olacak şekilde uygulama durumunu belirle.
    - Kullanıcının şifresini henüz kurup kurmadığını Secure Storage'daki "key" varlığından ayırt eden Initializer Provider yazılacak.
    - `login(String password)` fonksiyonu eklenecek, bu fonksiyon `crypto_service` ve `database_service` vasıtasıyla Vault'u açmaya çalışacak. Başarılı olursa state'i `authenticated` yapacak.
  </action>
  <verify>Riverpod testte Auth state geçişleri denenecek.</verify>
  <done>Auth mantığı state ağacına yerleşti.</done>
</task>

<task type="auto">
  <name>Özel Neumorphic Elementlerin Hazırlanması</name>
  <files>lib/theme/neumorphic_styles.dart, lib/widgets/neumorphic_container.dart, lib/widgets/neumorphic_button.dart, lib/widgets/neumorphic_textfield.dart</files>
  <action>
    - Uygulamanın tüm tasarımını kontrol eden, Neumorphic "iç boşluk" ve "dışa vurum" gölge objelerini (BoxShadow) component haline getir.
    - Buton, text input gibi UI widget'ları üretilecek.
  </action>
  <verify>Kullanıcı etkileşimine tepki verecek gölgeler kontrol edilecek.</verify>
  <done>Neumorphic UI hazır.</done>
</task>

<task type="auto">
  <name>Onboarding (Kurulum) Ekranı ve Router</name>
  <files>lib/screens/onboarding/onboarding_screen.dart, lib/router.dart</files>
  <action>
    - Kullanıcı ilk açtıysa GoRouter ile `/onboarding` adresine yönelecek.
    - Şifre oluşturma ekranı, şifre zorluğu barı.
    - "Generate Seed Phrase" (12 kelime) ve onay (Checkbox).
    - Oluşturulan bu master şifrenin AES-256 olarak PBKDF2 ile encode edilip Secure Storage'a yazılması, salt yazılması.
  </action>
  <verify>Sistemin kurulumu tamamlayıp AuthState'i authenticated yapıp yapmadığı kontrol edilecek.</verify>
  <done>Sistem şifreyle güvenli biçimde başlatıldı.</done>
</task>

<task type="auto">
  <name>Login (Giriş) Ekranı</name>
  <files>lib/screens/auth/login_screen.dart</files>
  <action>
    - AuthState "unauthenticated" ise /login adresine yönlendir.
    - Kullanıcı daha önce biyometrik açmışsa anında sensör sorulacak, iptal ederse Neumorphic TextField içerisinde "Master Parolayı Girin" istenecek.
    - Parola doğrulandığında `database_service` başlatılıp Master Key test edilecek.
  </action>
  <verify>Parolanın doğru/yanlış tepkisi test edilecek.</verify>
  <done>Uygulama login kapısı sağlam biçimde tamamlandı.</done>
</task>
