/// Payload QR presensi versi 1.
class QrPayload {
  const QrPayload({
    required this.courseCode,
    required this.meeting,
    required this.expiresAt,
  });

  static const String prefix = 'BAS-ATT';
  static const String version = '1';

  final String courseCode;
  final int meeting;
  final DateTime expiresAt;

  /// Menghasilkan null bila format tidak sesuai; tidak melempar exception.
  static QrPayload? tryParse(String raw) {
    final parts = raw.trim().split('|');
    if (parts.length != 5 || parts[0] != prefix || parts[1] != version) {
      return null;
    }
    final meeting = int.tryParse(parts[3]);
    final expiry = int.tryParse(parts[4]);
    if (parts[2].isEmpty || meeting == null || meeting < 1 || expiry == null) {
      return null;
    }
    try {
      return QrPayload(
        courseCode: parts[2],
        meeting: meeting,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          expiry * 1000,
          isUtc: true,
        ),
      );
    } on RangeError {
      return null;
    }
  }
}
