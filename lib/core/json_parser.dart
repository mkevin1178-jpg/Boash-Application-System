/// Helper parsing nilai dari JSON yang bisa kosong, null, atau bertipe lain.
///
/// Endpoint MockAPI mengirim angka sebagai string dan sebagian field nullable.
/// Semua helper di sini mengembalikan nilai aman agar satu record kotor tidak
/// membuat aplikasi crash.
class ApiJson {
  const ApiJson._();

  /// Teks aman: null, "null", dan spasi berlebih menjadi string kosong.
  static String text(Object? value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  /// Angka bulat dari String/int/double; mengembalikan [fallback] bila invalid.
  static int integer(Object? value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(text(value)) ?? fallback;
  }

  /// Angka desimal dari String/int/double; mengembalikan [fallback] bila invalid.
  static double number(Object? value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(text(value)) ?? fallback;
  }

  /// Tanggal dari `yyyy-MM-dd`, `yyyy-MM-dd HH:mm:ss`, atau ISO 8601.
  static DateTime? date(Object? value) {
    final raw = text(value);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  /// Tanggal dari epoch detik (field seperti `tanggal_sertifikat`).
  static DateTime? unixSeconds(Object? value) {
    if (value == null) return null;
    final seconds = value is num ? value.toInt() : int.tryParse(text(value));
    if (seconds == null || seconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
