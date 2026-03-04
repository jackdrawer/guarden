# Phase 3 Context: Core UI & Modules

## Objective
The goal of Phase 3 is to build the core functionality of Guarden. Now that the user can securely authenticate and have an encrypted vault (Phase 1 & Phase 2), they need to be able to add, view, edit, and delete their passwords, bank accounts, and subscriptions. Furthermore, the UI must strictly follow the premium Neumorphic design language chosen by the user, and incorporate the "Dynamic Logo Service" to fetch and cache logos for a high-end feel.

## Key Requirements & Scope
1.  **Dinamik Logo Servisi (Cache Destekli):**
    *   Kullanıcının girdiği URL veya kuruma göre logoyu getirecek bir servis (örneğin Clearbit API `https://logo.clearbit.com/garantibbva.com.tr`).
    *   Bu logolar, cihazın önbelleğinde veya base64 olarak DB'de saklanarak çevrimdışı (offline) modda da gösterilebilmelidir. Bulunamayan logolar için Neumorphic tasarımlı, baş harfli placeholder avatarlar kullanılmalıdır.
2.  **Ana Dashboard:**
    *   Toplam bütçe (aboneliklerden gelen verilerle pie chart), yaklaşan banka şifre değişim uyarıları ve "Hızlı Erişim" butonlarının bulunduğu özet ekran.
3.  **Banka Ekranı (Esnek Periyotlu):**
    *   Banka şifreleri için *3, 6, 9 veya 12 Ay* periyot seçimi sunulmalıdır. Formda bu seçenek olmalı ve son değişim tarihine göre uygulamanın bir sonraki ekranında veya dashboard'da uyarı verebilmesi için veritabanında saklanmalıdır.
4.  **Abonelikler ve Web Şifreleri (CRUD):**
    *   Sınıflandırma ve kolay arayüz eklentileri (Neumorphic input alanları).
    *   Abonelikler kısmında aylık/yıllık ücret girişi yapılabilmeli.

## Architecture Guidelines
*   **State Management:** Riverpod 2 (`AutoDisposeNotifier`). Servisler bağımsız olmalı.
*   **Data Models:** Hive ile zaten modellerimiz tanımlı (`BankAccount`, `Subscription`, `WebPassword`). Bu modellere "logoUrl" ve banka için "periodMonths" (int) gibi yeni alanlar eklenecekse Hive type adapter'leri güncellenmelidir (veya mevcut modelde varsa doğrudan kullanılacaktır).
*   **Design Language:** `AppColors` sınıfından güç alan Neumorphism esintili bileşenler kullanılmaya devam edecek.

## Split execution plan
*   **Plan 01:** Logo Servisi ve Hive Modellerinin (Alanlarının) Güncellenmesi.
*   **Plan 02:** Bankacılık, Abonelik ve Web şifreleri modellerinin (ViewModel / Provider) ve CRUD servislerinin Riverpod aracılığı ile bağlanması.
*   **Plan 03:** Ana Dashboard, Banka Kayıt Ekleme ve diğer Neumorphic UI ekranlarının oluşturulması.

## Current status
Ready to execute Plan 01.
