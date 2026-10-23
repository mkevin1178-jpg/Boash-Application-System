# DESIGN.md — Boash Application System

> Audit awal dan rencana implementasi untuk aplikasi beta Boash berbasis Flutter.
>
> **Batasan utama:** jangan mengubah desain, layout, navigasi, atau komponen yang sudah ada selain penambahan yang secara eksplisit diminta dalam tiga task berikut.

## 1. Ringkasan audit awal

Audit awal dilakukan terhadap file yang tersedia pada branch `main`:

- `pubspec.yaml` menunjukkan aplikasi Flutter dengan dependency `google_fonts`, `http`, dan Material Icons.
- `lib/main.dart` mengatur `MaterialApp`, menggunakan Poppins, Material 3, dan membuka `LoginScreen` sebagai halaman awal.
- `lib/theme/app_colors.dart` memiliki palet terpusat: primary `#0B4FCB`, gradient biru, ikon navy `#1A2B6D`, latar alternatif `#F3F6FE`, teks utama `#0F1B3D`, dan teks sekunder `#5F6B8A`.
- `README.md` masih berupa template awal Flutter dan berisi marker merge-conflict (`<<<<<<< HEAD`, `=======`, `>>>>>>>`). Perbaiki secara terpisah hanya jika diizinkan.
- `main.dart` mengimpor `api/auth_api.dart` dan `login.dart`; file pada path tersebut tidak ditemukan saat pemeriksaan path awal. Verifikasi struktur aktual dan nama file sebelum implementasi. Jangan membuat ulang file atau mengganti arsitektur berdasarkan asumsi.

Audit ini bersifat awal, bukan klaim bahwa seluruh source code telah ditinjau. Sebelum coding, inventarisasi file di `lib/`, rute, model data, serta implementasi autentikasi dan dashboard yang benar-benar ada.

## 2. Prinsip desain yang tidak boleh dilanggar

1. **Jangan redesign halaman lain.** Pertahankan layout, warna, ukuran, jarak, tipografi, ikon, navigasi, dan interaksi yang sudah ada.
2. Login boleh diperbarui hanya untuk menerapkan konsep yang disepakati: header atas berwarna/gradient biru dengan blur lembut dan objek ikon dekoratif; panel/form putih di bawah dengan sudut atas besar dan membulat; field NPM/username dan password berbentuk rectangle dengan sudut membulat; tombol utama konsisten dengan tema.
3. Gunakan token warna dari `lib/theme/app_colors.dart` jika sesuai. Hindari menambahkan warna baru tanpa alasan.
4. Gunakan komponen dan pola kode yang sudah dipakai proyek. Jangan menambahkan dependency baru bila fitur bisa dibuat dengan dependency yang tersedia.
5. **KRS dan KTM wajib berada di dalam menu/fitur Akademik**, bukan sebagai menu utama yang berdiri sendiri. Pertahankan menu Akademik yang sudah ada; tambahkan KRS dan KTM sebagai submenu atau item di dalam halaman Akademik sesuai pola navigasi proyek. Jangan mengubah menu yang tidak terkait.
6. Jika data backend belum tersedia atau skema API belum cocok, tampilkan keadaan kosong/error yang ramah. Jangan mengarang data mahasiswa atau status akademik.

## 3. Task 1 — Audit dan implementasi Login UI + autentikasi API

### Tujuan
Meninjau integrasi login dan sumber data nilai menggunakan endpoint API yang diberikan, sambil mempertahankan desain login yang disepakati. Endpoint ini adalah endpoint nilai dengan filter NPM, sehingga jangan menganggapnya sebagai endpoint autentikasi atau sumber profil mahasiswa sebelum struktur respons dan kontraknya diverifikasi.

### Endpoint nilai
`https://6adab9277512f497b30020ef.mockapi.io/nilai?npm=12523030`

Endpoint ini meminta data dari resource `nilai` dengan filter `npm=12523030`. Angka tersebut adalah contoh NPM pada URL yang diberikan; implementasi harus menggunakan NPM mahasiswa yang sedang login secara dinamis, bukan mengunci nilai `12523030` untuk semua pengguna. Verifikasi skema respons terlebih dahulu. Endpoint nilai tidak boleh otomatis dipakai untuk memvalidasi password atau mengambil profil mahasiswa jika kontrak API tidak menyediakannya.

### Langkah kerja
- [ ] Inventarisasi implementasi login, service/API, model user, penyimpanan sesi, dan halaman tujuan setelah login.
- [ ] Periksa respons endpoint terlebih dahulu. Catat apakah respons berupa array user dan field apa yang tersedia. Jangan mengasumsikan nama field sebelum respons diperiksa.
- [ ] Buat atau rapikan lapisan API terpisah dari widget UI, mengikuti struktur proyek yang sudah ada.
- [ ] Untuk mengambil nilai, kirim parameter query `npm` berdasarkan NPM mahasiswa yang sedang login. URL contoh menggunakan `npm=12523030`, tetapi aplikasi harus membentuk query secara dinamis dan aman untuk mahasiswa yang aktif. Endpoint `/nilai` tidak boleh dianggap sebagai endpoint login. Autentikasi harus menggunakan sumber/kontrak autentikasi yang benar-benar tersedia di proyek; jika belum ada, laporkan keterbatasannya dan jangan mengklaim login terintegrasi dengan endpoint nilai.
- [ ] Implementasikan validasi input kosong, status loading, penanganan timeout/koneksi, kredensial salah, dan pencegahan tombol login ditekan berulang kali.
- [ ] Pertahankan teks, komposisi, dan gaya visual layar login kecuali detail header blur/ikon dan bentuk field yang telah disepakati.
- [ ] Setelah login berhasil, teruskan identitas user yang benar ke halaman tujuan dan gunakan data API, bukan data mahasiswa acak.
- [ ] Jangan menampilkan password atau hash password ke UI maupun log.

### Catatan keamanan SHA-1
Permintaan menyebut password menggunakan SHA-1. SHA-1 bukan algoritma penyimpanan password yang aman, dan MockAPI adalah layanan mock, bukan sistem autentikasi produksi.

- Periksa bentuk data password pada API sebelum menentukan cara membandingkannya.
- Jika backend menyimpan nilai SHA-1, perlakukan dukungan itu sebagai **kompatibilitas sementara untuk beta**, bukan autentikasi aman.
- Jangan mengubah password mentah menjadi SHA-1 lalu mengirimkannya dengan asumsi aman tanpa memastikan kontrak API. Hash yang dikirim dapat berfungsi sebagai password yang dapat dipakai ulang.
- Untuk produksi, verifikasi password harus dilakukan di backend melalui HTTPS. Gunakan hashing khusus password seperti Argon2id, scrypt, atau bcrypt dengan salt; API tidak boleh mengirim hash password ke aplikasi.
- Jangan menaruh API secret, kredensial admin, atau private key di aplikasi Flutter.

### Kriteria selesai
- [ ] Pemanggilan API nilai menggunakan NPM mahasiswa yang login dan responsnya dipetakan berdasarkan skema yang telah diverifikasi.
- [ ] Login berhasil hanya untuk kredensial yang cocok.
- [ ] Error, loading, input kosong, dan kegagalan jaringan ditangani.
- [ ] Tidak ada perubahan visual yang tidak diminta pada halaman lain.
- [ ] Hasil pengujian dan keterbatasan keamanan SHA-1 dicatat.

## 4. Task 2 — Tambahkan submenu KRS di dalam Akademik

### Tujuan
Menyediakan submenu **KRS (Kartu Rencana Studi)** di dalam menu/halaman **Akademik** agar mahasiswa dapat melihat dan mengisi rencana mata kuliah. KRS tidak boleh ditambahkan sebagai menu utama terpisah.

### Langkah kerja
- [ ] Temukan menu/halaman **Akademik** yang sudah ada, pola submenu di dalamnya, dan mekanisme routing yang digunakan.
- [ ] Tambahkan item **KRS di dalam Akademik**, bukan sebagai item navigasi utama baru.
- [ ] Ikuti gaya ikon, warna, ukuran, label, jarak, dan interaksi submenu yang sudah ada.
- [ ] Buat halaman KRS mengikuti design system yang sudah ada; jangan mengubah layout global atau halaman lain.
- [ ] Tampilkan identitas/periode akademik hanya jika tersedia dari data atau konfigurasi yang benar.
- [ ] Sediakan alur daftar mata kuliah, detail relevan (kode, nama, SKS, jadwal jika tersedia), pemilihan mata kuliah, ringkasan jumlah SKS, dan tombol simpan/ajukan sesuai kemampuan backend.
- [ ] Validasi batas SKS, bentrok jadwal, duplikasi mata kuliah, prasyarat, dan periode pengisian hanya jika aturan/data resmi tersedia. Jika belum tersedia, tandai sebagai belum didukung—jangan membuat aturan akademik fiktif.
- [ ] Jika backend KRS belum tersedia, buat keadaan kosong atau prototipe yang diberi label jelas. Jangan mengklaim penyimpanan berhasil jika data tidak benar-benar tersimpan.
- [ ] Pastikan data KRS terikat pada mahasiswa yang sedang login, bukan data tetap atau acak.

### Kriteria selesai
- [ ] KRS dapat dibuka melalui **Akademik → KRS**.
- [ ] KRS tidak muncul sebagai menu utama terpisah.
- [ ] Mahasiswa dapat memilih mata kuliah hanya jika sumber data mendukungnya.
- [ ] Ringkasan SKS diperbarui dari pilihan aktual.
- [ ] Simpan/ajukan memberi hasil nyata dari backend; jika belum didukung, UI menyatakan status dengan jujur.
- [ ] UI konsisten dengan desain yang sudah ada.

## 5. Task 3 — Tambahkan submenu KTM di dalam Akademik dan unduh kartu mahasiswa

### Tujuan
Menyediakan submenu **KTM (Kartu Tanda Mahasiswa)** di dalam menu/halaman **Akademik** untuk menampilkan KTM mahasiswa yang sedang login dan mengunduhnya. KTM tidak boleh ditambahkan sebagai menu utama terpisah.

### Langkah kerja
- [ ] Temukan menu/halaman **Akademik** yang sudah ada dan tambahkan item **KTM di dalam Akademik**, bukan sebagai item navigasi utama baru.
- [ ] Ikuti pola submenu, navigasi, ikon, dan gaya visual yang sudah ada.
- [ ] Ambil data profil mahasiswa dari sesi/API yang sama dengan login; jangan menggunakan identitas mahasiswa hard-coded.
- [ ] Tentukan field yang tersedia untuk nama, NPM, program studi, foto, dan informasi kartu lain. Tampilkan hanya data yang memang tersedia dan sah digunakan.
- [ ] Susun pratinjau KTM mengikuti identitas visual Boash dan format yang terbaca di layar ponsel.
- [ ] Implementasikan unduh/ekspor KTM ke format yang didukung proyek (utamakan PDF jika dependency dan kebutuhan platform mendukung).
- [ ] Tangani izin penyimpanan, kegagalan pembuatan file, data yang belum lengkap, dan status loading.
- [ ] Jangan membuat atau menampilkan KTM yang tampak resmi jika data mahasiswa belum terverifikasi. Untuk data demo, beri penanda **DEMO**.
- [ ] Jangan mengubah desain dashboard atau halaman lain selain penambahan menu dan halaman KTM.

### Kriteria selesai
- [ ] KTM dapat dibuka melalui **Akademik → KTM**.
- [ ] KTM tidak muncul sebagai menu utama terpisah.
- [ ] Halaman KTM menampilkan kartu milik mahasiswa yang sedang login.
- [ ] Informasi kartu berasal dari API/profil yang terverifikasi.
- [ ] Tombol unduh menghasilkan file yang benar-benar dapat dibuka, bukan sekadar snackbar sukses.
- [ ] Kegagalan ekspor dan data yang tidak lengkap ditangani dengan jelas.
- [ ] Gaya visual mengikuti design system yang ada.

## 6. Urutan implementasi yang wajib diikuti

1. **Baseline dan audit:** pastikan branch, status Git, struktur folder, rute, dan halaman saat ini; jalankan `flutter analyze` dan tes yang tersedia. Simpan screenshot baseline bila memungkinkan.
2. **Verifikasi kontrak API:** panggil endpoint, lihat contoh respons, identifikasi field NPM/ID/password/profil. Jangan lanjut dengan asumsi skema.
3. **Task 1 — Login/API:** implementasikan service dan pemetaan data terlebih dahulu, lalu sambungkan ke UI tanpa redesign.
4. **Validasi Task 1:** uji login benar/salah, input kosong, koneksi gagal, dan respons API yang tidak sesuai.
5. **Task 2 — KRS:** tambahkan submenu KRS di dalam Akademik dan implementasikan fungsi sesuai ketersediaan backend.
6. **Validasi Task 2:** uji pemilihan, hitung SKS, kondisi kosong, dan penyimpanan jika tersedia.
7. **Task 3 — KTM:** tambahkan submenu KTM di dalam Akademik, lalu buat pratinjau kartu dan proses ekspor.
8. **Validasi Task 3:** pastikan file unduhan valid dan data berasal dari mahasiswa yang login.
9. **Regression check:** bandingkan screenshot dengan baseline; pastikan layar/menu lain tidak berubah. Jalankan `flutter analyze` dan `flutter test`.
10. **Dokumentasi hasil:** catat file yang diubah, endpoint/field yang dipakai, test yang dijalankan, keterbatasan backend, dan pekerjaan lanjutan.

## 7. Pengujian regresi dan penerimaan

- [ ] Aplikasi dapat dibangun dan dibuka pada perangkat Android target.
- [ ] Tidak ada error analisis Flutter baru.
- [ ] Login memetakan NPM ke record yang benar.
- [ ] Tidak ada password/hash yang dicetak ke log.
- [ ] Navigasi **Akademik → KRS** dan **Akademik → KTM** berfungsi.
- [ ] KRS dan KTM tidak ditambahkan sebagai menu utama terpisah.
- [ ] Tidak ada perubahan layout atau tema di luar scope yang disetujui.
- [ ] Semua status loading, kosong, sukses, dan gagal ditangani.
- [ ] Fitur yang membutuhkan backend yang belum tersedia diberi status eksplisit, bukan simulasi sukses.

## 8. Catatan implementasi

- Endpoint MockAPI `/nilai?npm=...` di atas harus dianggap sebagai sumber data nilai untuk beta sampai backend resmi tersedia. Endpoint ini bukan otomatis endpoint autentikasi.
- Jangan mengasumsikan endpoint nilai ini menyediakan autentikasi, password, profil lengkap mahasiswa, data mata kuliah, jadwal, aturan SKS, atau file KTM; verifikasi respons dan kontraknya terlebih dahulu.
- Gunakan HTTPS, timeout, parsing JSON defensif, dan pesan error yang aman untuk pengguna.
- Lakukan perubahan bertahap dan terisolasi. Hindari refactor besar, perubahan dependency, penggantian navigasi, atau redesign di luar kebutuhan tiga task.
