/// Konfigurasi tunggal untuk seluruh endpoint HTTP aplikasi.
///
/// Jangan menulis base URL di file lain. Saat backend asli tersedia, cukup
/// ganti [baseUrl] di sini tanpa menyentuh data source, repository, atau UI.
class ApiConfig {
  const ApiConfig._();

  /// Base URL MockAPI untuk data nilai.
  static const String baseUrl = 'https://6adab9277512f497b30020ef.mockapi.io';

  /// Path endpoint daftar nilai.
  static const String nilaiPath = '/nilai';

  /// Batas waktu seluruh request nilai.
  static const Duration timeout = Duration(seconds: 15);

  /// Membuat URI `GET /nilai?npm=<NPM>` dengan query yang aman.
  static Uri nilaiUri(String npm) {
    return Uri.parse('$baseUrl$nilaiPath')
        .replace(queryParameters: <String, String>{'npm': npm.trim()});
  }
}
