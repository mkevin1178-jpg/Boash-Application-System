import 'dart:async';

import '../models/announcement.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/attendance_log.dart';
import '../models/class_session.dart';
import '../models/course.dart';
import '../models/course_material.dart';
import '../models/grade.dart';
import '../services/qr_attendance_service.dart';
import 'demo_data.dart';

/// Repository data demo.
///
/// Menyediakan seluruh data akademik dengan penundaan (latensi) singkat agar
/// state pemuatan, error, dan data kosong dapat benar-benar terjadi dan
/// diuji.
///
/// [simulateFailure] dipakai oleh pengujian untuk memverifikasi tampilan
/// error tanpa bergantung jaringan.
class DemoRepository {
  DemoRepository({
    this.latency = const Duration(milliseconds: 350),
    this.simulateFailure = false,
    QrAttendanceService? qrAttendanceService,
  }) : _qrAttendanceService = qrAttendanceService ?? QrAttendanceService();

  /// Jeda artificial sebelum data dikembalikan.
  final Duration latency;

  /// Bila `true`, setiap pemanggilan melempar exception.
  final bool simulateFailure;

  final QrAttendanceService _qrAttendanceService;
  final List<AttendanceLog> _attendanceLogs = [];

  DateTime get _now => DateTime.now();

  Future<T> _respond<T>(T value) async {
    await Future<void>.delayed(latency);
    if (simulateFailure) {
      throw Exception('Data gagal dimuat. Periksa koneksi lalu coba lagi.');
    }
    return value;
  }

  Future<List<Course>> fetchCourses() => _respond(DemoData.courses);

  Future<List<ClassSession>> fetchSchedule() =>
      _respond(DemoData.buildSchedule());

  Future<List<Assignment>> fetchAssignments() =>
      _respond(DemoData.buildAssignments(_now));

  Future<List<CourseMaterial>> fetchMaterials() =>
      _respond(DemoData.buildMaterials(_now));

  /// Mengambil nilai demo lokal (hard-coded).
  Future<List<Grade>> fetchGrades() => _respond(DemoData.grades);

  Future<List<AttendanceRecord>> fetchAttendance() =>
      _respond(DemoData.attendance);

  /// Validasi dan catat QR demo. Penulisan hanya dilakukan setelah repository
  /// berhasil merespons, sehingga simulateFailure tidak menghasilkan HADIR.
  Future<ScanResult> submitQrScan(String? raw, {required String npm}) async {
    await Future<void>.delayed(latency);
    if (simulateFailure) {
      throw Exception('Scan QR gagal diproses. Silakan coba lagi.');
    }
    final result = _qrAttendanceService.evaluate(
      raw: raw,
      npm: npm,
      courses: DemoData.courses,
      schedule: DemoData.buildSchedule(),
      existing: _attendanceLogs,
    );
    if (result.isSuccess && result.log != null) {
      _attendanceLogs.add(result.log!);
    }
    return result;
  }

  /// Log selalu difilter per NPM agar sesi mahasiswa tidak saling bercampur.
  Future<List<AttendanceLog>> fetchAttendanceLogs(String npm) => _respond(
    _attendanceLogs.where((log) => log.npm == npm).toList(growable: false),
  );

  /// Rekap dasar demo ditambah setiap log QR sebagai pertemuan tambahan.
  /// Ini asumsi demo; aturan rekap resmi belum tersedia.
  Future<List<AttendanceRecord>> fetchAttendanceFor(String npm) async {
    final records = await fetchAttendance();
    final logs = await fetchAttendanceLogs(npm);
    return [
      for (final record in records)
        () {
          final added = logs
              .where((log) => log.courseCode == record.courseCode)
              .length;
          return added == 0
              ? record
              : record.copyWith(
                  totalMeeting: record.totalMeeting + added,
                  attended: record.attended + added,
                );
        }(),
    ];
  }

  Future<List<Announcement>> fetchAnnouncements() =>
      _respond(DemoData.buildAnnouncements(_now));
}
