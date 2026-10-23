# IMPLEMENTATION_PLAN.md — Boash Student App

Dokumen ini adalah hasil audit repository dan rencana implementasi
pengembangan UI/UX Boash Student App (beta PBL).

---

## 1. Ringkasan implementasi saat ini

| Aspek | Kondisi sebelum pengembangan |
| --- | --- |
| Entry point | `lib/main.dart` → `MaterialApp` → `LoginScreen` |
| Autentikasi | `lib/api/auth_api.dart` memanggil `https://randomuser.me/api/`, mengambil `results[0]`, mencocokkan `login.username` + `login.password` dengan input pengguna |
| Sesi | `lib/session.dart` — `AppSession` sebagai **static global** (nama, NIM, email, foto, prodi, fakultas, semester, TAH) |
| Shell navigasi | `lib/welcome.dart` — `Scaffold` + `AppBar` + `IndexedStack` + `BottomNavigationBar` **4 tab** (Home, Info, Profile, News) |
| Halaman | `home.dart` (grid 13 menu + banner + chips + featured), `info.dart` (6 kartu accordion), `news.dart` (chip filter + berita utama + 4 item), `profile.dart` (avatar + statistik + logout), `ktm.dart` (Kartu Tanda Mahasiswa) |
| Tema | `lib/theme/app_colors.dart` — 16 token warna, `bgGradient` + `buttonGradient`, Poppins via `google_fonts` |
| Komponen reusable | `widgets/menu_icon_tile.dart`, `widgets/section_title.dart`, `widgets/app_snackbar.dart` |
| State management | `StatefulWidget` + `setState` lokal; `AppSession` static global. **Belum ada** model/repository/layer state |
| Data | Seluruh data dummy ditulis **inline di dalam widget** (`news.dart`, `info.dart`, `home.dart`, `profile.dart`) |
| Dependensi | `cupertino_icons`, `google_fonts`, `http` (+ `flutter_lints` sebagai dev dep). Tanpa state-management package |
| Pengujian | `test/widget_test.dart` — 1 widget test happy path dengan `AuthApi` palsu (offline) |

### Baseline verifikasi (sebelum perubahan)

```
flutter pub get   → Got dependencies!
flutter analyze   → No issues found! (ran in 1.2s)
flutter test      → All tests passed! (1 test)
```

Tidak ada error analisis atau kegagalan build bawaan proyek. Semua masalah
di bawah ini adalah masalah **desain/UI-UX/kelengkapan**, bukan crash.

---

## 2. Masalah yang ditemukan

### 2.1 Dokumentasi & fondasi

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| A1 | `README.md` | Marker konflik merge (`<<<<<<< HEAD`, `=======`, `>>>>>>>`) masih ada sehingga dokumen tidak terbaca normal | P0 |
| A2 | repo | Folder `docs/` belum ada; `mockup-boash.png` hanya di root | P0 |
| A3 | `docs/IMPLEMENTATION_PLAN.md` | Belum ada | P0 |

### 2.2 Navigasi

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| B1 | `lib/welcome.dart:19-24` | Hanya 4 tab (Home/Info/Profile/News); REVISI §5 dan WORKFLOW §5 mewajibkan 5 tab: Beranda/Jadwal/Akademik/Pengumuman/Profil | P0 |
| B2 | `lib/info.dart` + `lib/news.dart` | Menu **Info** dan **News** tumpang tindih tanpa pembeda fungsi jelas | P0 |
| B3 | `lib/home.dart:29-43` | 13 menu, 12 di antaranya hanya menampilkan snackbar ("<label> opened") — tombol tanpa fungsi | P0 |
| B4 | `lib/welcome.dart:59-67` | Label tab berbahasa Inggris ("Home", "Info", "News") tidak konsisten dengan dokumentasi berbahasa Indonesia | P1 |
| B5 | `lib/profile.dart:11-16` | Logout tanpa dialog konfirmasi dan **tidak menghapus sesi** (`AppSession` tidak punya `clear()`) | P0 |
| B6 | proyek | Tidak ada Splash Screen; WORKFLOW §3 mensyaratkan `Splash → Login → Dashboard` | P1 |

### 2.3 Dashboard

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| C1 | `lib/home.dart:61-181` | Isi = katalog kursus generik ("Math MasterClass", "Top search", "Featured") — bukan ringkasan aktivitas mahasiswa | P0 |
| C2 | `lib/home.dart:289-353` | Banner gradient besar tanpa nilai informasi | P1 |
| C3 | `lib/home.dart:231-259` | Ikon notifikasi & search hanya menampilkan snackbar | P1 |
| C4 | `lib/home.dart` | Tidak ada jadwal hari ini, tugas terdekat, atau pengumuman terbaru | P0 |

### 2.4 Login & API

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| D1 | `lib/login.dart:336-380` | **Password API ditampilkan terbuka** di kartu "Akun login dari API (untuk testing)" | P0 |
| D2 | `lib/login.dart:57-86` | Tidak ada guard anti-submit ganda; tidak ada state "memproses login" terpisah dari state "memuat API" | P0 |
| D3 | `lib/api/auth_api.dart:10-24` | Semua kegagalan (timeout, HTTP error, JSON rusak) di-swallows menjadi `null` tanpa informasi | P0 |
| D4 | `lib/api/auth_api.dart:13` | `GET` tanpa parameter `results=1` (mengambil 100 record) | P2 |
| D5 | `lib/login.dart` | Tidak ada tombol tampil/sembunyikan password | P1 |
| D6 | `lib/api/auth_api.dart` | Autentikasi adalah **simulasi** (randomuser.me bukan SIAKAD) tetapi tidak dijelaskan jujur di mana pun | P0 |

### 2.5 Kode, state & data

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| E1 | `lib/session.dart` | State global static mutable; tidak ada instance tunggal yang bisa di-reset | P0 |
| E2 | `lib/news.dart`, `lib/info.dart`, `lib/home.dart`, `lib/profile.dart` | Data dummy inline di widget; tidak ada model/repository | P0 |
| E3 | seluruh `lib/` | Tidak ada loading/error/empty state yang konsisten; tidak ada cara menguji kegagalan | P0 |
| E4 | `lib/section_title.dart:33` | `onAction ?? () {}` — no-op callback (tombol mati) | P1 |
| E5 | `lib/news.dart:168,216` | Tap berita → snackbar; tidak ada halaman detail pengumuman | P1 |
| E6 | `lib/ktm.dart:64-119` | Tombol SIMPAN/BAGIKAN hanya snackbar; barcode dekoratif tanpa label "demo" | P1 |
| E7 | `lib/main.dart:26` | `scaffoldBackgroundColor: Colors.white` — tidak ada token latar `#F4F7FC`, halaman dan kartu tidak bisa dibedakan | P1 |
| E8 | `lib/main.dart:24` | `ColorScheme.fromSeed` membuat palet turunan yang **berbeda** dari `AppColors` | P1 |
| E9 | `lib/home.dart` | `GridView.count` + `shrinkWrap` untuk grid 13 item; bukan builder | P2 |
| E10 | `lib/home.dart:25` | `_searchController` + state query tidak diperlukan lagi setelah redesign | P2 |

### 2.6 Pengujian

| # | Lokasi | Masalah | Prioritas |
| --- | --- | --- | --- |
| F1 | `test/widget_test.dart` | Hanya 1 test happy path | P0 |
| F2 | proyek | Tidak ada test untuk: input kosong, API gagal/timeout, data kosong, logout, navigasi 5 tab, detail tugas/pengumuman, avatar fallback | P0 |

---

## 3. Arsitektur target

Tidak ada penulisan ulang total dan **tidak ada dependensi baru**. Pola yang
dipakai: `ChangeNotifier` bawaan Flutter (tanpa package `provider`), service
API terpisah, model data terpisah, repository data demo terpisah.

```
lib/
├── main.dart                       # entry point, MyApp, tema, route awal
├── app/
│   └── app_theme.dart              # ThemeData terpusat (warna + tipografi + radius)
├── core/
│   ├── load_state.dart             # sealed LoadState: idle/loading/success/error
│   ├── async_controller.dart       # ChangeNotifier pemuat data + anti-duplikat request
│   ├── async_builder.dart          # widget pembungkus loading/error/empty/success
│   └── date_format.dart            # format tanggal/waktu bahasa Indonesia
├── models/
│   ├── course.dart                 # mata kuliah
│   ├── class_session.dart          # satu sesi kuliah
│   ├── assignment.dart             # tugas + status enum
│   ├── announcement.dart           # pengumuman
│   ├── course_material.dart        # materi perkuliahan
│   ├── grade.dart                  # nilai
│   └── attendance.dart             # presensi
├── data/
│   ├── demo_data.dart              # SATU sumber data demo (konsisten antar layar)
│   └── demo_repository.dart        # repository + latensi simulasi + mode gagal
├── services/
│   └── auth_api.dart               # service API (timeout, status HTTP, JSON guard)
├── state/
│   ├── app_session.dart            # model sesi (immutable + copyWith)
│   └── app_controller.dart         # ChangeNotifier: sesi, login, logout
├── theme/
│   ├── app_colors.dart             # token warna (diperluas, disatukan)
│   ├── app_spacing.dart            # skala jarak 4/8/12/16/20/24/32
│   ├── app_radii.dart              # radius seragam
│   └── app_typography.dart         # skala tipografi
├── widgets/                        # komponen reusable
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── app_card.dart
│   ├── status_badge.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   ├── loading_view.dart
│   ├── demo_note.dart              # label "Demo"/"Simulasi"
│   ├── page_header.dart
│   ├── section_title.dart
│   ├── menu_icon_tile.dart
│   └── app_snackbar.dart
└── features/
    ├── splash/splash_screen.dart
    ├── auth/login_screen.dart
    ├── shell/main_shell.dart       # IndexedStack 5 tab
    ├── dashboard/dashboard_screen.dart
    ├── schedule/schedule_screen.dart
    ├── academic/
    │   ├── academic_screen.dart
    │   ├── materials_screen.dart
    │   ├── assignments_screen.dart
    │   ├── assignment_detail_screen.dart
    │   ├── grades_screen.dart
    │   ├── attendance_screen.dart
    │   └── ktm_screen.dart
    ├── announcements/
    │   ├── announcements_screen.dart
    │   └── announcement_detail_screen.dart
    └── profile/
        ├── profile_screen.dart
        └── settings_screen.dart    # Pengaturan & Bantuan
```

### 3.1 Pemetaan file lama → baru (tidak ada fungsi yang hilang)

| File lama | File baru | Alasan |
| --- | --- | --- |
| `lib/main.dart` | `lib/main.dart` (diperbarui) | Tema terpusat + `AppController` |
| `lib/login.dart` | `lib/features/auth/login_screen.dart` | Alur login demo: validasi inline, show/hide password, guard submit, retry, label simulasi |
| `lib/welcome.dart` | `lib/features/shell/main_shell.dart` | Shell 5 tab (IndexedStack dipertahankan) |
| `lib/home.dart` | `lib/features/dashboard/dashboard_screen.dart` | Ganti katalog kursus → ringkasan aktivitas (C1, C4) |
| `lib/info.dart` | `lib/features/academic/academic_screen.dart` | Info tumpang tindih dengan News → jadi hub Akademik (B2) |
| `lib/news.dart` | `lib/features/announcements/announcements_screen.dart` | Ditambah halaman detail (E5) |
| `lib/profile.dart` | `lib/features/profile/profile_screen.dart` | Ditambah konfirmasi logout + pembersihan sesi (B5) |
| `lib/ktm.dart` | `lib/features/academic/ktm_screen.dart` | Dipertahankan penuh, ditambah label demo (E6) |
| `lib/session.dart` | `lib/state/app_session.dart` + `lib/state/app_controller.dart` | Static global → instance yang bisa di-reset (E1) |
| `lib/api/auth_api.dart` | `lib/services/auth_api.dart` | Ditambah penanganan error berjenjang (D3) |
| `lib/widgets/*` | `lib/widgets/*` | Dipertahankan + diseragamkan; `section_title` no-op dihapus (E4) |

---

## 4. File yang perlu diubah / ditambahkan

### 4.1 Diubah
`README.md`, `REVISI.md`, `WORKFLOW.md`, `design.md`, `pubspec.yaml` (deskripsi),
`lib/main.dart`, `lib/theme/app_colors.dart`, `lib/widgets/app_snackbar.dart`,
`lib/widgets/section_title.dart`, `lib/widgets/menu_icon_tile.dart`,
`test/widget_test.dart`.

### 4.2 Ditambahkan
`docs/IMPLEMENTATION_PLAN.md`, `docs/mockup-boash.png`,
`lib/app/app_theme.dart`, `lib/core/{load_state,async_controller,async_builder,date_format}.dart`,
`lib/models/*.dart` (7 file), `lib/data/{demo_data,demo_repository}.dart`,
`lib/services/auth_api.dart`, `lib/state/{app_session,app_controller}.dart`,
`lib/theme/{app_spacing,app_radii,app_typography}.dart`,
`lib/widgets/{app_button,app_text_field,app_card,status_badge,empty_state,error_state,loading_view,demo_note,page_header}.dart`,
`lib/features/**` (18 file),
`test/{login_flow_test,navigation_test,academic_flow_test,empty_error_state_test}.dart`.

### 4.3 Dihapus
`lib/home.dart`, `lib/info.dart`, `lib/news.dart`, `lib/welcome.dart`,
`lib/ktm.dart`, `lib/profile.dart`, `lib/login.dart`, `lib/session.dart`,
`lib/api/auth_api.dart` — **setiap file memiliki pemetaan penggantinya di
§3.1**; tidak ada kapabilitas yang dibuang.

---

## 5. Urutan implementasi

| Tahap | Pekerjaan | Output | Verifikasi |
| --- | --- | --- | --- |
| 1 | Dokumentasi & fondasi | `docs/IMPLEMENTATION_PLAN.md`, `docs/mockup-boash.png`, README tanpa konflik | `flutter analyze` |
| 2 | Design system | `app_theme.dart`, `app_colors/spacing/radii/typography`, 9 komponen reusable | `flutter analyze` |
| 3 | Navigasi utama | `main_shell.dart` 5 tab + `IndexedStack` + `AppController` | `flutter analyze` + test navigasi |
| 4 | Redesign dashboard | `dashboard_screen.dart` (sapaan, jadwal hari ini, tugas terdekat, pengumuman, akses cepat) | `flutter analyze` |
| 5A | Alur login | `splash_screen.dart`, `login_screen.dart`, `auth_api.dart` baru | `flutter test` |
| 5B | Jadwal | `schedule_screen.dart` (harian/mingguan + detail kelas) | `flutter analyze` |
| 5C | Akademik | `academic_screen.dart` + materi/tugas/detail/nilai/presensi/KTM | `flutter analyze` + test |
| 5D | Pengumuman | daftar + `announcement_detail_screen.dart` | `flutter analyze` + test |
| 5E | Profil | profil + pengaturan/bantuan + konfirmasi logout + pembersihan sesi | `flutter test` |
| 6 | Optimasi | pisah UI/model/service/state, `const`, builder list, guard request | `flutter analyze` |
| 7 | Pengujian | test terarah untuk login, navigasi, state, data kosong | `flutter test` |
| 8 | Dokumentasi akhir | README, checklist REVISI, WORKFLOW selaras implementasi | `flutter analyze && flutter test` |

---

## 6. Risiko teknis & dependensi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| `randomuser.me` sedang down / lambat | Login demo gagal total | Timeout 10 s, pesan error + tombol **Coba Lagi**, info kredensial demo tetap ditampilkan sebagai fallback sehingga alur tetap bisa didemokan |
| Cookie/`http` di web | CORS pada `flutter run -d chrome` | API `randomuser.me` mengizinkan CORS; dipakai di build web proyek sebelumnya |
| `google_fonts` mengunduh font saat runtime | Font fallback pada mode offline | `GoogleFonts.config.allowRuntimeFetching` tetap `true` (perilaku bawaan) — teks tetap terbaca dengan font fallback |
| Refactor besar pada navigasi | Test lama (`widget_test.dart`) ikut gagal | Test lama ditulis ulang sesuai kontrak baru, bukan dihapus |
| Addition `ChangeNotifier` tanpa `provider` | Boilerplate yang berulang | `ListenableBuilder` (bawaan Flutter) dipakai; controller di-inject via constructor agar testable |
| Data demo menumpuk di satu file | `demo_data.dart` membesar | Dipisah per model di `lib/models/`, data dikelompokkan per fitur |
| Menambahkan terlalu banyak file baru | Struktur jadi ribut | Aturan: file > 300 baris dipecah; komponen > 2 pemakaian dipindah ke `widgets/` |
| Halaman menjadi terlalu padat | Scroll panjang | Aturan prioritas: di atas lipatan layar = sapaan, jadwal hari ini, tugas terdekat |

**Dependensi baru:** **tidak ada**. Dependensi yang tersedia (`http`,
`google_fonts`) tetap dipakai apa adanya.

---

## 7. Fitur yang masih menggunakan simulasi

Semua data berikut adalah **data contoh** dan diberi label visual
(`Demo` / `Simulasi`) di UI:

| Fitur | Status simulasi | Penanda di UI |
| --- | --- | --- |
| Login | Kredensial dari `randomuser.me`; **bukan autentikasi SIAKAD/universitas** | Teks "Autentikasi demo — bukan sistem kampus resmi" + kartu kredensial |
| Foto profil | URL gambar dari `randomuser.me` | Fallback avatar lokal bila gagal dimuat |
| Jadwal kuliah | Hard-coded di `demo_data.dart` | Header "Data simulasi" |
| Materi perkuliahan | Hard-coded, aksi buka/unduh → snackbar demo | Badge "Demo" pada tiap materi |
| Tugas & tenggat | Hard-coded, tombol kumpulkan → dialog demo | Badge "Demo" pada tombol kumpulkan |
| Nilai | Angka contoh | Teks "Nilai demo — bukan nilai resmi" |
| Presensi | Data contoh | Teks "Rekap presensi demo" |
| KTM | Identitas contoh; barcode **dekoratif** (bukan barcode yang bisa discan) | Teks "Barcode dekoratif, bukan alat verifikasi" |
| Pengumuman | Hard-coded | Teks "Pengumuman contoh" |
| Simpan / Bagikan KTM | Tidak ada penyimpanan berkas | Snackbar "Demo: …" |
| Statistik profil (SKS, IPK, jumlah mata kuliah) | Angka contoh | Teks "Angka contoh" |

Tidak ada integrasi SIAKAD, tidak ada backend baru, tidak ada data mahasiswa
nyata, dan tidak ada kredensial sensitif di dalam source code.

---

## 8. Pelacakan progres

| Tahap | Status |
| --- | --- |
| 0 — Audit | ✅ selesai |
| 1 — Dokumentasi & fondasi | ✅ selesai |
| 2 — Design system | ✅ selesai |
| 3 — Navigasi utama | ✅ selesai |
| 4 — Redesign dashboard | ✅ selesai |
| 5A — Login demo | ✅ selesai |
| 5B — Jadwal | ✅ selesai |
| 5C — Fitur akademik | ✅ selesai |
| 5D — Pengumuman | ✅ selesai |
| 5E — Profil & logout | ✅ selesai |
| 6 — Optimasi kode | ✅ selesai |
| 7 — Pengujian | ✅ selesai |
| 8 — Dokumentasi akhir | ✅ selesai |

---

## 9. Hasil implementasi

### 9.1 Struktur akhir

```text
lib/
├── main.dart                  # BoashStudentApp + AppRoot (splash → login/shell)
├── app/app_theme.dart         # ThemeData terpusat
├── core/
│   ├── load_state.dart        # sealed LoadState
│   ├── async_controller.dart  # pemuat data + anti request ganda
│   ├── async_builder.dart     # loading / error+retry / empty / success
│   └── date_format.dart       # format tanggal Indonesia
├── models/                    # 7 model data
├── data/
│   ├── demo_data.dart         # SATU sumber data demo
│   └── demo_repository.dart   # repository + latensi + simulateFailure
├── services/auth_api.dart     # randomuser.me (timeout, status HTTP, AuthSuccess/AuthFailure)
├── state/
│   ├── app_session.dart       # sesi demo di memori
│   └── app_controller.dart    # ChangeNotifier: loadDemoUser / login / logout
├── theme/                     # app_colors, app_spacing, app_radii, app_typography
├── widgets/                   # 12 komponen reusable
└── features/
    ├── splash/splash_screen.dart
    ├── auth/login_screen.dart
    ├── shell/main_shell.dart          # 5 tab, IndexedStack
    ├── dashboard/dashboard_screen.dart
    ├── schedule/schedule_screen.dart
    ├── academic/                      # academic, assignments, assignment_detail,
    │                                  # materials, grades, attendance, ktm
    ├── announcements/                 # announcements + announcement_detail
    └── profile/                       # profile + settings
```

Berkas legacy dari versi 4 tab (`lib/home.dart`, `lib/info.dart`,
`lib/news.dart`, `lib/profile.dart`, `lib/ktm.dart`, `lib/login.dart`,
`lib/welcome.dart`, `lib/session.dart`, `lib/api/auth_api.dart`) sudah
dihapus.

### 9.2 Pengujian

| Berkas test | Jumlah uji |
| --- | --- |
| `test/login_flow_test.dart` | 6 |
| `test/navigation_test.dart` | 2 |
| `test/academic_flow_test.dart` | 4 |
| `test/error_and_empty_state_test.dart` | 3 |
| `test/date_format_test.dart` | 5 |
| **Total** | **20** |

Harness: `test/support/test_harness.dart` dengan `MockClient`
(`package:http/testing.dart`), `AuthApi` yang di-inject,
`DemoRepository(latency: Duration.zero, simulateFailure: true)`, dan
`GoogleFonts.config.allowRuntimeFetching = false` agar test tidak
mengunduh font.

### 9.3 Hasil verifikasi

| Perintah | Hasil |
| --- | --- |
| `dart format lib test` | 57 berkas diformat, 32 berubah |
| `flutter analyze` | **No issues found!** (0 isu) |
| `flutter test` | **All tests passed!** (20 uji) |

### 9.4 Dokumentasi

| Dokumen | Isi |
| --- | --- |
| `README.md` | Panduan menjalankan aplikasi, fitur, login demo, pengujian |
| `REVISI.md` | Checklist revisi P0/P1/P2 beserta status implementasi |
| `WORKFLOW.md` | User journey + pemetaan tahap ke berkas implementasi |
| `design.md` | Design document v2 (token, spesifikasi layar, acceptance criteria) |
| `docs/IMPLEMENTATION_PLAN.md` | Dokumen ini (audit → rencana → hasil) |
