# DESIGN DOCUMENT — Student App (Gaya "E-Learning" Blue)

> Pedoman desain untuk dieksekusi di Flutter. Menggabungkan:
> 1. **Instruksi tugas** — `Pertemuan 3 - Tab menu - StudentApp` (alur Login → Welcome dengan 4 tab: Home, Info, Profile, News; Home = 12 menu icon).
> 2. **Paket desain mobile app** — "E-Learning App" (gradient biru, tombol biru terang, ikon lingkaran, kartu putih bersudut bulat).
> 3. **Aturan sebelumnya** — semua ikon menu **satu warna biru dongker**.
>
> Menggantikan `design.md` versi "Student Portal" (ungu-biru). Status: **siap dieksekusi**.

---

## 1. Ringkasan

| Item | Keterangan |
| --- | --- |
| Nama Aplikasi | Student App |
| Framework | Flutter (Dart SDK `^3.13.4`) |
| Platform | Web (`flutter run -d chrome`), Android, iOS |
| Gaya Visual | E-Learning Blue: gradient biru, kartu putih, ikon lingkaran, font geometris |
| Layar | Login · Home · Info · Profile · News · KTM (6 layar) |
| Navigasi | Login (auth API) → `pushReplacement` → Welcome (shell) → `BottomNavigationBar` 4 tab · menu KTM → `push` `KtmScreen` |
| Aturan ikon | **Semua ikon menu = 1 warna, biru dongker `#1A2B6D`** |

### 1.1 Pemetaan Paket Desain → Kebutuhan Tugas

| Layar paket desain (referensi) | Dipakai untuk | Catatan |
| --- | --- | --- |
| Login your account (username, password, tombol LOGIN) | **`login.dart`** | Dipakai penuh |
| Choose your interests (grid ikon 3 kolom + label) | **Grid 12 menu di `home.dart`** | Gaya ikon lingkaran + label |
| Beranda "Hi, Alina" + search + banner + Top search + Featured | **`home.dart`** | Header, banner, chip, kartu |
| Profil (avatar, ID, statistik, tombol) | **`profile.dart`** | Statistik diganti Courses / GPA / Credits |
| Daftar kartu (Featured, Comments) | **`info.dart`** dan **`news.dart`** | Gaya kartu + list item |
| Splash / Welcome / Pilih metode login | Opsional | Tidak diwajibkan tugas |
| Video player, Comments, Kuis | Tidak dipakai | Di luar lingkup tugas |

> Logo buku di paket desain **tidak disalin**. Gunakan ikon buku sederhana buatan sendiri (`Icons.menu_book`) agar aman dan orisinal.

---

## 2. Struktur File

```
lib/
├── main.dart          # Entry point → LoginScreen
├── login.dart         # Layar login + autentikasi API randomuser.me
├── welcome.dart       # Shell: AppBar "Student App" + BottomNavigationBar (4 tab)
├── home.dart          # Tab 0 — Home (grid menu, termasuk KTM)
├── info.dart          # Tab 1 — Info
├── profile.dart       # Tab 2 — Profile (data dari sesi login)
├── news.dart          # Tab 3 — News
├── ktm.dart           # Kartu Tanda Mahasiswa (dibuka dari menu Home)
├── session.dart       # Data mahasiswa yang login (hasil API)
├── api/
│   └── auth_api.dart  # Pemanggil API randomuser.me
├── theme/
│   └── app_colors.dart    # (disarankan) token warna & gradient
└── widgets/
    ├── menu_icon_tile.dart   # (disarankan) lingkaran ikon + label
    ├── app_snackbar.dart     # SnackBar seragam
    └── section_title.dart    # (disarankan) judul section + "See all"
```

Alur:

```
main.dart → LoginScreen ──(auth API randomuser.me)──► WelcomeScreen
                                                      ├─ HomeScreen    (tab 0)
                                                      ├─ InfoScreen    (tab 1)
                                                      ├─ ProfileScreen (tab 2)
                                                      └─ NewsScreen    (tab 3)

HomeScreen ──(menu "KTM")──► KtmScreen ──(back)──► HomeScreen
```

---

## 3. Design System

### 3.1 Palet Warna

| Token | Hex | Penggunaan |
| --- | --- | --- |
| `gradTop` | `#0B86E0` | Gradient biru — atas |
| `gradMid` | `#0A4FCB` | Gradient biru — tengah |
| `gradBottom` | `#0A2A9E` | Gradient biru — bawah |
| `primary` | `#0B4FCB` | Tombol, tab aktif, link, header Home/Info/News |
| `buttonStart` | `#12A0EE` | Gradient tombol — kiri |
| `buttonEnd` | `#0B5ED7` | Gradient tombol — kanan |
| **`iconNavy`** | **`#1A2B6D`** | **Semua ikon menu & ikon daftar** |
| `iconBg` | `#E8EFFF` | Lingkaran latar ikon |
| `background` | `#FFFFFF` | Latar halaman |
| `surfaceAlt` | `#F3F6FE` | Latar kartu/list lembut |
| `textPrimary` | `#0F1B3D` | Judul |
| `textSecondary` | `#5F6B8A` | Deskripsi, label kecil |
| `onGradient` | `#FFFFFF` | Teks di atas gradient |
| `onGradientSoft` | `#CFE3FF` | Teks sekunder di atas gradient |
| `divider` | `#E6EBF7` | Garis pemisah |
| `badge` | `#EF4444` | Badge notifikasi |

Gradient latar (Login, header): `LinearGradient(begin: topCenter, end: bottomCenter, colors: [#0B86E0, #0A4FCB, #0A2A9E], stops: [0, .45, 1])`.

### 3.2 Tipografi

Font: **Poppins** (paket `google_fonts`) — atau `fontFamily: 'Poppins'` bila aset di-bundle. Cadangan: Roboto.

| Gaya | Ukuran | Berat | Penggunaan |
| --- | --- | --- | --- |
| Display | 28 | Bold (700) | "Information", "News", nama profil |
| Title | 20 | SemiBold (600) | Judul section |
| Card Title | 15–16 | SemiBold (600) | Judul kartu/list |
| Body | 14 | Regular (400) | Isi |
| Label | 12 | Regular/Medium | Label ikon, caption |
| Button | 14 | SemiBold, UPPERCASE, letter-spacing 0.5 | Tombol |
| AppBar | 22 | Bold (700) | "Student App" |

### 3.3 Spacing, Radius, Elevasi

| Token | Nilai |
| --- | --- |
| Padding halaman | 20 |
| Spacing | 4 / 8 / 12 / 16 / 24 / 32 |
| Radius tombol & input | 10 |
| Radius kartu | 16–20 |
| Radius chip | 20 (pill) |
| Lingkaran ikon menu | 64 × 64 |
| Elevasi kartu | bayangan lembut `0 4 14 rgba(11,79,203,.10)` |

### 3.4 Ikon

- Material Icons (`uses-material-design: true`), gaya garis/outline bila ada.
- Ikon menu: **warna `iconNavy`**, ukuran 28, di dalam lingkaran `iconBg` 64.
- Ikon di atas tombol/gradient: putih.
- Dilarang memakai warna ikon lain pada grid menu.

---

## 4. Spesifikasi Layar

### 4.1 Login — `login.dart`

Mengadopsi materi **Pertemuan 4 — Auth Flutter**: halaman login memakai akun dari
API `https://randomuser.me/api/` (`lib/api/auth_api.dart`). Data sesi yang berhasil
login disimpan di `lib/session.dart` (`AppSession`).

| Aspek | Detail |
| --- | --- |
| Latar | Gradient biru penuh (3.1) |
| Isi (atas → bawah) | Ikon buku putih 96 → "STUDENT APP" → "Login your account" → subteks "Sign in with the account from randomuser.me API" → field Username → field Password → tombol LOGIN → pesan status → "Don't have account? **Sign Up**" → kartu "Akun login dari API (untuk testing)" + tombol **Ganti User Acak** |
| Field | Tinggi 52, radius 10, border putih 50%, isi putih 10%, ikon di kiri, teks putih |
| Tombol LOGIN | Tinggi 52, lebar penuh, gradient `buttonStart→buttonEnd`, teks putih UPPERCASE; nonaktif (label `MEMUAT...`) saat data API sedang diambil |
| Data API | `GET randomuser.me/api/` → `results[0]` (username, password, nama, email, `picture.large`). Gagal/jaringan mati → pesan error + tombol ulangi |
| Validasi | Kosong → "Username dan password wajib diisi"; tidak cocok → "Username atau password salah"; cocok → simpan sesi lalu masuk |
| Pesan | Kartu kaca (putih 12%, border putih 35%) + ikon status, di bawah tombol LOGIN |
| Aksi sukses | `AppSession.setFromApiUser(user)` → `Navigator.pushReplacement(... WelcomeScreen())` |
| Widget | `Scaffold` + `Container(decoration: gradient)` + `SingleChildScrollView` + `Column` |

### 4.2 Welcome (Shell) — `welcome.dart`

| Aspek | Detail |
| --- | --- |
| AppBar | Judul "Student App", Bold 22, putih, `centerTitle: true`, `backgroundColor: primary`, `elevation: 4` |
| Body | `IndexedStack` / `_pages[_selectedIndex]` |
| BottomNav | 4 item: Home, Info, Profile, News |
| Aktif / non-aktif | `primary` / `#8A94B0` |
| Tipe | `BottomNavigationBarType.fixed`, latar putih, bayangan tipis atas |

| Index | Label | Ikon |
| --- | --- | --- |
| 0 | Home | `Icons.home` |
| 1 | Info | `Icons.info` |
| 2 | Profile | `Icons.person` |
| 3 | News | `Icons.article` |

### 4.3 Home — `home.dart`

Urutan section:

1. **Header biru** (radius bawah 24): sapaan "Hi, &lt;nama depan sesi&gt;" (default "Alex"), subteks "You are enrolled in Multimedia", ikon search & bell (putih), badge merah.
2. **Search field** putih bersudut bulat, ikon search biru, hint "Find here".
3. **Banner** gradient biru: tag kecil, judul, tombol **VIEW** (putih, teks biru).
4. **Menu** — judul section + "See all", grid **3 kolom × 5 baris = 13 menu**
   (12 menu bawaan + **KTM**).

5. **Top search** — chip: ALL COURSE (aktif, biru), DESIGN, VIDEO.
6. **Featured** — 2 kartu gradient (judul, chip kategori + durasi).

**13 Menu (semua ikon `iconNavy`):**

| No | Label | Ikon |
| --- | --- | --- |
| 1 | KTM | `Icons.badge_outlined` |
| 2 | Profile | `Icons.person_outline` |
| 3 | Events | `Icons.event` |
| 4 | Staffs | `Icons.groups_outlined` |
| 5 | Attendance | `Icons.fact_check_outlined` |
| 6 | Chatbox | `Icons.chat_bubble_outline` |
| 7 | GradeSheet | `Icons.bar_chart` |
| 8 | Gallery | `Icons.photo_library_outlined` |
| 9 | Fees Details | `Icons.attach_money` |
| 10 | Notices | `Icons.description_outlined` |
| 11 | Assignments | `Icons.menu_book_outlined` |
| 12 | Exams | `Icons.assignment_outlined` |
| 13 | Library | `Icons.local_library_outlined` |

Item menu: lingkaran 64 (`iconBg`), ikon 28 `iconNavy`, label 12 `textPrimary` di bawah, rata tengah. Saat ditekan: lingkaran menjadi `iconNavy`, ikon putih. Tap menu **KTM** membuka `KtmScreen`; menu lain menampilkan SnackBar.

### 4.4 Info — `info.dart`

| Aspek | Detail |
| --- | --- |
| Header | Blok biru: "Information" (Display putih) + subteks |
| Daftar | 6 kartu: ikon lingkaran (`iconNavy`) + judul + deskripsi + chevron |
| Isi contoh | Academic Info, Class Schedule, Exam Schedule, Campus Contact, Service Hours, FAQ |
| Aksi bawah | Tombol gradient "CONTACT CAMPUS" |
| Widget | `ListView` + `Card` / `ListTile` |

### 4.5 Profile — `profile.dart`

| Aspek | Detail |
| --- | --- |
| Header | Blok biru dengan avatar bulat 96 (border putih) menimpa tepi bawah; foto diambil dari `AppSession.photoUrl` (API), fallback ikon `person` |
| Identitas | Nama (Display) & "NIM ..." dari `AppSession` |
| Statistik | Kartu 3 kolom: **Courses 12 · GPA 3.80 · Credits 86** |
| Data diri | 3 baris: Email, Program Studi, Phone (ikon `iconNavy`, nilai dari `AppSession`) |
| Aksi | Tombol outline "EDIT PROFILE" + tombol gradient "LOGOUT" → kembali ke `LoginScreen` |
| Widget | `CircleAvatar`, `ListTile`, `Divider`, `ElevatedButton` |

### 4.6 News — `news.dart`

| Aspek | Detail |
| --- | --- |
| Header | Blok biru: "News" |
| Chip filter | All, Campus, Event, Academic |
| Berita utama | 1 kartu besar gradient + judul + tanggal |
| Daftar | 4 item: thumbnail 88×88 (radius 14), judul, tanggal, ringkasan 2 baris |
| Widget | `ListView`, `Card`, `ClipRRect` |

### 4.7 KTM (Kartu Tanda Mahasiswa) — `ktm.dart`

Dibuka dari menu **KTM** di Home (`Navigator.push`), punya tombol back sendiri.

| Aspek | Detail |
| --- | --- |
| Header | Blok biru radius bawah 24: tombol back + judul "Kartu Tanda Mahasiswa" + subteks "Student Identity Card" |
| Kartu | Kartu putih radius 20 + bayangan `cardShadow`, strip gradient: header (logo `menu_book` + "UNIVERSITAS NUSANTARA" + "KARTU TANDA MAHASISWA") dan footer gradient barcode |
| Isi kartu | Foto 78×100 radius 12 (`AppSession.photoUrl`, fallback ikon) + baris NIM, Nama, Program Studi, Fakultas |
| Meta kartu | 3 kotak `surfaceAlt`: Semester · Tahun Akademik · Berlaku s/d |
| Detail bawah | Section "Data Mahasiswa" + 5 baris ikon lingkaran (`iconNavy`): Email, Program Studi, Fakultas, Phone, Tahun Akademik |
| Aksi | Tombol outline "SIMPAN KTM" + tombol gradient "BAGIKAN" (keduanya SnackBar demo) |
| Widget | `ListView`, `Container` gradient, `Image.network`, `ListTile` |

### 4.8 Interaksi (sesuai prototipe)

| Layar | Interaksi | Implementasi Flutter |
| --- | --- | --- |
| Login | Ambil 1 user acak dari API saat halaman dibuka | `initState` → `AuthApi.fetchRandomUser()` |
| Login | LOGIN mencocokkan input dengan username/password API | perbandingan string + `_message` |
| Login | Ganti User Acak → ambil ulang user dari API | `_loadUser()` |
| Login | LOGIN berhasil → Welcome tanpa tombol back | `AppSession.setFromApiUser` + `Navigator.pushReplacement` |
| Login | "Sign Up" hanya menampilkan pesan | `ScaffoldMessenger...showSnackBar` |
| Welcome | Pindah tab, state tiap tab tetap terjaga | `IndexedStack` + `setState` pada `_selectedIndex` |
| Home | Ketik di "Find here" → grid menu tersaring langsung; kosong → teks "No menu matches that search." | `TextField(onChanged)` + `where(...)` pada list menu |
| Home | Tap menu KTM → halaman KTM; menu lain → SnackBar "<nama> opened" | `Navigator.push` / `InkWell.onTap` + `SnackBar` |
| Home | Chip Top search: satu aktif (single select) | `ChoiceChip` / state index |
| Info | Tap kartu → detail terbuka/tertutup (accordion), chevron berputar | `ExpansionTile` atau `AnimatedCrossFade` |
| Profile | LOGOUT → kembali ke Login | `Navigator.pushReplacement(LoginScreen)` |
| KTM | SIMPAN / BAGIKAN → SnackBar demo; back → Home | `showAppSnackBar` / `Navigator.pop` |
| News | Chip kategori (All, Campus, Event, Academic) menyaring daftar; kosong → "No news in this category yet." | state `selectedCategory` + `where(...)` |
| News | Tap berita → SnackBar "Opening: <judul>" | `onTap` + `SnackBar` |

**SnackBar:** latar `#25304F`, teks putih 13, radius 10, `behavior: floating`, durasi 2 detik.

**Detail visual tambahan:** AppBar `primary` tinggi 60 dengan bayangan; header Home/Info/News menyambung dari AppBar (warna sama, radius bawah 24); badge notifikasi berupa titik merah di ikon bell; tag berita memuat kategori (mis. `8 Oct 2026 · Event`).

---

## 5. Komponen Reusable (Flutter)

```dart
// theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const gradTop = Color(0xFF0B86E0);
  static const gradMid = Color(0xFF0A4FCB);
  static const gradBottom = Color(0xFF0A2A9E);
  static const primary = Color(0xFF0B4FCB);
  static const buttonStart = Color(0xFF12A0EE);
  static const buttonEnd = Color(0xFF0B5ED7);
  static const iconNavy = Color(0xFF1A2B6D); // satu warna untuk semua ikon menu
  static const iconBg = Color(0xFFE8EFFF);
  static const surfaceAlt = Color(0xFFF3F6FE);
  static const textPrimary = Color(0xFF0F1B3D);
  static const textSecondary = Color(0xFF5F6B8A);
  static const divider = Color(0xFFE6EBF7);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradTop, gradMid, gradBottom],
    stops: [0, .45, 1],
  );
  static const buttonGradient = LinearGradient(colors: [buttonStart, buttonEnd]);
}
```

```dart
// widgets/menu_icon_tile.dart
class MenuIconTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const MenuIconTile({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              color: AppColors.iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppColors.iconNavy),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
```

Grid Home:

```dart
GridView.count(
  crossAxisCount: 3,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 16,
  crossAxisSpacing: 8,
  childAspectRatio: 0.95,
  children: const [
    MenuIconTile(icon: Icons.badge_outlined, label: 'KTM'),
    MenuIconTile(icon: Icons.person_outline, label: 'Profile'),
    MenuIconTile(icon: Icons.event, label: 'Events'),
    // ... total 13 menu sesuai tabel 4.3
  ],
)
```

---

## 6. Data Dummy

| Layar | Data |
| --- | --- |
| Login | 1 user acak dari `randomuser.me/api/` (username, password, nama, email, foto) |
| Home | 13 menu (termasuk KTM); banner "Math MasterClass"; 2 kartu Featured |
| Info | 6 item informasi kampus |
| Profile | `AppSession`: nama & email dari API · NIM 20240001 · Courses 12 · GPA 3.80 · Credits 86 |
| News | 1 berita utama + 4 berita daftar (judul, tanggal, ringkasan) |
| KTM | NIM 20240001 · nama/foto dari API · Prodi Multimedia · Fakultas Teknik · Semester 5 · berlaku 30 Jun 2027 |

Semua isi adalah **contoh** untuk screenshot tugas; ganti sesuai kebutuhan.

---

## 7. Acceptance Criteria

- [ ] `flutter run -d chrome` jalan tanpa error; `flutter analyze` bersih; `flutter test` lolos.
- [ ] `main.dart` membuka `LoginScreen` bergradient biru.
- [ ] Login memakai akun dari API `randomuser.me`; salah → pesan error, cocok → `WelcomeScreen` (tanpa bisa kembali ke login).
- [ ] 4 tab (Home, Info, Profile, News) pada `BottomNavigationBar`, tiap tab menampilkan konten berbeda.
- [ ] Home menampilkan menu icon grid 3 kolom (13 menu, termasuk **KTM**).
- [ ] **Semua ikon menu berwarna biru dongker `#1A2B6D`**.
- [ ] Info, Profile, News terdesain rapi (sesuai bagian 4).
- [ ] Menu **KTM** membuka halaman kartu tanda mahasiswa berdesain tema biru + tombol back.
- [ ] Logout di Profile kembali ke Login.
- [ ] Siap screenshot: **Login, Home, Info, Profile, News, KTM**.

## 8. Roadmap Eksekusi

| Fase | Pekerjaan |
| --- | --- |
| F1 | 7 file dasar sesuai Word (main, login, welcome, home, info, profile, news) |
| F2 | Pasang tema: `app_colors.dart`, font Poppins |
| F3 | Home: header, search, banner, grid menu, chip, featured |
| F4 | Info, Profile, News |
| F5 | Auth API (Pertemuan 4): `api/auth_api.dart`, `session.dart`, login terintegrasi |
| F6 | Halaman KTM + menu Home |
| F7 | Polish (spacing, radius, bayangan) + `flutter analyze` + `flutter test` |
| F8 | Screenshot 6 halaman → folder Google Drive per nama siswa → kirim link ke WhatsApp |

## 9. Catatan Teknis

- `withOpacity` deprecated → pakai `.withValues(alpha: ...)`.
- Gunakan `const` pada widget statis.
- Font: tambahkan `google_fonts` di `pubspec.yaml`, atau bundle Poppins di `assets/fonts/`.
- Gambar/foto tidak wajib: pakai placeholder gradient + ikon agar tidak bergantung aset.
- Jaga tiap file < ~300 baris; pecah ke `widgets/` bila panjang.
