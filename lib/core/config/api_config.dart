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

  /// Path endpoint daftar nilai.
  static const String nilaiPath = '/nilai';

  /// Path endpoint KRS.
  static const String krsPath = '/krs';

  /// Path endpoint profil mahasiswa.
  static const String mahasiswaPath = '/mahasiswa';

  /// Batas waktu seluruh request HTTP.
  static const Duration timeout = Duration(seconds: 15);

  /// Membuat URI `GET /nilai?npm=<NPM>` dengan query yang aman.
  static Uri nilaiUri(String npm) =>
      _withNpmQuery(nilaiBaseUrl, nilaiPath, npm);

  /// Membuat URI `GET /krs?npm=<NPM>` dengan query yang aman.
  static Uri krsUri(String npm) => _withNpmQuery(akademikBaseUrl, krsPath, npm);

  /// Membuat URI `GET /mahasiswa?npm=<NPM>` dengan query yang aman.
  static Uri mahasiswaUri(String npm) =>
      _withNpmQuery(akademikBaseUrl, mahasiswaPath, npm);

  static Uri _withNpmQuery(String baseUrl, String path, String npm) {
    return Uri.parse('$baseUrl$path')
        .replace(queryParameters: <String, String>{'npm': npm.trim()});
  }
}
