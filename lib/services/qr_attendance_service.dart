import '../models/attendance_log.dart';
import '../models/class_session.dart';
import '../models/course.dart';
import '../models/qr_payload.dart';

enum ScanStatus {
  hadir,
  sudahTercatat,
  kedaluwarsa,
  diLuarJadwal,
  mataKuliahTidakDikenal,
  formatTidakValid,
}

class ScanResult {
  const ScanResult(this.status, this.message, {this.log});

  final ScanStatus status;
  final String message;
  final AttendanceLog? log;

  bool get isSuccess => status == ScanStatus.hadir;
}

class QrAttendanceService {
  QrAttendanceService({
    DateTime Function()? clock,
    // Asumsi demo: mahasiswa boleh scan 15 menit sebelum jadwal dimulai.
    this.earlyWindow = const Duration(minutes: 15),
  }) : _now = clock ?? DateTime.now;

  final DateTime Function() _now;
  final Duration earlyWindow;

  ScanResult evaluate({
    required String? raw,
    required String npm,
    required List<Course> courses,
    required List<ClassSession> schedule,
    required List<AttendanceLog> existing,
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return const ScanResult(
        ScanStatus.formatTidakValid,
        'QR tidak berisi data presensi.',
      );
    }
    final payload = QrPayload.tryParse(raw);
    if (payload == null) {
      return const ScanResult(ScanStatus.formatTidakValid, 'QR TIDAK VALID');
    }
    final matchingCourses = courses.where((c) => c.code == payload.courseCode);
    if (matchingCourses.isEmpty) {
      return const ScanResult(
        ScanStatus.mataKuliahTidakDikenal,
        'Mata kuliah tidak terdaftar pada semester ini.',
      );
    }
    final course = matchingCourses.first;
    final now = _now();
    if (now.toUtc().isAfter(payload.expiresAt)) {
      return const ScanResult(
        ScanStatus.kedaluwarsa,
        'QR sudah kedaluwarsa. Minta dosen menampilkan QR baru.',
      );
    }
    if (!schedule.any(
      (session) =>
          session.courseCode == course.code &&
          _inWindow(session, now, earlyWindow),
    )) {
      return const ScanResult(
        ScanStatus.diLuarJadwal,
        'Di luar jadwal kuliah mata kuliah ini.',
      );
    }
    if (existing.any(
      (log) =>
          log.npm == npm &&
          log.courseCode == course.code &&
          log.meeting == payload.meeting,
    )) {
      return const ScanResult(
        ScanStatus.sudahTercatat,
        'Presensi pertemuan ini sudah tercatat.',
      );
    }
    return ScanResult(
      ScanStatus.hadir,
      'HADIR',
      log: AttendanceLog(
        npm: npm,
        courseCode: course.code,
        courseName: course.name,
        meeting: payload.meeting,
        scannedAt: now,
      ),
    );
  }

  DateTime _onDay(DateTime now, DateTime time) =>
      DateTime(now.year, now.month, now.day, time.hour, time.minute);

  bool _inWindow(ClassSession session, DateTime now, Duration early) {
    if (session.weekday != now.weekday) return false;
    final start = _onDay(now, session.start).subtract(early);
    final end = _onDay(now, session.end);
    return !now.isBefore(start) && !now.isAfter(end);
  }
}
