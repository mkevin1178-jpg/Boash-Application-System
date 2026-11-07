import 'dart:async';

import '../models/announcement.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/attendance_log.dart';
import '../models/class_session.dart';
import '../models/course.dart';
import '../models/course_material.dart';
import '../models/grade.dart';
import '../services/nilai_api.dart';
import '../services/qr_attendance_service.dart';
import '../shared/matkul_reference.dart';
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
    NilaiApi? nilaiApi,
    QrAttendanceService? qrAttendanceService,
  }) : _nilaiApi = nilaiApi ?? const NilaiApi(),
       _qrAttendanceService = qrAttendanceService ?? QrAttendanceService();

  /// Jeda artificial sebelum data dikembalikan.
  final Duration latency;

  /// Bila `true`, setiap pemanggilan melempar exception.
  final bool simulateFailure;

  final NilaiApi _nilaiApi;
  final QrAttendanceService _qrAttendanceService;
  final List<AttendanceLog> _attendanceLogs = [];

  DateTime get _now => DateTime.now();

  Future<T> _respond<T>(T value) async {
    await Future<void>.delayed(latency);
    if (simulateFailure) {
      throw Exception(
        'Data gagal dimuat. Periksa koneksi lalu coba lagi.',
      );
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

  /// Mengambil nilai dari API mockapi.io berdasarkan NPM mahasiswa yang login.
  ///
  /// Jika [npm] kosong atau API tidak dapat dihubungi (network error),
  /// fallback ke data demo lokal hanya untuk error jaringan.
  ///
  /// Jika NPM tidak ditemukan di API (list kosong setelah filter client-side),
  /// kembalikan list kosong — pemanggil menampilkan empty state yang jujur.
  /// Tidak ada fallback diam-diam ke data demo untuk NPM yang tidak cocok.
  Future<List<Grade>> fetchApiGrades(String npm) async {
    if (simulateFailure) {
      throw Exception(
        'Data nilai gagal dimuat. Periksa koneksi lalu coba lagi.',
      );
    }

    if (npm.trim().isEmpty) {
      // NPM belum tersedia, kembalikan data lokal sebagai tampilan default
      return DemoData.grades;
    }

    final result = await _nilaiApi.fetchGradesByNpm(npm);

    switch (result) {
      case NilaiSuccess(:final grades):
        // Jika NPM tidak ditemukan di API, kembalikan list kosong (empty state)
        // Jangan fallback ke DemoData.grades karena itu akan menyesatkan
        return grades;
      case NilaiFailure():
        // Gagal jaringan: fallback ke data demo agar aplikasi tetap bisa dipakai
        return DemoData.grades;
    }
  }

  /// Mengambil data DHS dari API mockapi.io berdasarkan NPM.
  ///
  /// Jika NPM tidak ditemukan di API (list kosong), kembalikan list kosong.
  /// Jika gagal jaringan, fallback ke data demo lokal.
  Future<List<DhsGrade>> fetchDhsGrades(String npm) async {
    if (simulateFailure) {
      throw Exception('Data DHS gagal dimuat. Periksa koneksi lalu coba lagi.');
    }

    if (npm.trim().isEmpty) {
      return DemoData.dhsGrades;
    }

    final result = await _nilaiApi.fetchGradesByNpm(npm);

    switch (result) {
      case NilaiSuccess(:final grades):
        if (grades.isEmpty) {
          // NPM tidak ditemukan di API — kembalikan kosong, bukan data demo
          return const [];
        }
        return grades
            .map(
              (g) => DhsGrade(
                courseCode: g.courseCode,
                courseName: g.courseName.isNotEmpty
                    ? g.courseName
                    : g.courseCode,
                credits: MatkulReference.sksOf(g.courseCode) ?? 3,
                na: g.totalScore,
                hm: g.letterGrade,
                am: g.angkaMutu ?? _amFromHm(g.letterGrade),
                thnAkademik: g.thnAkademik ?? '',
                semester: g.semester ?? '',
              ),
            )
            .toList();
      case NilaiFailure():
        return DemoData.dhsGrades;
    }
  }

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

  /// Konversi huruf mutu ke angka mutu standar Indonesia.
  static double _amFromHm(String hm) {
    switch (hm.toUpperCase().trim()) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.75;
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.75;
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
