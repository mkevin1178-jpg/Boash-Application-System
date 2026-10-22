# Riwayat Percakapan — Project Student App (Auth + KTM)

## User (Prompt 1)

> riset folder ini dan saya ingin melanjutkan project ini dengan menambahkan apa yg ada di dalam file /Pertemuan_4_-_Auth_Flutter.md . dari materi tersebut sesuaikan dengan apa yg ada di dalam project ini. kalau bisa edit terlebih dahulu desainnya agar menyesuaikan API yg ada. agar fitur fitur didalam nya itu berfungsi. Tambahan : buatkan desain KTM atau Kartu Tanda Mahasiswa sesuai dengan tema dan desain yg ada pada project ini, tambahkan fitur tersebut kedalam menu home. KERJAKAN PROJECT INI DAN JANGAN SAMPAI SALAH

## Assistant

### Riset project

Membaca struktur project dan file pendukung:

- `lib/` : `main.dart`, `login.dart`, `welcome.dart`, `home.dart`, `info.dart`, `profile.dart`, `news.dart`, `theme/app_colors.dart`, `widgets/menu_icon_tile.dart`, `widgets/section_title.dart`, `widgets/app_snackbar.dart`
- `design.md` — Design Document "Student App" gaya E-Learning Blue (gradient biru, kartu putih, ikon lingkaran navy `#1A2B6D`, font Poppins).
- `Pertemuan_4_-_Auth_Flutter.md` — materi autentikasi: `api/auth_api.dart` (randomuser.me), `pages/auth_page.dart`, `main.dart`.
- `pubspec.yaml` — Flutter Dart SDK `^3.13.4`, dependency `google_fonts`.
- `test/widget_test.dart` — test login → welcome.

### Rencana & Pengerjaan

1. Tambah dependency `http` (untuk memanggil API).
2. `lib/api/auth_api.dart` — fetch 1 user acak dari `https://randomuser.me/api/`.
3. `lib/session.dart` — menyimpan data mahasiswa yang login (hasil API).
4. Redesign `lib/login.dart` agar terhubung ke API: loading, validasi, pesan, kartu akun testing + tombol Ganti User Acak.
5. `lib/ktm.dart` — halaman Kartu Tanda Mahasiswa sesuai tema.
6. `lib/home.dart` — tambah menu KTM + sapaan dari session.
7. `lib/profile.dart` — sinkron dengan data session/API.
8. `lib/main.dart` — LoginScreen bisa menerima injeksi `AuthApi` (testability).
9. `test/widget_test.dart` — rewrite memakai `AuthApi` palsu (offline test).
10. Android manifest — tambah izin `INTERNET`.
11. Update `design.md` agar selaras.
12. Verifikasi: `flutter analyze`, `flutter test`, `flutter build web`.

### Hasil Verifikasi

```
flutter analyze   → No issues found!
flutter test      → All tests passed!
flutter build web → ✓ Built build\web
```

### Ringkasan Perubahan

**Auth API (Pertemuan 4) — disesuaikan dengan desain project**

- `lib/api/auth_api.dart` — ambil 1 user acak dari `randomuser.me` (timeout + catch error).
- `lib/login.dart` — tetap bergaya gradient biru/Poppins, tapi kini: validasi cocok dengan username/password API, indikator loading (`MEMUAT...`), pesan kaca (error/sukses), kartu "Akun login dari API (untuk testing)" + tombol **Ganti User Acak**.
- `lib/session.dart` — simpan data hasil login (nama, username, email, foto) dipakai lintas halaman.
- `lib/main.dart` — `LoginScreen` bisa diinjeksi `AuthApi` (untuk test).
- Android manifest — tambah izin `INTERNET` agar API jalan di release.

**KTM (Kartu Tanda Mahasiswa)**

- `lib/ktm.dart` — kartu bergaya ID card: strip gradient + logo, foto (dari API) + NIM/Nama/Prodi/Fakultas, kotak meta (semester/tahun/berlaku), footer barcode; plus section "Data Mahasiswa" dan tombol SIMPAN/BAGIKAN.
- `lib/home.dart` — menu **KTM** (`Icons.badge_outlined`) di grid Home, tap → buka `KtmScreen`; sapaan header jadi `Hi, <nama sesi>`.
- `lib/profile.dart` — nama, NIM, email, prodi, phone, dan avatar kini dari data sesi/API.
- `design.md` — diselaraskan (login auth API, 13 menu, Spesifikasi 4.7 KTM, interaksi, acceptance criteria, roadmap).

Cara pakai: jalankan `flutter run -d chrome`, login pakai kredensial pada kartu "Akun login dari API" di halaman login (bisa tekan "Ganti User Acak"), lalu dari Home buka menu **KTM**.

---

## User (Prompt 2)

> simpan semua history percakapan ini menjadi 1 file .md yaitu "prompt.md"

## Assistant

Membuat file `prompt.md` berisi seluruh riwayat percakapan ini.
