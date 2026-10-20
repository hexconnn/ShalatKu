# ShalatKu — Aplikasi Pengingat Waktu Shalat

## Deskripsi

ShalatKu adalah aplikasi mobile berbasis Flutter dan Dart yang digunakan untuk melihat jadwal shalat harian berdasarkan kota dan tanggal yang dipilih. Aplikasi mengambil data jadwal shalat dari AlAdhan Prayer Times API dan menampilkannya melalui antarmuka yang sederhana dan mudah digunakan.

Aplikasi ini dikembangkan sebagai bagian dari tugas Ujian Tengah Semester (UTS) mata kuliah Pemrograman Mobile.

## Fitur Utama

- **Jadwal Shalat:** Menampilkan waktu Subuh, Dzuhur, Ashar, Maghrib, dan Isya.
- **Navigasi Tanggal:** Melihat jadwal shalat hari sebelumnya, hari berikutnya, atau tanggal tertentu melalui kalender.
- **Status Waktu Shalat:** Menampilkan status sudah lewat, sekarang, atau akan datang untuk jadwal hari ini.
- **Pengingat Shalat:** Menjadwalkan notifikasi lokal untuk mengingatkan waktu shalat.
- **Compass:** Menampilkan arah utara berdasarkan sensor kompas perangkat yang mendukung.
- **Maps:** Membuka Google Maps untuk membantu pengguna mencari masjid.
- **Pengaturan Kota:** Memilih kota yang digunakan untuk mengambil jadwal shalat.
- **Pengaturan Notifikasi:** Mengaktifkan atau menonaktifkan pengingat shalat.
- **Pengambilan Data API:** Menggunakan HTTP request untuk mengambil data jadwal shalat.
- **Asynchronous Programming:** Menggunakan Future dan FutureBuilder untuk menangani proses loading, keberhasilan, dan kesalahan pengambilan data.

## Teknologi dan Package

- Flutter
- Dart
- AlAdhan Prayer Times API
- `http`
- `flutter_local_notifications`
- `timezone`
- `flutter_timezone`
- `flutter_compass`
- `url_launcher`

## Sumber Data API

Aplikasi menggunakan AlAdhan Prayer Times API untuk memperoleh jadwal shalat.

Dokumentasi API: https://aladhan.com/prayer-times-api

Jadwal diperoleh berdasarkan kota, negara, tanggal, dan metode perhitungan yang dikonfigurasi pada aplikasi. Waktu shalat sebaiknya dicocokkan dengan jadwal resmi setempat.

## Struktur Folder

```text
shalatku/
├── android/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── prayer_schedule.dart
│   ├── services/
│   │   ├── prayer_service.dart
│   │   └── notification_service.dart
│   └── screens/
│       └── home_page.dart
├── test/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

## Persyaratan

Sebelum menjalankan aplikasi, pastikan perangkat pengembangan sudah memiliki:

- Flutter SDK
- Dart SDK
- Android Studio atau Visual Studio Code
- Android SDK atau emulator Android
- Koneksi internet

## Cara Menjalankan Aplikasi

1. Clone repositori GitHub:

   ```bash
   git clone https://github.com/USERNAME/shalatku-flutter.git
   ```

2. Masuk ke folder proyek:

   ```bash
   cd shalatku-flutter
   ```

3. Unduh dependensi:

   ```bash
   flutter pub get
   ```

4. Periksa konfigurasi dan kode:

   ```bash
   flutter analyze
   ```

5. Jalankan aplikasi pada emulator atau perangkat Android:

   ```bash
   flutter run
   ```

Ganti `USERNAME` dengan username GitHub pemilik repositori.

## Pengujian

Pengujian aplikasi dilakukan untuk memeriksa:

1. Keberhasilan pengambilan jadwal shalat dari API.
2. Tampilan indikator loading ketika data sedang dimuat.
3. Penanganan error ketika permintaan API gagal.
4. Navigasi tanggal sebelumnya dan berikutnya.
5. Pemilihan tanggal melalui kalender.
6. Perubahan kota dan pemuatan ulang jadwal.
7. Pengaktifan serta penonaktifan pengingat.
8. Fungsi kompas pada perangkat yang mendukung sensor.
9. Fungsi pembukaan Google Maps.

Hasil pengujian dicatat berdasarkan pelaksanaan aktual pada emulator atau perangkat Android.

## Catatan

- Koneksi internet diperlukan untuk mengambil jadwal shalat dari API.
- Notifikasi memerlukan izin yang sesuai dari sistem operasi.
- Ketepatan waktu notifikasi dapat dipengaruhi oleh pengaturan sistem dan kebijakan baterai perangkat.
- Kompas saat ini menunjukkan arah utara magnetis, bukan arah kiblat.
- Fitur Maps membuka layanan Google Maps secara eksternal.
- Pengaturan kota dan status pengingat belum disimpan secara permanen setelah aplikasi ditutup.

## Pengembang

- Nama: Muhammad Akmalul Fikri
- NIM: 240605110147
- Program Studi: Teknik Informatika
- Mata Kuliah: Pemrograman Mobile

## Referensi

- Flutter Documentation: https://docs.flutter.dev/
- Dart Documentation: https://dart.dev/
- AlAdhan Prayer Times API: https://aladhan.com/prayer-times-api
- HTTP Package: https://pub.dev/packages/http
- Flutter Local Notifications: https://pub.dev/packages/flutter_local_notifications
- Flutter Compass: https://pub.dev/packages/flutter_compass
- URL Launcher: https://pub.dev/packages/url_launcher