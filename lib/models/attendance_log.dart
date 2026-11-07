/// Catatan presensi hasil scan QR, disimpan sementara di memori aplikasi.
class AttendanceLog {
  const AttendanceLog({
    required this.npm,
    required this.courseCode,
    required this.courseName,
    required this.meeting,
    required this.scannedAt,
  });

  final String npm;
  final String courseCode;
  final String courseName;
  final int meeting;
  final DateTime scannedAt;
}
