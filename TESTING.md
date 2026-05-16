# Panduan Automation UI Testing – SEHATI (Smart Farmasi)

Dokumen ini menjelaskan cara menjalankan dan mengembangkan sistem otomatisasi UI Testing untuk aplikasi Flutter SEHATI.

## 🚀 Persiapan
Pastikan Anda sudah menginstal dependensi tambahan dengan menjalankan:
```bash
flutter pub get
```

## 🧪 Jenis Pengujian

### 1. Widget Testing (Component/Feature Test)
Berfokus pada pengujian unit UI dan logika di tingkat halaman/widget tanpa memerlukan perangkat fisik. Menggunakan *mocking* untuk database (Firebase) dan API.

**Cara Menjalankan:**
*   **Semua test:** `flutter test`
*   **File spesifik:** `flutter test test/widget/auth_test.dart`

**Daftar Test yang Tersedia:**
- `onboarding_test.dart`: Alur pengenalan aplikasi.
- `auth_test.dart`: Validasi form Login & Register.
- `home_test.dart`: Navigasi menu utama.
- `health_check_test.dart`: Logika pemilihan gejala.
- `chatbot_test.dart`: Simulasi percakapan dengan Cio.
- `pharmacy_test.dart`: Penanganan izin lokasi & daftar apotek.
- `profile_test.dart`: Tampilan profil & modal keamanan.
- `scan_test.dart`: Simulasi pemindaian label obat.

---

### 2. Integration Testing (End-to-End Test)
Berfokus pada pengujian alur pengguna dari awal hingga akhir (*Happy Path*).

**Cara Menjalankan:**
*   **Android/Emulator:** 
    ```bash
    flutter test integration_test/app_integration_test.dart
    ```
*   **Web (Chrome):**
    ```bash
    flutter test integration_test/app_integration_test.dart -d chrome
    ```

---

## 🛠️ Arsitektur Testing

### Mocking (Tanpa Backend/Internet)
Aplikasi menggunakan **GetX** untuk state management. Dalam lingkungan test, kita mengganti controller asli dengan controller dummy agar test stabil dan cepat:
- **`MockAuthController`**: Meng-override Firebase Auth. Anda bisa mengatur status login dengan `setLoggedInUser()`.
- **`FakePharmacyController`**: Meng-override `Geolocator` untuk menghindari error izin GPS di lingkungan headless.
- **`mockNetworkImagesFor`**: Digunakan di hampir semua test untuk mencegah error saat memuat gambar dari URL.

### Helper: `test_helpers.dart`
Berisi utilitas untuk:
- Mengatur ukuran layar (Mobile Small s/d Desktop) untuk cek *UI Overflow*.
- `pumpAndSettleSafely`: Menunggu animasi selesai dengan batas waktu agar test tidak gantung (*infinite loop*).

## 📝 Menambah Test Baru
Jika Anda membuat fitur baru yang menggunakan layanan eksternal (API, Firebase, GPS, Kamera):
1. Buat class *Fake/Mock* yang meng-*extend* controller asli di `test/mocks/`.
2. Gunakan `Get.put<OriginalClass>(MockClass())` dalam `BindingsBuilder` di file test.
3. Gunakan `mockNetworkImagesFor` jika widget memuat gambar internet.
4. Gunakan `setScreenSize` untuk memastikan fitur responsif di berbagai perangkat.

---
*Dibuat oleh Antigravity - Senior Flutter QA Engineer Automation Suite*
