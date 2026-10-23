/// Rekap presensi satu mata kuliah (data demo).
class AttendanceRecord {
  const AttendanceRecord({
    required this.courseCode,
    required this.courseName,
    required this.totalMeeting,
    required this.attended,
    required this.sick,
    required this.permission,
    required this.missed,
  });

  final String courseCode;
  final String courseName;

  /// Jumlah pertemuan efektif pada semester berjalan.
  final int totalMeeting;
  final int attended;
  final int sick;
  final int permission;

  /// Pertemuan tanpa keterangan.
  final int missed;

  /// Persentase kehadiran (0–100).
  double get percentage =>
      totalMeeting == 0 ? 0 : (attended / totalMeeting) * 100;
}
