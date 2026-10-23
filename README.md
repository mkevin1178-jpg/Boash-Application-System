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
| **Akademik** | Hub ke Materi perkuliahan, Tugas (+ detail tugas), Nilai demo, Presensi demo, dan KTM digital demo |
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

Aplikasi memakai **API acak `https://randomuser.me/api/`** untuk
mengambil satu profil contoh. Alurnya:

```text
Splash → Login → Validasi input → Autentikasi demo (API acak) → Dashboard
```

1. Buka aplikasi. Halaman **Login** mengambil satu user acak dari
   `randomuser.me`.
2. Kartu **"Akun demo dari API"** menampilkan username dan password
   contoh yang dipakai API tersebut. Password **disembunyikan secara
   default** — tekan ikon mata untuk melihatnya.
3. Isi kolom username & password dengan nilai tersebut, lalu tekan
   **MASUK**.
4. Jika API sedang lambat atau gagal, tekan **"Coba lagi"**. Sesi demo
   tetap dapat dipakai karena kredensial contoh ditampilkan di layar.

Karakter login demo:

- **Bukan** autentikasi resmi kampus. Tidak ada kredensial asli, tidak ada
  data mahasiswa nyata, dan tidak ada pencatatan ke server kampus.
- API acak hanya menyediakan **profil contoh**; pencocokan username dan
  password di layar login adalah **mekanisme simulasi** yang dibuat
  eksplisit di `lib/features/auth/login_screen.dart`, bukan verifikasi
  identitas.
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
| Login | Kredensial dari `randomuser.me`, bukan SIAKAD |
| Foto profil | Diambil dari `randomuser.me`; ada avatar cadangan bila gagal dimuat |
| Jadwal, materi, tugas, nilai, presensi, pengumuman | Hard-coded di `lib/data/demo_data.dart` |
| Tombol kumpulkan tugas | Simulasi — tidak mengirim berkas ke mana pun |
| Tombol simpan / bagikan KTM | Simulasi — tidak menyimpan berkas |
| Barcode pada KTM | **Dekoratif**, bukan barcode yang dapat discan untuk verifikasi |
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
├── services/auth_api.dart  # pemanggil API randomuser.me
├── state/                  # AppSession + AppController (ChangeNotifier)
├── theme/                  # token warna, spacing, radius, tipografi
├── widgets/                # komponen reusable
└── features/               # splash, auth, shell, dashboard, schedule,
                            # academic, announcements, profile
```

---

## Pengujian

`flutter test` menjalankan 20 pengujian widget yang tidak bergantung
jaringan (API acak disimulasikan lewat injeksi `AuthApi` pada
`test/support/test_harness.dart`):

| Berkas | Cakupan uji |
| --- | --- |
| `test/login_flow_test.dart` | Login demo berhasil / ditolak, input kosong, kegagalan API, isi otomatis |
| `test/navigation_test.dart` | Navigasi kelima tab dan signup halaman detail |
| `test/academic_flow_test.dart` | Alur Akademik: tugas, materi, nilai, presensi, KTM, pengumuman |
| `test/error_and_empty_state_test.dart` | State pemuatan, error, dan data kosong |
| `test/date_format_test.dart` | Format tanggal Indonesia dan tenggat relatif |

Status verifikasi terakhir: `flutter analyze` → **No issues found!**,
`flutter test` → **All tests passed!** (20 uji).

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
- `http` — pemanggilan API acak
- Tanpa package state management; memakai `ChangeNotifier` bawaan Flutter
- Versi aplikasi: **2.0** (prototipe PBL, data simulasi)
