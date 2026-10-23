# Prompt OpenCode — Implementasi Login, Akademik (KRS & KTM)

Kamu sedang mengerjakan repository Flutter **Boash-Application-System**. Baca `DESIGN.md` sampai selesai sebelum melakukan perubahan. Jadikan dokumen tersebut sebagai spesifikasi utama dan ikuti urutan implementasi yang ditentukan.

## Tujuan pekerjaan

Selesaikan tiga task secara bertahap:

1. Audit dan perbaiki Login UI/autentikasi agar menggunakan API mahasiswa yang ditentukan.
2. Tambahkan submenu KRS di dalam menu **Akademik** untuk pengisian KRS.
3. Tambahkan submenu KTM di dalam menu **Akademik** untuk melihat dan mengunduh KTM mahasiswa.

## Aturan wajib

- **Jangan mengubah desain, layout, warna, tipografi, spacing, navigasi, atau komponen yang tidak terkait dengan tiga task.**
- Jangan melakukan redesign dashboard atau halaman yang sudah ada.
- KRS dan KTM **harus berada di dalam menu Akademik**. Jangan membuat KRS atau KTM sebagai menu utama/top-level navigation terpisah.
- Pertahankan design system yang sudah ada. Periksa `lib/theme/app_colors.dart` dan gunakan token warna yang tersedia.
- Ikuti struktur file, routing, state management, pola API, dan gaya penulisan kode yang benar-benar digunakan repository. Audit dahulu; jangan menebak nama file atau membuat arsitektur baru tanpa kebutuhan.
- Jangan menghapus fitur yang sudah berfungsi.
- Jangan mengarang data mahasiswa, mata kuliah, SKS, jadwal, atau status akademik.
- Jangan menyatakan operasi berhasil jika backend tidak benar-benar menyimpan data atau menghasilkan file.
- Kerjakan satu task pada satu waktu. Setelah setiap task, jalankan pemeriksaan yang relevan sebelum lanjut.
- Jangan berhenti hanya dengan memberi rekomendasi. Implementasikan perubahan di repository jika akses tulis tersedia.

## Task 1 — Login UI dan API mahasiswa

API nilai:
`https://6adab9277512f497b30020ef.mockapi.io/nilai?npm=12523030`

URL tersebut adalah endpoint resource nilai yang difilter menggunakan query `npm`. Angka `12523030` hanya contoh NPM dari URL; gunakan NPM mahasiswa yang sedang login secara dinamis, jangan hard-code untuk semua pengguna.

Langkah:
1. Audit seluruh struktur `lib/`, login screen, model mahasiswa, service API, navigasi setelah login, serta sumber data user yang sekarang digunakan.
2. Verifikasi respons endpoint dan field yang benar-benar tersedia sebelum menulis parsing atau validasi.
3. Ganti penggunaan data nilai acak/mock dengan data dari endpoint nilai tersebut. **Jangan menggunakan endpoint `/nilai` untuk autentikasi atau verifikasi password** kecuali audit kontrak API membuktikan endpoint tersebut memang mendukungnya.
4. Untuk mengambil data nilai, gunakan **NPM mahasiswa yang sedang login** sebagai query `npm`. Verifikasi field respons dan mapping nilainya terlebih dahulu. Jangan menganggap field `id` sama dengan NPM. Endpoint nilai ini tidak otomatis menyediakan data autentikasi atau profil.
5. Password diminta menggunakan SHA-1. Periksa kontrak API terlebih dahulu. Jangan menganggap hash SHA-1 aman untuk produksi, jangan mencetak password/hash ke log, dan jangan mengirim hash ke server tanpa memastikan bahwa memang itulah kontrak API. Dokumentasikan keterbatasan ini. Untuk produksi, verifikasi password harus dilakukan di backend dengan password hashing yang sesuai.
6. Tangani input kosong, kredensial salah, loading, timeout, koneksi gagal, dan respons JSON tidak sesuai.
7. Pertahankan desain login yang sudah disepakati: header atas dengan blur lembut dan ikon dekoratif; panel/form putih dengan sudut atas besar membulat; field NPM dan password berbentuk rectangle dengan sudut membulat. Jangan mengubah layar lain.
8. Pastikan identitas mahasiswa yang sudah terautentikasi melalui mekanisme yang valid dapat dipakai oleh fitur Akademik, KRS, dan KTM. Data nilai diambil dari endpoint `/nilai` berdasarkan NPM aktif. Jika proyek belum memiliki sumber autentikasi/profil yang valid, laporkan kebutuhan tersebut; jangan menyalahgunakan endpoint nilai sebagai login.

## Task 2 — KRS di dalam Akademik

1. Temukan menu/halaman **Akademik** yang sudah ada.
2. Tambahkan item **KRS sebagai submenu di dalam Akademik**. Jangan menambahkannya ke bottom navigation atau daftar menu utama jika itu membuatnya menjadi menu top-level baru.
3. Pertahankan layout dan gaya visual Akademik. Tambahkan hanya komponen yang diperlukan.
4. Buat alur pengisian KRS berdasarkan data yang benar-benar tersedia: daftar mata kuliah, informasi kode/nama/SKS/jadwal bila ada, pemilihan mata kuliah, ringkasan SKS, serta simpan/ajukan jika backend mendukung.
5. Terapkan validasi akademik hanya bila aturan resmi tersedia. Jangan mengarang batas SKS, prasyarat, jadwal, atau periode KRS.
6. Jika backend KRS belum tersedia, buat empty state/prototipe yang jelas dan jangan berpura-pura menyimpan data.
7. Pastikan KRS terhubung dengan mahasiswa yang sedang login.

Kriteria:
- KRS dapat dibuka melalui **Akademik → KRS**.
- KRS tidak menjadi menu utama terpisah.
- Perhitungan ringkasan mengikuti pilihan aktual.
- Status simpan/error dijelaskan secara jujur.

## Task 3 — KTM di dalam Akademik

1. Tambahkan item **KTM sebagai submenu di dalam Akademik**. Jangan menjadikannya menu utama terpisah.
2. Ambil data mahasiswa dari sesi/API mahasiswa yang sedang login, bukan data hard-coded atau acak.
3. Periksa field yang tersedia untuk nama, NPM, program studi, foto, dan detail kartu lain. Tampilkan hanya data yang tersedia dan sesuai.
4. Buat halaman pratinjau KTM yang konsisten dengan design system Boash.
5. Implementasikan unduh/ekspor KTM ke file yang benar-benar dapat dibuka; gunakan PDF jika cocok dengan dependency dan target platform yang ada.
6. Tangani data tidak lengkap, loading, error ekspor, dan izin penyimpanan sesuai kebutuhan platform.
7. Jangan membuat KTM yang tampak resmi dari data yang belum terverifikasi. Beri label DEMO untuk data demo.

Kriteria:
- KTM dapat dibuka melalui **Akademik → KTM**.
- KTM tidak menjadi menu utama terpisah.
- Informasi kartu sesuai mahasiswa yang login.
- Tombol unduh menghasilkan file valid, bukan hanya notifikasi sukses palsu.

## Urutan kerja

1. Baca `DESIGN.md` dan audit repository serta status Git terlebih dahulu.
2. Temukan menu Akademik dan petakan routing serta komponen yang ada.
3. Verifikasi struktur respons API.
4. Implementasikan Task 1, lalu uji.
5. Implementasikan Task 2 di bawah Akademik, lalu uji.
6. Implementasikan Task 3 di bawah Akademik, lalu uji.
7. Jalankan `flutter analyze` dan `flutter test` jika tersedia.
8. Periksa diff untuk memastikan tidak ada perubahan tidak terkait dan tidak ada layout halaman lain yang berubah.
9. Perbaiki error yang disebabkan perubahan ini.
10. Laporkan ringkasan file yang diubah, hasil tes, keterbatasan backend, dan bagian yang masih membutuhkan API/aturan akademik.

## Definisi selesai

Pekerjaan hanya dianggap selesai bila:
- Ketiga task ditangani.
- KRS dan KTM berada di dalam **Akademik**.
- Pengambilan data nilai menggunakan endpoint API dan query NPM dinamis sesuai skema respons yang telah diverifikasi; autentikasi tidak dianggap selesai hanya dengan endpoint nilai.
- Perubahan visual dibatasi pada login dan elemen baru yang diperlukan untuk KRS/KTM.
- Pemeriksaan Flutter dijalankan dan hasilnya dilaporkan dengan jujur.
