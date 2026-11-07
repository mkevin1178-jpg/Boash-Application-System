# Boash Student App

Aplikasi mobile **beta** sistem informasi kampus untuk tugas
*Project-Based Learning* (PBL). Boash Student App adalah prototipe
pengalaman mahasiswa: melihat jadwal kuliah, materi, tugas, nilai,
presensi, pengumuman kampus, dan profil demo dalam satu aplikasi.

> **Penting:** seluruh data pada aplikasi ini adalah **data contoh
> (simulasi)**. Aplikasi ini **tidak** terhubung ke SIAKAD atau sistem
> informasi kampus mana pun, dan login pada aplikasi ini **bukan
> autentikasi resmi kampus**.

---

## Daftar fitur

| Menu | Isi |
| --- | --- |
| **Beranda** | Sapaan mahasiswa, foto profil demo, jadwal kuliah hari ini, tugas terdekat beserta tenggat, pengumuman kampus terbaru, akses cepat ke fitur akademik |
| **Jadwal** | Jadwal harian dan mingguan, penanda hari aktif, detail kelas (jam, mata kuliah, ruang, dosen contoh) |
| **Akademik** | Hub Materi, Tugas, Nilai, Presensi (termasuk Scan QR demo), KTM, KRS, dan DHS |
| **Pengumuman** | Daftar pengumuman kampus (kategori + tanggal), penanda belum dibaca, halaman detail pengumuman |
| **Profil** | Profil demo, statistik contoh, menu KTM / Pengaturan / Tentang, konfirmasi logout, pembersihan sesi demo |

State tiap halaman dipertahankan saat berpindah menu bottom navigation.

---

## Instalasi & menjalankan aplikasi

Prasyarat: **Flutter SDK** (versi `3.47.x` / Dart `3.13.x` sudah dipakai
proyek ini).

```bash
# 1. Ambil dependensi
flutter pub get

# 2. Jalankan di perangkat / emulator / web
flutter run -d chrome     # web
flutter run              # perangkat yang terhubung (Android/iOS)

# 3. Periksa kualitas kode
flutter analyze

# 4. Jalankan pengujian
flutter test
```

Folder `android/`, `ios/`, `web/`, `windows/`, `macos/`, dan `linux/`
sudah tersedia sebagai hasil `flutter create`.

---

## Login demo

Aplikasi memakai login demo lokal dengan NPM dan kata sandi minimal.
Profil akademik selain NPM menggunakan data contoh. Alurnya:

```text
Splash → Login → Validasi format NPM/kata sandi → Sesi demo → Dashboard
```

1. Masukkan NPM (minimal 5 digit) dan kata sandi (minimal 4 karakter).
2. Tekan **MASUK** untuk membuat sesi demo lokal.

Karakter login demo:

- **Bukan** autentikasi resmi kampus. Tidak ada kredensial asli, tidak ada
  data mahasiswa nyata, dan tidak ada pencatatan ke server kampus.
- Login hanya memeriksa format input; bukan verifikasi identitas kampus.
- Tombol login dinonaktifkan selama proses berlangsung agar tidak terjadi
  permintaan ganda.
- Sesi demo disimpan **di memori aplikasi** (tidak ada penyimpanan
  permanen). Menutup aplikasi atau logout akan menghapus sesi.

---

## Fitur yang masih berupa simulasi

Semua data berikut adalah data contoh dan diberi penanda visual
(`Demo` / `Simulasi`) di dalam aplikasi:

| Fitur | Catatan |
| --- | --- |
| Login | Sesi demo lokal berdasarkan format NPM, bukan SIAKAD |
| Foto profil | Avatar fallback untuk sesi demo lokal |
| Jadwal, materi, tugas, nilai, presensi, pengumuman | Hard-coded di `lib/data/demo_data.dart` |
| Tombol kumpulkan tugas | Simulasi — tidak mengirim berkas ke mana pun |
| Tombol simpan / bagikan KTM | Simulasi — tidak menyimpan berkas |
| Barcode pada KTM | **Dekoratif**, bukan barcode yang dapat discan untuk verifikasi |
| Scan QR Presensi | Validasi jadwal dan kedaluwarsa; log per NPM hanya di memori aplikasi |
| Statistik profil (IPK, SKS, jumlah mata kuliah) | Angka contoh |

Tidak ada backend baru, tidak ada integrasi SIAKAD, dan tidak ada
kredensial sensitif di dalam source code.

---

## Struktur proyek

```text
lib/
├── main.dart               # entry point + AppRoot (splash → login/dashboard) + tema
├── app/app_theme.dart      # ThemeData terpusat
├── core/                   # LoadState, AsyncController, AsyncBuilder, format tanggal
├── models/                 # model data (course, assignment, announcement, ...)
├── data/                   # sumber data demo + repository
├── services/              # API nilai dan validasi QR presensi demo
├── state/                  # AppSession + AppController (ChangeNotifier)
├── theme/                  # token warna, spacing, radius, tipografi
├── widgets/                # komponen reusable
└── features/               # splash, auth, shell, dashboard, schedule,
                            # academic, announcements, profile
```

---

## Pengujian

`flutter test` menjalankan pengujian widget dan unit yang tidak bergantung
kamera atau jaringan:

| Berkas | Cakupan uji |
| --- | --- |
| `test/login_flow_test.dart` | Login demo berhasil / ditolak, input kosong, kegagalan API, isi otomatis |
| `test/navigation_test.dart` | Navigasi kelima tab dan signup halaman detail |
| `test/academic_flow_test.dart` | Alur Akademik: tugas, materi, nilai, presensi, KTM, pengumuman |
| `test/error_and_empty_state_test.dart` | State pemuatan, error, dan data kosong |
| `test/date_format_test.dart` | Format tanggal Indonesia dan tenggat relatif |
| `test/qr_attendance_service_test.dart` | Validasi payload, jadwal, kedaluwarsa, dan duplikasi |
| `test/qr_attendance_flow_test.dart` | Scan palsu, kegagalan simpan, riwayat kosong, tile Akademik |

Status verifikasi terbaru: `flutter analyze` → **No issues found!**;
`flutter test` → **All tests passed!** (43 pengujian).

---

## Referensi dokumen

| Dokumen | Isi |
| --- | --- |
| [`WORKFLOW.md`](WORKFLOW.md) | Perjalanan pengguna dan alur aplikasi |
| [`REVISI.md`](REVISI.md) | Daftar fitur, optimasi, dan perbaikan UI/UX |
| [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) | Hasil audit, masalah, dan rencana implementasi |
| [`design.md`](design.md) | Design document v2 (identitas visual "E-Learning Blue", 5 tab, pola state) |
| [`docs/mockup-boash.png`](docs/mockup-boash.png) | Referensi visual UI mobile |

---

## Stack

- Flutter 3.47.x · Dart 3.13.x
- `google_fonts` — font Poppins
- `http` — pemanggilan API nilai demo
- `mobile_scanner` — pemindaian QR dari kamera
- Tanpa package state management; memakai `ChangeNotifier` bawaan Flutter
- Versi aplikasi: **2.0** (prototipe PBL, data simulasi)
