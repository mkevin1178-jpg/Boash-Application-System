/// Informasi lokal mata kuliah yang tidak disediakan API.
class MatkulInfo {
  const MatkulInfo({required this.kode, required this.nama, required this.sks});

  final String kode;
  final String nama;
  final int sks;
}

/// Tabel referensi kode mata kuliah → nama + SKS.
///
/// API `/nilai` tidak mengirim nama matkul maupun SKS, jadi data ini menjadi
/// sumber tunggal untuk keperluan tampilan dan perhitungan IPS/IPK.
///
/// Tambahkan/ubah entri di sini ketika kurikulum berubah. Kode yang tidak ada
/// di tabel tetap ditampilkan apa adanya dan dikeluarkan dari perhitungan.
class MatkulReference {
  const MatkulReference._();

  static const Map<String, MatkulInfo> table = <String, MatkulInfo>{
    'GC301': MatkulInfo(
      kode: 'GC301',
      nama: 'Algoritma dan Pemrograman',
      sks: 3,
    ),
    'GC302': MatkulInfo(kode: 'GC302', nama: 'Basis Data', sks: 3),
    'GC303': MatkulInfo(kode: 'GC303', nama: 'Struktur Data', sks: 3),
    'GC304': MatkulInfo(kode: 'GC304', nama: 'Jaringan Komputer', sks: 3),
    'GC305': MatkulInfo(kode: 'GC305', nama: 'Sistem Operasi', sks: 2),
    'GC306': MatkulInfo(kode: 'GC306', nama: 'Pemrograman Web', sks: 3),
    'GC307': MatkulInfo(kode: 'GC307', nama: 'Kecerdasan Buatan', sks: 3),
    'GC308': MatkulInfo(kode: 'GC308', nama: 'Keamanan Siber', sks: 3),
    'GC309': MatkulInfo(kode: 'GC309', nama: 'Multimedia', sks: 3),
    'GC310': MatkulInfo(kode: 'GC310', nama: 'Statistika', sks: 2),
    'GC327': MatkulInfo(kode: 'GC327', nama: 'Pemrograman Mobile', sks: 3),
  };

  /// Cari referensi berdasarkan kode; `null` bila belum terdaftar.
  static MatkulInfo? find(String kode) {
    return table[kode.trim().toUpperCase()];
  }

  /// Nama matkul, atau kode apa adanya bila tidak ditemukan.
  static String nameOf(String kode) => find(kode)?.nama ?? kode.trim();

  /// SKS matkul, atau `null` bila kode belum terdaftar.
  static int? sksOf(String kode) => find(kode)?.sks;

  /// Seluruh entri referensi (read-only).
  static Iterable<MatkulInfo> get all => table.values;
}
