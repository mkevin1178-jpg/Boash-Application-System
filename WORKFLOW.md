# WORKFLOW.md --- User Journey Boash Student App

## 1. Tujuan

Dokumen ini menjelaskan alur pengguna aplikasi **Boash Student App**,
sebuah aplikasi beta untuk proyek PBL sistem kampus. Aplikasi berfokus
pada simulasi pengalaman mahasiswa dalam mengakses informasi akademik
dan non-akademik. Data login boleh menggunakan API acak karena aplikasi
ini merupakan prototipe/PBL, bukan sistem produksi yang memerlukan data
mahasiswa asli.

## 2. Persona dan kebutuhan pengguna

**Persona utama:** mahasiswa yang ingin mengetahui jadwal kuliah,
materi, tugas, nilai, presensi, pengumuman kampus, dan informasi akun
melalui satu aplikasi.

**Kebutuhan utama:** - Masuk dengan alur login demo yang mudah
dipahami. - Melihat ringkasan aktivitas penting tanpa membuka banyak
menu. - Menemukan jadwal, tugas, materi, dan pengumuman dengan cepat. -
Mendapatkan feedback yang jelas ketika data sedang dimuat, berhasil
ditampilkan, atau gagal dimuat. - Mengelola profil demo dan keluar dari
aplikasi dengan aman.

## 3. Alur utama (happy path)

``` mermaid
flowchart TD
    A[Pengguna membuka aplikasi] --> B[Splash Screen]
    B --> C{Sudah ada sesi demo?}
    C -- Tidak --> D[Halaman Login]
    C -- Ya --> E[Dashboard]
    D --> F[Isi email/username dan password demo]
    F --> G{Input valid?}
    G -- Tidak --> H[Tampilkan pesan validasi]
    H --> D
    G -- Ya --> I[Autentikasi melalui API acak]
    I --> J{Respons API berhasil?}
    J -- Tidak --> K[Tampilkan error dan tombol coba lagi]
    K --> D
    J -- Ya --> L[Simpan sesi demo]
    L --> E
    E --> M{Pilih kebutuhan}
    M --> N[Jadwal Kuliah]
    M --> O[Menu Akademik]
    M --> P[Pengumuman]
    M --> Q[Profil]
    O --> R[Materi / Tugas / Nilai / Presensi / KTM]
    R --> S[Lihat detail atau lakukan aksi demo]
    N --> T[Kembali ke Dashboard atau navigasi lain]
    P --> T
    S --> T
    Q --> U[Edit profil demo / Pengaturan]
    U --> T
    T --> V{Keluar?}
    V -- Tidak --> M
    V -- Ya --> W[Hapus sesi demo]
    W --> X[Kembali ke Login]
```

## 4. Detail perjalanan per tahap

  -----------------------------------------------------------------------
  Tahap             Aksi pengguna     Respons aplikasi  Kondisi yang
                                                        perlu dirancang
  ----------------- ----------------- ----------------- -----------------
  1\. Membuka       Menjalankan Boash Splash screen     Transisi singkat;
  aplikasi                            lalu memeriksa    jangan membuat
                                      sesi              pengguna menunggu
                                                        tanpa indikator

  2\. Login         Mengisi           Validasi form     Input kosong,
                    email/username    lalu request ke   format salah,
                    dan password demo API acak          jaringan gagal,
                                                        API gagal, tombol
                                                        loading

  3\. Dashboard     Melihat ringkasan Jadwal, tugas     Empty state bila
                    hari ini          terdekat,         data tidak
                                      pengumuman, dan   tersedia; konten
                                      menu cepat        utama mudah
                                                        dipindai

  4\. Jadwal        Membuka menu      Daftar jadwal     Hari aktif
                    Jadwal            harian/mingguan   terlihat;
                                      dan detail kelas  tampilkan jam,
                                                        mata kuliah,
                                                        ruang, dan dosen
                                                        demo

  5\. Akademik      Membuka menu      Pilihan Materi,   Setiap menu
                    Akademik          Tugas, Nilai,     memiliki status
                                      Presensi, dan KTM dan feedback yang
                                                        konsisten

  6\. Detail tugas  Membuka tugas     Deskripsi,        Tandai status
                                      tenggat,          tugas dan batas
                                      lampiran, dan     waktu dengan
                                      aksi pengumpulan  jelas
                                      simulasi          

  7\. Pengumuman    Membuka daftar    Daftar pengumuman Bedakan
                    pengumuman        kampus demo       pengumuman baru
                                                        dan lama;
                                                        tampilkan tanggal

  8\. Profil        Membuka profil    Identitas demo,   Avatar fallback;
                                      pengaturan,       jelaskan bahwa
                                      bantuan, dan      data bersifat
                                      tombol keluar     simulasi bila
                                                        perlu

  9\. Logout        Menekan Keluar    Sesi demo         Konfirmasi agar
                    dan mengonfirmasi dibersihkan dan   tidak keluar
                                      pengguna kembali  tanpa sengaja
                                      ke login          
  -----------------------------------------------------------------------

## 5. Navigasi yang disarankan

Gunakan **bottom navigation dengan lima menu utama**: 1. **Beranda** ---
ringkasan aktivitas dan shortcut. 2. **Jadwal** --- jadwal
harian/mingguan. 3. **Akademik** --- materi, tugas, nilai, presensi, dan
KTM. 4. **Pengumuman** --- informasi kampus. 5. **Profil** --- profil
demo, pengaturan, bantuan, dan logout.

Hindari menaruh semua fitur di bottom navigation. Fitur yang masih satu
konteks sebaiknya dikelompokkan di halaman Akademik.

## 6. Alur alternatif dan error state

### Login

-   Field kosong: tampilkan validasi langsung di bawah field.
-   API lambat: tampilkan loading dan nonaktifkan tombol login selama
    request berlangsung.
-   API tidak tersedia: tampilkan pesan ramah, tombol **Coba Lagi**, dan
    jangan mengunci pengguna di layar loading.
-   Kredensial demo tidak cocok dengan mekanisme API: tampilkan petunjuk
    sesuai mekanisme demo yang memang diimplementasikan. Jangan
    menampilkan password rahasia di UI.

### Data akademik

-   Belum ada data: tampilkan empty state dengan penjelasan, bukan
    halaman kosong.
-   Gagal memuat: tampilkan pesan dan tombol muat ulang.
-   Aksi masih simulasi: beri label **Demo** atau **Simulasi** agar
    pengguna tidak mengira data sungguhan telah tersimpan.

### Profil dan sesi

-   Foto tidak tersedia: gunakan avatar default.
-   Sesi kedaluwarsa atau tidak valid: arahkan kembali ke login dengan
    pesan yang jelas.
-   Logout: hapus data sesi lokal yang digunakan oleh aplikasi demo.

## 7. Touchpoint dan emosi pengguna

  -----------------------------------------------------------------------
  Touchpoint        Harapan pengguna  Risiko UX         Solusi
  ----------------- ----------------- ----------------- -----------------
  Splash dan login  Aplikasi mudah    Tidak tahu cara   Label field dan
                    dimulai           masuk             instruksi demo
                                                        yang jelas

  Dashboard         Informasi penting Terlalu ramai     Prioritaskan
                    langsung terlihat                   jadwal, tugas
                                                        terdekat,
                                                        pengumuman

  Jadwal            Cepat menemukan   Informasi padat   Kelompokkan per
                    kelas                               hari dan
                                                        tampilkan jam
                                                        dengan konsisten

  Tugas             Paham apa yang    Tenggat/status    Badge status,
                    harus dikerjakan  tidak terlihat    deadline, dan
                                                        detail yang
                                                        terstruktur

  Pengumuman        Menemukan         Semua item        Tanggal,
                    informasi terbaru terlihat sama     kategori, dan
                                                        indikator belum
                                                        dibaca

  Profil            Memahami akun     Mengira data demo Gunakan data
                    demo              adalah data resmi contoh dan
                                                        penjelasan
                                                        seperlunya
  -----------------------------------------------------------------------

## 8. Kriteria keberhasilan UX

-   Pengguna baru dapat masuk ke dashboard tanpa kebingungan.
-   Pengguna dapat menemukan jadwal, tugas, dan pengumuman melalui
    maksimal dua atau tiga interaksi dari dashboard.
-   Setiap request memiliki loading, success, error, dan empty state
    yang relevan.
-   Navigasi konsisten di seluruh halaman.
-   Aksi yang belum terhubung ke backend diberi penanda simulasi.
-   Tampilan tetap terbaca di ukuran layar kecil dan besar.
-   Alur login dan logout dapat diuji tanpa data mahasiswa asli.

## 9. Batasan PBL

Aplikasi ini adalah **beta/prototipe PBL**. API acak dapat dipakai untuk
simulasi login atau pengisian profil, sesuai implementasi yang tersedia.
Jangan menyatakan autentikasi tersebut sebagai autentikasi kampus resmi.
Fitur seperti pengumpulan tugas, nilai, presensi, dan verifikasi KTM
boleh memakai data mock selama status simulasi dinyatakan dengan jelas.

## 10. Status implementasi

Dokumen ini dipakai sebagai acuan alur; berikut pemetaannya ke kode yang
sudah berjalan.

| Tahap | Halaman / file | Status |
| --- | --- | --- |
| 1. Membuka aplikasi | `lib/features/splash/splash_screen.dart` (dipanggil `AppRoot` di `lib/main.dart`) | Selesai |
| 2. Login demo | `lib/features/auth/login_screen.dart` + `lib/services/auth_api.dart` | Selesai |
| 3. Dashboard | `lib/features/dashboard/dashboard_screen.dart` | Selesai |
| 4. Jadwal | `lib/features/schedule/schedule_screen.dart` | Selesai |
| 5. Akademik | `lib/features/academic/academic_screen.dart` | Selesai |
| 6. Detail tugas | `lib/features/academic/assignment_detail_screen.dart` | Selesai |
| 7. Pengumuman | `lib/features/announcements/announcements_screen.dart` + `announcement_detail_screen.dart` | Selesai |
| 8. Profil | `lib/features/profile/profile_screen.dart` + `settings_screen.dart` | Selesai |
| 9. Logout | `AppController.logout()` (dialog konfirmasi) | Selesai |

Catatan tambahan:

-   Alur sesi ditangani satu titik di `AppRoot`: setelah `loadDemoUser()`
    selesai, `ListenableBuilder` memilih `LoginScreen` atau `MainShell`
    sehingga tidak ada `Navigator.pushReplacement` manual.
-   Navigasi utama: 5 tab (`Beranda`, `Jadwal`, `Akademik`, `Pengumuman`,
    `Profil`) memakai `IndexedStack` agar state tiap tab terjaga.
-   Setiap layar data memakai pola state yang sama: loading → success,
    dengan cabang error (tombol **Coba lagi**) dan empty state.
-   Pengujian otomatis ada di `test/` (login, navigasi, alur akademik,
    error/empty state, format tanggal).
