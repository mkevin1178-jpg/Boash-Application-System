# REVISI.md --- Daftar Penambahan Fitur, Optimasi, dan Perbaikan UI/UX

> **Status implementasi:** `[x]` = sudah selesai di aplikasi saat ini,
> `[ ]` = belum dikerjakan (P2 di luar ruang lingkup PBL tahap ini).
> Verifikasi terakhir: `flutter analyze` 0 isu · `flutter test` 20 uji lulus.
> Rincian dokumentasi ada di `README.md`, `design.md`, `WORKFLOW.md`, dan
> `docs/IMPLEMENTATION_PLAN.md`.

## 1. Konteks proyek

Boash Student App merupakan aplikasi beta untuk proyek PBL sistem
kampus. Tujuannya adalah membangun prototipe pengalaman mahasiswa yang
rapi dan mudah digunakan. **Data mahasiswa asli tidak diperlukan**; API
acak tetap dapat dipakai untuk kebutuhan simulasi login/profil.
Rekomendasi berikut memprioritaskan kualitas alur, konsistensi UI, dan
fitur yang realistis untuk prototipe.

## 2. Prioritas revisi

-   **P0 --- Wajib:** fondasi UX, navigasi utama, state
    loading/error/empty, dan alur demo yang dapat diuji.
-   **P1 --- Penting:** fitur akademik utama dan konsistensi komponen.
-   **P2 --- Pengembangan lanjutan:** polish visual, aksesibilitas, dan
    peningkatan kenyamanan.

## 3. Penambahan fitur

### P0 --- Fitur inti

-   [x] **Dashboard akademik:** sapaan pengguna, jadwal hari ini, tugas
    terdekat, dan pengumuman terbaru.
-   [x] **Jadwal kuliah:** tampilan harian/mingguan dengan jam, mata
    kuliah, ruang, dan dosen contoh.
-   [x] **Menu Akademik:** satu pintu untuk Materi, Tugas, Nilai,
    Presensi, dan KTM.
-   [x] **Pengumuman kampus:** daftar pengumuman dengan kategori dan
    tanggal.
-   [x] **Status UI:** loading, error, empty state, dan retry pada layar
    yang mengambil data.
-   [x] **Feedback aksi:** snackbar/toast untuk aksi berhasil atau
    gagal, bukan snackbar generik tanpa perubahan state.
-   [x] **Logout demo:** konfirmasi keluar dan penghapusan sesi lokal.

### P1 --- Fitur akademik

-   [x] **Materi perkuliahan:** daftar materi berdasarkan mata kuliah
    dan aksi membuka/unduh simulasi.
-   [x] **Daftar tugas:** status Belum Dikerjakan, Dikerjakan, dan
    Dikumpulkan.
-   [x] **Detail tugas:** deskripsi, tenggat, lampiran contoh, dan
    tombol pengumpulan simulasi.
-   [x] **Nilai:** daftar nilai demo per mata kuliah dan ringkasan
    semester.
-   [x] **Presensi:** ringkasan kehadiran demo per mata kuliah.
-   [x] **KTM digital demo:** identitas contoh dan QR/barcode hanya
    sebagai ilustrasi, kecuali benar-benar ada mekanisme verifikasi.
-   [x] **Pencarian/filter:** pencarian materi, tugas, dan pengumuman
    bila jumlah konten sudah cukup banyak.

> Catatan: pencarian **Pengumuman** (teks + kategori), filter **Tugas**
> (status dengan jumlah), dan filter **Materi** (mata kuliah) sudah
> tersedia. Pencarian teks pada halaman Materi belum ada.

### P2 --- Peningkatan pengalaman

-   [ ] **Notifikasi lokal/demo:** pengingat tugas dan jadwal, bila
    cakupan PBL memungkinkan.
-   [ ] **Kalender akademik:** agenda, tenggat, dan jadwal dalam satu
    tampilan.
-   [ ] **Mode gelap:** jika tidak mengganggu ruang lingkup PBL.
-   [ ] **Preferensi profil:** pengaturan sederhana dan pilihan
    tampilan.
-   [ ] **Bookmark materi/pengumuman:** simpan item favorit secara
    lokal.

> Tahap ini ditandai **di luar ruang lingkup PBL saat ini**; seluruh item
> P0 dan P1 sudah selesai.

## 4. Optimasi aplikasi

### Struktur kode dan state

-   [x] Pisahkan UI, model, service/API, dan state management agar
    tanggung jawab tiap file jelas.
-   [x] Pindahkan data contoh dan mock response ke repository/service,
    bukan ditulis langsung di widget.
-   [x] Gunakan satu pola state yang konsisten, misalnya `loading`,
    `success`, `empty`, dan `error`.
-   [x] Jadikan komponen berulang reusable: tombol, input, kartu jadwal,
    badge status, item pengumuman, dan empty state.
-   [x] Hindari callback no-op; tombol yang belum tersedia harus
    dinonaktifkan atau diberi keterangan **Segera hadir/Demo**.
-   [x] Hindari request berulang yang tidak diperlukan; cache data demo
    sederhana jika bermanfaat.

### Performa

-   [x] Gunakan `const` pada widget statis jika memungkinkan.
-   [x] Gunakan `ListView.builder`/grid builder untuk daftar yang
    panjang.
-   [x] Optimalkan ukuran aset gambar dan sediakan fallback saat gambar
    gagal dimuat.
-   [x] Hindari rebuild seluruh halaman ketika hanya satu bagian yang
    berubah.
-   [x] Tampilkan indikator loading yang ringan dan cegah tombol submit
    dipencet berkali-kali selama request.

> Catatan: daftar pada aplikasi ini berisi data demo berbatas kecil
> (maks. ±8 item) dan memakai `ListView` biasa; `ListView.separated`
> dipakai pada jadwal mingguan. Builder akan lebih penting bila data
> dinormalkan dari server.

### API dan simulasi login

-   [x] API acak boleh dipertahankan untuk PBL; dokumentasikan bahwa
    data dan autentikasi bersifat demo.
-   [x] Pisahkan pemanggilan API ke kelas service, tangani timeout,
    status HTTP, dan respons yang tidak sesuai.
-   [x] Jangan menaruh kredensial sensitif di source code atau
    menampilkan password di UI.
-   [x] Validasi input di sisi aplikasi untuk pengalaman pengguna;
    jangan menganggap validasi UI sebagai keamanan produksi.
-   [x] Bila API acak tidak menyediakan autentikasi username/password
    sesungguhnya, gunakan alur mock login yang eksplisit dan konsisten,
    bukan mengklaimnya sebagai autentikasi resmi.
-   [x] Jangan mengirim data pribadi nyata ke API acak.

### Kualitas dan pengujian

-   [x] Jalankan `flutter analyze` dan perbaiki warning/error yang
    relevan.
-   [x] Uji login berhasil/gagal, API offline, data kosong, dan logout.
-   [x] Uji layout pada beberapa ukuran layar dan orientasi yang
    didukung.
-   [x] Pastikan tombol, back navigation, dan bottom navigation bekerja
    sesuai label.
-   [x] Buat data demo yang konsisten antarlayar agar nama mata kuliah,
    jadwal, dan tugas tidak saling bertentangan.

> Catatan: pengujian otomatis (`test/`) memakai ukuran layar standar
> widget test; pemeriksaan beberapa ukuran layar dilakukan manual
> (overflow pada pemilih hari di Jadwal sudah diperbaiki).

## 5. Perbaikan UI/UX

### Visual design system

-   [x] Pertahankan identitas biru sebagai warna utama; gunakan warna
    sekunder hanya untuk membedakan kategori/status.
-   [x] Gunakan latar belakang netral terang dan surface putih untuk
    membedakan kartu dari halaman.
-   [x] Tetapkan skala spacing konsisten, misalnya kelipatan 4 atau 8.
-   [x] Samakan radius kartu, tombol, field, dan modal.
-   [x] Gunakan hierarki tipografi yang jelas: judul halaman, judul
    bagian, teks utama, metadata.
-   [x] Gunakan satu gaya ikon yang konsisten dan hindari ikon dekoratif
    yang tidak membantu pemahaman.
-   [x] Gunakan gradient seperlunya untuk area hero atau highlight,
    bukan pada semua kartu.
-   [x] Pastikan kontras teks dan ukuran tap target memadai.

### Navigasi dan hierarki informasi

-   [x] Gunakan lima tab utama: **Beranda, Jadwal, Akademik, Pengumuman,
    Profil**.
-   [x] Hindari menu yang tumpang tindih seperti Info dan News tanpa
    pembeda fungsi yang jelas.
-   [x] Letakkan jadwal, tugas mendekati tenggat, dan pengumuman penting
    di area atas dashboard.
-   [x] Jangan menampilkan terlalu banyak kartu atau banner sebelum
    informasi utama.
-   [x] Gunakan judul, label, tanggal, status, dan aksi yang konsisten
    di setiap halaman.

### Perbaikan per layar

  -----------------------------------------------------------------------
  Layar                               Revisi yang disarankan
  ----------------------------------- -----------------------------------
  Splash                              Logo dan nama aplikasi jelas,
                                      durasi singkat, transisi sederhana

  Login                               Label input jelas, tombol
                                      tampil/sembunyikan password,
                                      validasi inline, loading, error,
                                      petunjuk login demo

  Dashboard                           Ganti fokus katalog kursus generik
                                      menjadi ringkasan aktivitas kampus

  Jadwal                              Penanda hari aktif, kartu jadwal
                                      yang mudah dipindai, status
                                      kehadiran opsional

  Akademik                            Kartu menu seragam, ikon dan
                                      deskripsi singkat, kelompokkan
                                      fitur terkait

  Detail tugas                        Deadline, status, file pendukung,
                                      dan tombol aksi terlihat jelas

  Pengumuman                          Kategori, tanggal, indikator baru,
                                      dan halaman detail

  KTM                                 Data contoh konsisten, tombol
                                      simpan/bagikan berfungsi atau
                                      diberi label demo; barcode
                                      dekoratif tidak diklaim sebagai
                                      verifikasi

  Profil                              Avatar fallback, informasi demo,
                                      pengaturan, bantuan, dan logout
                                      yang jelas
  -----------------------------------------------------------------------

### Micro-interaction dan aksesibilitas

-   [x] Tambahkan feedback visual saat tombol ditekan dan saat aksi
    selesai.
-   [x] Gunakan badge status yang tidak hanya mengandalkan warna;
    sertakan teks status.
-   [x] Pastikan ukuran teks tetap terbaca dan layout tidak overflow.
-   [x] Sediakan label semantik yang jelas pada tombol dan ikon
    interaktif.
-   [ ] Gunakan animasi pendek dan fungsional, bukan animasi yang
    memperlambat tugas utama.

> Catatan: item animasi sengaja ditunda agar prototipe tetap ringan dan
> tidak mengganggu alur demo.

## 6. Rekomendasi urutan pengerjaan

1.  **Rapikan fondasi:** selesaikan konflik pada README, jalankan
    analisis Flutter, dan pastikan struktur project dapat dibangun.
2.  **Kunci design system:** warna, tipografi, spacing, radius, tombol,
    field, kartu, dan navigasi.
3.  **Redesign dashboard dan bottom navigation:** utamakan informasi
    akademik.
4.  **Selesaikan alur utama:** login demo → dashboard →
    jadwal/akademik/pengumuman → profil → logout.
5.  **Bangun state UI:** loading, error, empty, success untuk tiap alur
    data.
6.  **Tambahkan fitur P1:** materi, tugas, nilai, presensi, KTM demo.
7.  **QA dan polish:** responsif, aksesibilitas, analisis kode, dan
    pengujian skenario.

## 7. Kriteria selesai (Definition of Done)

-   [x] Tidak ada error analisis/build yang menghalangi aplikasi
    dijalankan.
-   [x] Semua tab utama membuka halaman yang benar.
-   [x] Tidak ada tombol penting yang diam tanpa feedback.
-   [x] Setiap layar data punya loading, error, dan empty state yang
    relevan.
-   [x] Data demo konsisten dan tidak disalahartikan sebagai data
    mahasiswa asli.
-   [x] UI terbaca pada beberapa ukuran layar.
-   [x] Login dan logout demo dapat diuji dari awal sampai akhir.
-   [x] README tidak mengandung merge-conflict markers.

## 8. Catatan ruang lingkup

Daftar ini adalah rekomendasi untuk **aplikasi beta PBL**, bukan
tuntutan membangun sistem akademik produksi penuh. API acak tetap dapat
digunakan untuk simulasi login/profil. Integrasi SIAKAD, autentikasi
kampus, penyimpanan nilai resmi, presensi resmi, dan verifikasi KTM
tidak termasuk kewajiban kecuali secara khusus ditambahkan ke ruang
lingkup proyek.
