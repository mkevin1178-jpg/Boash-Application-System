/// Konfigurasi tunggal untuk seluruh endpoint HTTP aplikasi.
///
/// Jangan menulis base URL di file lain. Saat backend asli tersedia, cukup
/// ganti nilai di sini tanpa menyentuh data source, repository, atau UI.
class ApiConfig {
  const ApiConfig._();

  /// Base URL MockAPI untuk data nilai (Host A).
  static const String nilaiBaseUrl =
      'https://6adab9277512f497b30020ef.mockapi.io';

  /// Base URL MockAPI untuk data akademik: KRS dan mahasiswa (Host B).
  static const String akademikBaseUrl =
      'https://6aed363dfc3b911e6fd60ab2.mockapi.io';

  /// Base URL untuk enam endpoint BAS yang baru (Host A, sama dengan nilai).
  static const String basBaseUrl = nilaiBaseUrl;

  /// Path endpoint daftar nilai.
  static const String nilaiPath = '/nilai';

  /// Path endpoint KRS.
  static const String krsPath = '/krs';

  /// Path endpoint profil mahasiswa.
  static const String mahasiswaPath = '/mahasiswa';

  /// Path endpoint riwayat kehadiran.
  static const String kehadiranPath = '/kehadiran';

  /// Path endpoint sertifikat.
  static const String sertifikatPath = '/sertifikat';

  /// Path endpoint data bimbingan.
  static const String bimbinganPath = '/bimbingan_data';

  /// Path endpoint pembayaran mahasiswa.
  static const String financePath = '/fin_mhs_payment';

  /// Path endpoint berita kampus.
  static const String beritaPath = '/berita';

  /// Path endpoint informasi kampus.
  static const String informasiPath = '/informasi';

  /// Batas waktu seluruh request HTTP.
  static const Duration timeout = Duration(seconds: 15);

  /// Membuat URI `GET /nilai?npm=<NPM>` dengan query yang aman.
  static Uri nilaiUri(String npm) =>
      _withQuery(nilaiBaseUrl, nilaiPath, 'npm', npm);

  /// Membuat URI `GET /krs?npm=<NPM>` dengan query yang aman.
  static Uri krsUri(String npm) =>
      _withQuery(akademikBaseUrl, krsPath, 'npm', npm);

  /// Membuat URI `GET /mahasiswa?npm=<NPM>` dengan query yang aman.
  static Uri mahasiswaUri(String npm) =>
      _withQuery(akademikBaseUrl, mahasiswaPath, 'npm', npm);

  /// Endpoint kehadiran memakai `userid` sebagai identitas mahasiswa.
  static Uri kehadiranUri(String npm) =>
      _withQuery(basBaseUrl, kehadiranPath, 'userid', npm);

  static Uri sertifikatUri(String npm) =>
      _withQuery(basBaseUrl, sertifikatPath, 'npm', npm);

  static Uri bimbinganUri(String npm) =>
      _withQuery(basBaseUrl, bimbinganPath, 'npm', npm);

  static Uri financeUri(String npm) =>
      _withQuery(basBaseUrl, financePath, 'npm', npm);

  /// Berita dan informasi tidak memiliki field NPM.
  static Uri beritaUri() => Uri.parse('$basBaseUrl$beritaPath');

  static Uri informasiUri() => Uri.parse('$basBaseUrl$informasiPath');

  /// URI untuk POST ke path yang sudah didefinisikan di atas.
  static Uri postUri(String path) => Uri.parse('$basBaseUrl$path');

  static Uri _withQuery(String baseUrl, String path, String key, String value) {
    return Uri.parse('$baseUrl$path')
        .replace(queryParameters: <String, String>{key: value.trim()});
  }
}
