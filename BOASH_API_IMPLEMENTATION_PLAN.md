# Rancangan Implementasi API Nilai — Boash Application System

## 1. Tujuan

Mengintegrasikan API nilai mahasiswa (MockAPI) ke aplikasi mobile **Boash Application System** agar pengguna dapat melihat nilai per mata kuliah, rincian komponen nilai, dan ringkasan akademik (IPS/IPK) berdasarkan NPM.

## 2. Sumber Data

**Base URL**
```
https://6adab9277512f497b30020ef.mockapi.io
```

**Endpoint**

| Method | Path | Query | Keterangan |
|---|---|---|---|
| GET | `/nilai` | `npm=<NPM>` | Daftar nilai milik satu NPM |

**Contoh request**
```
GET https://6adab9277512f497b30020ef.mockapi.io/nilai?npm=12523030
```

**Contoh response (ringkas)**
```json
[
  {
    "id": 162801,
    "kd_matkul": "GC327",
    "npm": "12523030",
    "uas": "70", "uts": "75", "quis": "72", "tugas": "80", "hadir": "100",
    "na_uas": "17.5", "na_uts": "15", "na_quis": "10.8", "na_tugas": "16", "na_hadir": "20",
    "hm": "B+", "na": "79.3", "am": "3.5", "mutu": "10.5",
    "thn_akademik": "2023/2024", "semester": "1"
  }
]
```

**Catatan penting data**
- Semua angka dikirim sebagai **string** → wajib di-parse ke tipe numerik.
- Field `seminar`, `bimbingan`, `makalah`, `lisan` bernilai `"0"` bila tidak dipakai matkul tersebut.
- `tahun`, `tri_semester`, `bmanual` bisa kosong/null → harus nullable.
- Response **tidak** memuat nama matkul maupun SKS → perlu tabel referensi lokal (lihat bagian 5).
- Endpoint tanpa autentikasi (hanya cocok untuk prototipe/demo).

## 3. Arsitektur

Pakai pola berlapis supaya mudah diganti ketika backend asli sudah tersedia.

```
UI (Screen/Widget)
   ↓
State Management (ViewModel / Provider / Bloc / Zustand sesuai stack)
   ↓
Repository  ← satu-satunya pintu data bagi UI
   ↓
Remote Data Source (HTTP client → MockAPI)
   ↓
Model (parsing JSON → objek bertipe)
```

Struktur folder yang disarankan:
```
lib/ (atau src/)
├── core/
│   ├── config/api_config.dart        # base URL, timeout
│   ├── network/http_client.dart
│   └── error/failure.dart
├── features/nilai/
│   ├── data/
│   │   ├── models/nilai_model.dart
│   │   ├── datasources/nilai_remote_ds.dart
│   │   └── repositories/nilai_repository.dart
│   ├── domain/
│   │   └── ips_calculator.dart
│   └── presentation/
│       ├── nilai_list_screen.dart
│       ├── nilai_detail_screen.dart
│       └── widgets/
└── shared/matkul_reference.dart       # kode matkul → nama + SKS
```

## 4. Model Data

`Nilai` (hasil parsing satu record):

| Field | Tipe | Catatan |
|---|---|---|
| id | int | |
| kdMatkul | String | dari `kd_matkul` |
| npm | String | |
| uas, uts, quis, tugas, hadir | double | parse dari string |
| naUas, naUts, naQuis, naTugas, naHadir | double | nilai berbobot per komponen |
| hm | String | huruf mutu (A, B+, B, ...) |
| na | double | nilai akhir |
| am | double | angka mutu (4.0 skala) |
| mutu | double | |
| thnAkademik | String | contoh `2023/2024` |
| semester | int | |

Aturan parsing: gunakan helper `toDouble(String?)` yang mengembalikan `0.0` bila kosong/null/tidak valid, agar aplikasi tidak crash karena data kotor.

## 5. Data Pendukung Lokal

Karena API tidak menyediakan nama matkul dan SKS, buat tabel referensi lokal (konstanta atau file JSON asset):

| kd_matkul | Nama Matkul | SKS |
|---|---|---|
| GC327 | (isi sesuai kurikulum) | (isi) |
| GC302 | (isi sesuai kurikulum) | (isi) |

Rumus:
- **IPS** = Σ(`am` × SKS) / Σ(SKS) untuk satu semester
- **IPK** = Σ(`am` × SKS) / Σ(SKS) untuk semua semester

Bila kode matkul tidak ditemukan di tabel referensi, tampilkan kode matkul apa adanya dan keluarkan dari perhitungan IPS dengan penanda peringatan.

## 6. Fitur & Alur Layar

1. **Input/Identitas NPM** — NPM diambil dari sesi login, atau input manual pada tahap awal. Validasi: wajib diisi, hanya angka.
2. **Daftar Nilai** — dikelompokkan per `thn_akademik` + `semester`. Tiap item: nama matkul, kode, huruf mutu, nilai akhir.
3. **Ringkasan Semester** — kartu berisi IPS, total SKS, jumlah matkul.
4. **Detail Nilai** — rincian UTS, UAS, Quis, Tugas, Kehadiran beserta nilai berbobotnya.
5. **Pull-to-refresh** untuk memuat ulang data.

## 7. Penanganan State & Error

State yang harus ada: `loading`, `success`, `empty`, `error`.

| Kondisi | Perilaku UI |
|---|---|
| Sedang memuat | Skeleton/spinner |
| Response `[]` | Pesan "Belum ada data nilai untuk NPM ini" |
| Tidak ada internet | Pesan + tombol coba lagi |
| Timeout (set 15 detik) | Pesan + tombol coba lagi |
| HTTP 4xx/5xx | Pesan umum, detail teknis hanya di log |
| JSON tidak valid | Pesan umum, catat ke log |

Opsional: cache hasil terakhir secara lokal agar nilai tetap bisa dilihat saat offline.

## 8. Keamanan & Batasan

- MockAPI **bukan** layanan produksi: ada batas request, data bisa hilang, tanpa autentikasi.
- Endpoint publik berbasis query `npm` → siapa pun dapat membaca nilai NPM lain. Jangan dipakai untuk data akademik nyata.
- Simpan base URL di satu file konfigurasi agar mudah diganti.
- Jangan menaruh token/kredensial di source code saat nanti pindah ke backend asli.
- Rencana migrasi: ganti Remote Data Source saja, UI dan Repository tidak berubah.

## 9. Tahapan Pengerjaan

| Tahap | Pekerjaan | Hasil |
|---|---|---|
| 1 | Setup HTTP client + konfigurasi base URL | Request GET berhasil di log |
| 2 | Buat model `Nilai` + parsing aman | Unit test parsing lulus |
| 3 | Buat Remote Data Source + Repository | Data tampil di console |
| 4 | Tabel referensi matkul + kalkulator IPS | Unit test IPS lulus |
| 5 | Layar daftar nilai + ringkasan semester | UI dasar jalan |
| 6 | Layar detail + state error/empty/loading | Semua state tertangani |
| 7 | Pengujian & perapihan | Checklist bagian 10 terpenuhi |

## 10. Checklist Pengujian

- [ ] Parsing berhasil untuk data normal (NPM 12523030)
- [ ] Parsing tidak crash untuk field kosong/null
- [ ] NPM tanpa data menampilkan state kosong
- [ ] Mode pesawat menampilkan state error + coba lagi
- [ ] IPS terhitung benar (cocok dengan hitungan manual)
- [ ] Pengelompokan per semester benar
- [ ] Pull-to-refresh bekerja
- [ ] Tampilan aman di layar kecil dan besar

## 11. Pengembangan Lanjutan

- Login + backend asli dengan autentikasi per mahasiswa
- Grafik tren IPS per semester
- Ekspor transkrip ke PDF
- Notifikasi saat nilai baru masuk
