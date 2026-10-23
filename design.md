# DESIGN DOCUMENT — Boash Student App (Gaya "E-Learning" Blue) v2

> Pedoman desain **v2** hasil implementasi ulang Boash Student App.
> Menggantikan dokumen versi 1 (4 tab: Home/Info/Profile/News).
>
> - **Identitas visual tidak berubah:** gradien biru, kartu putih, ikon
>   lingkaran, satu warna ikon (`iconNavy`), font Poppins.
> - **Perubahan utama v2:** navigasi menjadi **5 tab**
>   (Beranda/Jadwal/Akademik/Pengumuman/Profil), halaman Beranda berubah
>   menjadi *ringkasan aktivitas*, seluruh state memakai satu pola
>   `loading/success/empty/error`, dan setiap data simulasi diberi label
>   **Demo**.
>
> Sumber: `WORKFLOW.md` (user journey), `REVISI.md` (checklist revisi),
> `docs/IMPLEMENTATION_PLAN.md` (rencana implementasi), dan
> `docs/mockup-boash.png` (referensi visual).

---

## 1. Ringkasan

| Item | Keterangan |
| --- | --- |
| Nama Aplikasi | Boash Student App |
| Framework | Flutter 3.47.x · Dart 3.13.x |
| Platform | Web (`flutter run -d chrome`), Android, iOS, desktop |
| Gaya Visual | E-Learning Blue: gradien biru, kartu putih, ikon lingkaran, font Poppins |
| Layar | Splash · Login · Beranda · Jadwal · Akademik (Materi, Tugas, Nilai, Presensi, KTM) · Pengumuman · Profil · Pengaturan |
| Navigasi | `AppRoot` (splash → login/dashboard) → `MainShell` dengan `BottomNavigationBar` 5 tab |
| State | `AsyncController` + `AsyncBuilder` (loading / success / empty / error + retry) |
| Aturan ikon | **Semua ikon menu & daftar = 1 warna, biru dongker `#1A2B6D`** |
| Data | `lib/data/demo_data.dart` sebagai **satu-satunya sumber data demo** |

### 1.1 Peta layar

```text
AppRoot (lib/main.dart)
├── SplashScreen                → selama menyiapkan akun contoh dari API
├── LoginScreen                 → belum login
└── MainShell (5 tab, IndexedStack)
    ├── Beranda     DashboardScreen      (ringkasan aktivitas)
    ├── Jadwal      ScheduleScreen      (harian / mingguan)
    ├── Akademik    AcademicScreen      (hub 5 fitur)
    │   ├── MaterialsScreen   (filter per mata kuliah)
    │   ├── AssignmentsScreen → AssignmentDetailScreen
    │   ├── GradesScreen
    │   ├── AttendanceScreen
    │   └── KtmScreen
    ├── Pengumuman  AnnouncementsScreen → AnnouncementDetailScreen
    └── Profil      ProfileScreen → SettingsScreen, KtmScreen
```

---

## 2. Struktur file

```text
lib/
├── main.dart                  # entry point + AppRoot (splash/login/shell)
├── app/app_theme.dart         # ThemeData terpusat (AppTheme.build())
├── core/
│   ├── load_state.dart        # sealed LoadState
│   ├── async_controller.dart  # pemuat data (anti request ganda)
│   ├── async_builder.dart     # loading / error+retry / empty / success
│   └── date_format.dart       # format tanggal Indonesia
├── models/                    # course, class_session, assignment,
│                              # announcement, course_material, grade, attendance
├── data/
│   ├── demo_data.dart         # SATU sumber data demo
│   └── demo_repository.dart   # repository + latensi + simulateFailure
├── services/auth_api.dart     # pemanggil randomuser.me
├── state/
│   ├── app_session.dart       # data sesi demo
│   └── app_controller.dart    # ChangeNotifier: login/logout/sesi
├── theme/
│   ├── app_colors.dart        # token warna
│   ├── app_spacing.dart       # token jarak
│   ├── app_radii.dart         # token radius
│   └── app_typography.dart    # skala tipografi
├── widgets/                   # komponen reusable
└── features/
    ├── splash/ auth/ shell/ dashboard/ schedule/
    ├── academic/ announcements/ profile/
```

> Aturan: file > 300 baris dipecah; komponen yang dipakai > 2 kali
> dipindahkan ke `lib/widgets/`.

---

## 3. Design system

### 3.1 Palet warna (`lib/theme/app_colors.dart`)

| Token | Hex | Penggunaan |
| --- | --- | --- |
| `primary` | `#0B4FCB` | Tombol, tab aktif, header halaman |
| `primaryDark` | `#093C9E` | Variasi header |
| `primarySoft` | `#E8EFFF` | Latar kartu ringkasan, chip |
| `accent` | `#12A0EE` | Awal gradien tombol |
| `background` | `#F4F7FC` | Latar halaman (netral terang) |
| `surface` | `#FFFFFF` | Permukaan kartu |
| `surfaceAlt` | `#F3F6FE` | Latar baris/metadata |
| `textPrimary` | `#17233F` | Judul & teks utama |
| `textSecondary` | `#5F6B8A` | Deskripsi, label kecil |
| `textMuted` | `#8A94B0` | Metadata, ikon non-aktif |
| `onPrimary` | `#FFFFFF` | Teks di atas biru |
| `onPrimarySoft` | `#CFE3FF` | Teks sekunder di atas biru |
| `divider` | `#E6EBF7` | Garis pemisah |
| **`iconNavy`** | **`#1A2B6D`** | **Semua ikon menu & ikon daftar** |
| `iconBg` | `#E8EFFF` | Lingkaran latar ikon |
| `success` / `successBg` | `#15803D` / `#E7F6EC` | Status berhasil |
| `warning` / `warningBg` | `#B45309` / `#FEF3C7` | Peringatan & label **Demo** |
| `danger` / `dangerBg` | `#B91C1C` / `#FDE7E7` | Error & tenggat lewat |
| `info` / `infoBg` | `#0B4FCB` / `#E8EFFF` | Kategori/label informasi |

Gradien:

- `bgGradient` — `#0B86E0 → #0A4FCB → #0A2A9E` (stops `0, .45, 1`),
  dipakai pada layar login dan header halaman.
- `buttonGradient` — `#12A0EE → #0B4FCB`, dipakai pada area hero (KTM).

Bayangan: `cardShadow` (`0 4 14 rgba(11,79,203,.10)`) dan `softShadow`
(`0 2 10 rgba(11,79,203,.06)`).

### 3.2 Tipografi (`lib/theme/app_typography.dart`)

Font **Poppins** (`google_fonts`), cadangan Roboto.

| Peran | Ukuran | Berat | Penggunaan |
| --- | --- | --- | --- |
| Display | 26 | 700 | Nama profil, judul besar |
| Title | 20 | 600 | Judul section & header halaman |
| Title medium | 16 | 600 | Judul kartu |
| Body large | 15 | 400 | Isi |
| Body medium | 13 | 400 | Deskripsi |
| Body small | 11 | 400 | Metadata |
| Label large | 14 | 600 | Teks tombol |
| Button | 14 | 600, `letterSpacing 0.5` | Label tombol (kapital) |

### 3.3 Spacing, radius, elevasi

| Token | Nilai |
| --- | --- |
| `AppSpacing` | `xxs 2`, `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 20`, `xxl 24`, `xxxl 32` |
| Padding halaman | `AppSpacing.pageH = 20` |
| Padding bawah | `AppSpacing.pageBottom = 24` (aman dari bottom navigation) |
| Radius input/button | 12 |
| Radius kartu | 16 |
| Radius sheet | 20 (atas) |
| Radius chip | pill (999) |
| Lingkaran ikon menu | 44–64 px |

### 3.4 Ikon

- Material Icons, gaya outline bila tersedia.
- Ikon menu/daftar: **`iconNavy`**, di dalam lingkaran `iconBg`.
- Ikon di atas gradien: putih.
- Larang memakai warna ikon lain pada grid menu.
- Ikon-only wajib memakai `Semantics(label: ...)` atau `tooltip`.

---

## 4. Spesifikasi layar

### 4.1 Splash — `lib/features/splash/splash_screen.dart`

| Aspek | Detail |
| --- | --- |
| Latar | `AppColors.primary` penuh |
| Isi | Ikon buku putih (96, radius 28) → "BOASH" (letterSpacing 6) → "STUDENT APP" → "Versi demo - data simulasi" → spinner |
| Durasi | ±0,9 s sambil menyiapkan akun contoh dari API |

### 4.2 Login — `lib/features/auth/login_screen.dart`

| Aspek | Detail |
| --- | --- |
| Latar | Gradien biru penuh |
| Isi (atas → bawah) | Ikon buku → "BOASH STUDENT APP" → "Masuk ke akun Anda" → subteks demo → field Username → field Password → tombol **MASUK** → catatan autentikasi demo → kartu **"AKUN DEMO DARI API ACAK"** → "Belum punya akun? Daftar" |
| Field | `AppTextField`: label di atas, ikon kiri, tinggi ~52, validasi inline di bawah field |
| Password | `obscureText` + tombol mata (tampilkan/sembunyikan) |
| Tombol **MASUK** | `AppButton` full width; menampilkan spinner dan nonaktif saat `LoginState.submitting` |
| Kartu akun demo | Menampilkan username; **password disembunyikan** (`••••••••`) sampai tombol mata ditekan; tombol **Isi otomatis** dan **Ganti akun** |
| API gagal | Pesan error + tombol **Coba lagi** di dalam kartu |
| Submit | Cocokkan input dengan username/password profil contoh dari API. **Bukan** autentikasi kampus |

### 4.3 Beranda — `lib/features/dashboard/dashboard_screen.dart`

Urutan konten (paling penting di atas lipatan layar):

1. **Header biru** (radius bawah 24): sapaan sesuai jam ("Selamat pagi, Budi"),
   subjudul program studi, badge **Data simulasi**, avatar (foto API dengan
   fallback inisial).
2. **Jadwal Hari Ini** — kartu sesi (jam, mata kuliah, ruang, dosen) +
   tombol "Lihat semua"; **empty state** bila tidak ada sesi.
3. **Tugas Terdekat** — 3 tugas dengan badge tenggat relatif
   ("Hari ini 23:00", "2 hari lagi"); warna merah bila < 48 jam.
4. **Pengumuman Terbaru** — 3 pengumuman (kategori, tanggal, ringkasan).
5. **Akses Cepat** — grid 4 kolom: Jadwal, Akademik, Materi, Tugas, Nilai,
   Presensi, KTM, Pengumuman.

### 4.4 Jadwal — `lib/features/schedule/schedule_screen.dart`

| Aspek | Detail |
| --- | --- |
| Header | `PageHeader` "Jadwal" + subjudul |
| Pemilih tampilan | Segmented control **Harian / Mingguan** (bingkai pill) |
| Pemilih hari | 7 chip hari (Sen–Min); hari ini diberi label "Hari ini" |
| Kartu sesi | Jam (chip biru) · mata kuliah · ruang · dosen |
| Detail sesi | **Bottom sheet**: hari, jam, ruang, dosen, kode mata kuliah + catatan demo |
| Empty state | "Tidak ada jadwal pada hari ini" + petunjuk memilih hari lain |

### 4.5 Akademik — `lib/features/academic/`

**`academic_screen.dart`** — hub fitur:

- Grid 3 kolom (5 menu): Materi, Tugas, Nilai, Presensi, KTM.
- Catatan demo di bawah grid.
- Daftar mata kuliah semester berjalan (kode, nama, dosen, SKS) → diklik
  membuka materi mata kuliah tersebut.

**`materials_screen.dart`** — daftar materi (jenis berkas, tanggal
pembaruan, ukuran). Aksi "Buka" hanya menampilkan snackbar demo.

**`assignments_screen.dart`** — daftar tugas dengan filter status
(Semua / Belum dikerjakan / Dikerjakan / Dikumpulkan + jumlah), kartu berisi
badge status, tenggat relatif, mata kuliah, dan cuplikan deskripsi.

**`assignment_detail_screen.dart`** — judul, mata kuliah, status, deskripsi,
tenggat + sisa waktu, file pendukung contoh, dan tombol **KUMPULKAN TUGAS**
(dialog konfirmasi → status berubah menjadi **SUDAH DIKUMPULKAN**). Status
perubahan hanya lokal.

**`grades_screen.dart`** — ringkasan (IPK, jumlah mata kuliah, jumlah nilai
lulus) + kartu nilai per mata kuliah (Tugas 40 %, UTS 40 %, UAS 60 % dari
sisa bobot) dan grade huruf A–E.

**`attendance_screen.dart`** — rekap per mata kuliah: persentase kehadiran,
progress bar, serta jumlah hadir/sakit/izin/tanpa keterangan.

**`ktm_screen.dart`** — kartu KTM digital contoh: header gradien, avatar,
NIM/nama/prodi/fakultas, meta semester & tahun akademik, barcode **dekoratif**,
dan tombol **BAGIKAN KTM** / **SIMPAN KTM** (snackbar demo).

### 4.6 Pengumuman — `lib/features/announcements/`

- `announcements_screen.dart`: pencarian + filter kategori (Akademik, Kampus,
  Acara, Beasiswa) lengkap dengan jumlah; kartu berisi kategori, tanggal,
  judul, ringkasan, dan penulis.
- `announcement_detail_screen.dart`: judul, kategori, tanggal, penulis, isi
  lengkap, dan catatan bahwa isi tersebut adalah contoh.

### 4.7 Profil — `lib/features/profile/`

- `profile_screen.dart`: header biru (avatar, nama, NIM, prodi, badge demo),
  ringkasan **Total SKS / IPK / Mata kuliah**, daftar data mahasiswa, menu
  (KTM, Pengaturan, Tentang), catatan demo, dan tombol
  **KELUAR DARI AKUN DEMO** dengan dialog konfirmasi.
- `settings_screen.dart`: bagian Tampilan, Akun demo (ganti akun contoh),
  Aplikasi, dan tombol keluar. Tidak ada pengaturan akun resmi.

### 4.8 Komponen reusable

| Widget | Fungsi |
| --- | --- |
| `AppButton` | Tombol dengan varian primary/secondary/ghost/danger, ikon, spinner |
| `AppTextField` | Input dengan label, ikon, validasi inline, tombol lihat password |
| `AppCard` | Permukaan kartu putih, radius 16, bayangan lembut, `onTap` opsional |
| `StatusBadge` | Lencana status **berupa teks** (bukan hanya warna) |
| `PageHeader` | Header biru seragam dengan judul, subjudul, dan slot aksi |
| `ProfileAvatar` | Avatar foto API dengan fallback inisial |
| `DemoNote` / `DemoNotice` | Penanda data/aksi simulasi (badge & baris kartu) |
| `EmptyState` / `ErrorState` / `LoadingView` | State loading/empty/error seragam |
| `MenuIconTile` | Lingkaran ikon + label untuk grid menu |
| `SectionTitle` | Judul section + aksi "Lihat semua" |
| `showAppSnackBar` | Snackbar gelap dengan varian info/success/error |

### 4.9 Pola state (wajib di semua halaman data)

```text
LoadIdle/LoadLoading → LoadingView (indikator + pesan)
LoadError            → ErrorState (pesan + tombol "Coba lagi")
LoadSuccess + data kosong → EmptyState (ikon + judul + penjelasan)
LoadSuccess          → isi halaman (RefreshIndicator untuk muat ulang)
```

---

## 5. Data demo

| Layar | Sumber |
| --- | --- |
| Login | 1 profil acak dari `randomuser.me` |
| Mata kuliah | `DemoData.courses` (MK-01 … MK-08) |
| Jadwal | `DemoData.buildSchedule()` (Senin–Jumat, acuan 5 Jan 2026) |
| Tugas | `DemoData.buildAssignments(now)` (T-01 … T-06) |
| Materi | `DemoData.buildMaterials(now)` (M-01 … M-06) |
| Nilai | `DemoData.grades` (8 mata kuliah, bobot tugas 40 %) |
| Presensi | `DemoData.attendance` (8 mata kuliah) |
| Pengumuman | `DemoData.buildAnnouncements(now)` (AN-01 … AN-06) |

Semua isi adalah **data contoh**; nama mata kuliah, jadwal, dan tugas selalu
konsisten antar layar karena sumbernya satu.

---

## 6. Acceptance criteria (v2)

- [x] `flutter analyze` bersih (0 isu) dan `flutter test` lolos (20 uji).
- [x] `main.dart` membuka splash, lalu login, lalu dashboard.
- [x] Login memakai akun dari `randomuser.me`; salah → pesan error, cocok →
      sesi demo tersimpan dan dashboard tampil.
- [x] 5 tab (Beranda, Jadwal, Akademik, Pengumuman, Profil) pada
      `BottomNavigationBar`, state tiap tab tetap terjaga (`IndexedStack`).
- [x] Beranda menampilkan ringkasan aktivitas, bukan katalog menu generik.
- [x] Halaman Akademik menyediakan Materi, Tugas, Nilai, Presensi, dan KTM.
- [x] **Semua ikon menu berwarna biru dongker `#1A2B6D`**.
- [x] Setiap halaman data punya loading, error, empty state, dan retry.
- [x] Semua data simulasi diberi penanda **Demo** di UI.
- [x] Logout menghapus sesi demo dengan konfirmasi dan kembali ke login.
- [x] KTM menampilkan barcode dekoratif yang **tidak diklaim** sebagai
      alat verifikasi.

## 7. Catatan teknis

- `withOpacity` deprecated → pakai `.withValues(alpha: ...)`.
- Gunakan `const` pada widget statis.
- `google_fonts` mengunduh font saat runtime; pada mode offline teks tetap
  terbaca dengan font cadangan.
- Jangan menaruh kredensial sensitif di source code.
- Jaga tiap file < ~300 baris.
