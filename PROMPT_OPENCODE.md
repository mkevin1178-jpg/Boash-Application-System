# PROMPT OPENCODE — Sinkronisasi Boash Application System (BAS) dengan 3 MockAPI

Kamu adalah engineer Flutter senior. Kerjakan perbaikan di repo ini (Flutter, package `bas`) supaya aplikasi benar-benar memakai 3 endpoint MockAPI sebagai backend. Baca dulu seluruh instruksi, lalu kerjakan bertahap sesuai urutan, dan jalankan `flutter analyze` serta `flutter test` setelah setiap tahap.

## 1. Kontrak API (sudah diverifikasi dari respons asli)

| Resource | URL | Catatan |
|---|---|---|
| Nilai | `https://6adab9277512f497b30020ef.mockapi.io/nilai?npm=<NPM>` | Host A |
| KRS | `https://6aed363dfc3b911e6fd60ab2.mockapi.io/krs` | Host B |
| Mahasiswa | `https://6aed363dfc3b911e6fd60ab2.mockapi.io/mahasiswa` | Host B |

Contoh NPM uji: `12523030`.

**Field `/mahasiswa`** (semua string kecuali disebut lain): `npm`, `nama` (ada spasi di akhir, wajib di-trim), `tempat_lahir`, `tgl_lahir`, `agama`, `kelamin`, `alamat`, `handphone`, `email`, `kd_progstudi`, `kd_jenjang`, `kd_kelas`, `tahun_masuk` (contoh `2023/2024`), `foto` (nama file, contoh `aa_sof.png`, bukan URL penuh), `status`. Banyak field berisi string kosong atau `null`. Tidak ada field password.

**Field `/krs`**: `id`, `npm`, `kd_matkul`, `kd_kelas`, `thn_akademik`, `semester` (string, contoh `"1"` dan `"5"`), `thn_akademik_now`, `semester_now` (`ganjil`/`genap`), `status` (angka 0/1), `group_id_nonreg`, `tahun`, `tri_semester`.

**Field `/nilai`**: sudah dipakai di `features/nilai/data/models/nilai_model.dart`. Jangan diubah kecuali perlu.

**Sifat data yang wajib ditangani:**
- `/krs` dan `/mahasiswa` mengembalikan SEMUA record bila tanpa query. Selalu kirim `?npm=` DAN filter ulang di client (`npm` harus sama persis setelah trim).
- `id` di `/krs` campur tipe: ada int (`119308`), ada string (`"119317"`). Parse aman.
- `tahun` dan `tri_semester` berisi sampah (`"tahun 119327"`) atau `null`. Abaikan kedua field ini, jangan ditampilkan.
- Ada record duplikat di `/krs` (mis. GC327 semester 1 tampil 3 kali; semester 5 ada dua set, IF503 muncul kelas A dan B). Dedupe berdasarkan `(kd_matkul, thn_akademik, semester)`. Bila ada konflik, pertahankan record dengan `id` numerik terkecil, kecuali record `status == 1` (utamakan itu).
- `status` di `/krs` bernilai 0/1 tapi artinya BELUM DIKONFIRMASI. Simpan sebagai `int statusRaw`. Jangan beri label "Disetujui"/"Ditolak"/"Aktif" sampai ada konfirmasi. Tampilkan netral, mis. `Status: 1`, dan beri komentar `// TODO: arti status belum dikonfirmasi`.
- Kode matkul di API: `GC302`, `GC311`, `GC319`, `GC327`, `IF501`–`IF507`.
- `/nilai` hanya punya data untuk sebagian matkul (mis. GC311 dan GC319 belum ada nilainya). Itu normal: tampilkan "Belum ada nilai", bukan error.

## 2. Temuan masalah yang harus diperbaiki

1. `lib/core/config/api_config.dart` hanya punya satu `baseUrl` (Host A). Host B belum ada.
2. `/krs` belum diintegrasikan. `lib/features/academic/krs_screen.dart` memakai `DemoData.courses` (kode `MK-01`…`MK-08`), dan tombol "Ajukan KRS" hanya menampilkan snackbar sukses palsu tanpa mengirim data.
3. `/mahasiswa` belum diintegrasikan. `lib/state/app_session.dart` (`AppSession.fromNpm`) mengisi nama "Kevin Pratama", prodi "Multimedia", dan data lain secara hardcode.
4. `lib/state/app_controller.dart` login hanya validasi lokal (NPM ≥5 digit, password ≥4 karakter), tidak mengecek NPM ke `/mahasiswa`. `lib/services/auth_api.dart` (randomuser.me) tidak relevan.
5. `lib/shared/matkul_reference.dart` tidak memuat `GC311`, `GC319`, `IF501`–`IF507`, sehingga nama dan SKS kosong dan IPS salah.
6. Ada dua jalur pengambilan nilai paralel: `lib/services/nilai_api.dart` (dipakai `lib/data/demo_repository.dart`) dan `lib/features/nilai/...`.
7. `DemoRepository.fetchApiGrades` dan `fetchDhsGrades` diam-diam fallback ke `DemoData` saat jaringan gagal. Ini menampilkan nilai palsu seolah asli.

## 3. Tugas (kerjakan berurutan)

### Tahap 1 — Konfigurasi
- Di `ApiConfig`: pisahkan `nilaiBaseUrl` (Host A) dan `akademikBaseUrl` (Host B). Tambah `krsPath = '/krs'`, `mahasiswaPath = '/mahasiswa'`, dan builder `krsUri(npm)`, `mahasiswaUri(npm)` dengan `queryParameters: {'npm': npm.trim()}`. Pertahankan `nilaiUri` dan `timeout`.
- Jangan menulis URL di file lain.

### Tahap 2 — Mahasiswa + login
- Buat `lib/features/mahasiswa/data/{models,datasources,repositories}/` dengan pola yang sama seperti `features/nilai` (gunakan `AppHttpClient` dan `Failure` yang sudah ada).
- Model `Mahasiswa` parse aman (null, kosong, spasi → string kosong), `nama` di-trim.
- Ubah `AppSession`: tambah `factory AppSession.fromMahasiswa(Mahasiswa m)` yang memakai nama, email, `kd_progstudi`, `tahun_masuk`, dan `foto` dari API. Field yang memang tidak tersedia di API (fakultas, validUntil, dll.) boleh tetap demo tetapi harus diberi label demo yang jelas, dan hapus nama "Kevin Pratama" serta data pribadi hardcode.
- Ubah `AppController.login`: setelah validasi format, panggil `/mahasiswa?npm=` lalu filter client-side. Jika kosong, kembalikan `LoginFailure('NPM tidak terdaftar.')`. Jika jaringan gagal, kembalikan `LoginFailure` dengan pesan jaringan (jangan login diam-diam). Password: API tidak punya field password, jadi password tetap validasi demo dan WAJIB diberi komentar serta label UI bahwa password belum terhubung ke backend. Jangan mengklaim autentikasi terintegrasi.
- Hapus `auth_api.dart` dan referensinya bila tidak dipakai (cek dengan grep dulu).

### Tahap 3 — KRS
- Buat `lib/features/krs/data/{models,datasources,repositories}/` + controller/presentation sesuai pola `features/nilai`.
- Model `KrsItem`: `id` (parse aman int/string), `npm`, `kdMatkul`, `kdKelas`, `thnAkademik`, `semester` (int), `semesterNow`, `statusRaw`. Abaikan `tahun` dan `tri_semester`.
- Repository: fetch dengan `?npm=`, filter client-side, dedupe sesuai aturan di bagian 1, urutkan per `thn_akademik` lalu `semester` lalu `kd_matkul`.
- Ubah `krs_screen.dart`: tampilkan KRS dari API, dikelompokkan per tahun akademik + semester, nama matkul dan SKS dari `MatkulReference`, total SKS per semester. Pertahankan state loading/empty/error/retry (`AsyncBuilder`).
- Tombol "Ajukan KRS": jangan tampilkan sukses palsu. Pilih salah satu: (a) `POST` ke `/krs` dengan body field API yang valid dan tampilkan sukses HANYA bila respons 2xx; atau (b) bila belum diimplementasi POST, nonaktifkan tombol dan beri teks jujur "Pengajuan KRS belum terhubung ke server". Pilih (a) bila memungkinkan dan jelaskan keputusannya di laporan akhir.

### Tahap 4 — Referensi matkul
- Lengkapi `MatkulReference.table` dengan `GC311`, `GC319`, `IF501`–`IF507`. Nama dan SKS DIISI OLEH PENGGUNA di tabel berikut. JANGAN mengarang nama atau SKS. Jika kolom masih `ISI`, biarkan entri itu tidak ada di tabel (kode tampil apa adanya, dikeluarkan dari hitungan IPS dengan penanda peringatan, sesuai perilaku yang sudah ada) dan laporkan daftar kode yang belum terisi di akhir.

| Kode | Nama | SKS |
|---|---|---|
| GC311 | ISI | ISI |
| GC319 | ISI | ISI |
| IF501 | ISI | ISI |
| IF502 | ISI | ISI |
| IF503 | ISI | ISI |
| IF504 | ISI | ISI |
| IF505 | ISI | ISI |
| IF506 | ISI | ISI |
| IF507 | ISI | ISI |

### Tahap 5 — Rapikan jalur nilai
- Jadikan `features/nilai` satu-satunya jalur pengambilan nilai. Migrasikan pemakai `NilaiApi`/`DemoRepository.fetchApiGrades`/`fetchDhsGrades` (grades_screen, dhs_screen, dashboard bila ada) ke repository `features/nilai`, lalu hapus `lib/services/nilai_api.dart` bila sudah tidak dipakai.
- Hapus fallback diam-diam ke `DemoData.grades`/`DemoData.dhsGrades`. Saat gagal, kembalikan error ke UI (state error + tombol coba lagi). Saat NPM kosong di API, tampilkan state empty yang jujur.
- Matkul yang ada di KRS tapi belum punya nilai tampil sebagai "Belum ada nilai".

### Tahap 6 — Pengujian
- Tambah unit test: parsing `Mahasiswa` (nama bertrailing spasi, field null), parsing `KrsItem` (id int dan string, field sampah), dedupe KRS (pakai contoh duplikat GC327 semester 1 dan IF503 A/B semester 5), filter client-side per NPM, dan login gagal untuk NPM tidak terdaftar. Gunakan HTTP client palsu/mock, jangan memanggil jaringan sungguhan di test.
- Perbarui test yang rusak. Jangan menghapus test hanya agar lulus.

## 4. Aturan

- Jangan memakai endpoint `/nilai`, `/krs`, atau `/mahasiswa` sebagai bukti autentikasi password. Jujur soal keterbatasan.
- Jangan menaruh URL, token, atau kredensial di luar `ApiConfig`.
- Jangan mengubah desain/UI di luar layar yang disebut kecuali perlu untuk state loading/empty/error.
- Jangan menampilkan data demo sebagai data asli. Semua teks yang bersifat simulasi harus berlabel demo.
- Jangan mengarang arti `status` KRS, nama matkul, atau SKS.
- Pertahankan gaya kode, penamaan, dan komentar bahasa Indonesia yang sudah ada di repo.
- Jangan commit atau push kecuali diminta.

## 5. Kriteria selesai

- [ ] `flutter analyze` bersih (tanpa error baru).
- [ ] `flutter test` lulus.
- [ ] Login NPM `12523030` memuat profil dari `/mahasiswa` (nama "Sofi Arianti", tanpa spasi trailing). NPM acak (mis. `99999`) ditolak dengan pesan "NPM tidak terdaftar".
- [ ] Layar KRS menampilkan data `/krs` untuk NPM aktif, tanpa duplikat, dikelompokkan per semester.
- [ ] Layar nilai memakai satu jalur data, tanpa fallback ke data demo.
- [ ] Tidak ada lagi `MK-01`…`MK-08` dan "Kevin Pratama" yang tampil sebagai data asli.
- [ ] Tombol Ajukan KRS tidak lagi menampilkan sukses palsu.

## 6. Laporan akhir (wajib)

Tulis ringkas: file yang diubah/dibuat/dihapus, keputusan untuk tombol Ajukan KRS, daftar kode matkul yang SKS/namanya masih kosong, hasil `flutter analyze` dan `flutter test`, serta keterbatasan yang tersisa (password belum terhubung ke backend, arti `status` KRS belum dikonfirmasi).