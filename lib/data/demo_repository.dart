import 'dart:async';

import '../models/announcement.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/class_session.dart';
import '../models/course.dart';
import '../models/course_material.dart';
import '../models/grade.dart';
import '../services/nilai_api.dart';
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
  }) : _nilaiApi = nilaiApi ?? const NilaiApi();

  /// Jeda artificial sebelum data dikembalikan.
  final Duration latency;

  /// Bila `true`, setiap pemanggilan melempar exception.
  final bool simulateFailure;

  final NilaiApi _nilaiApi;

  DateTime get _now => DateTime.now();

  Future<T> _respond<T>(T value) async {
    await Future<void>.delayed(latency);
    if (simulateFailure) {
      throw Exception(
        'Data demo gagal dimuat. Periksa koneksi lalu coba lagi.',
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
  /// Jika [npm] kosong atau API gagal, fallback ke data demo lokal.
  /// Tidak pernah dipakai untuk autentikasi.
  Future<List<Grade>> fetchApiGrades(String npm) async {
    if (simulateFailure) {
      throw Exception(
        'Data nilai gagal dimuat. Periksa koneksi lalu coba lagi.',
      );
    }

    final result = await _nilaiApi.fetchGradesByNpm(npm);

    switch (result) {
      case NilaiSuccess(:final grades):
        if (grades.isEmpty) {
          // NPM tidak ditemukan di API — gunakan data demo lokal
          return DemoData.grades;
        }
        return grades;
      case NilaiFailure():
        // Gagal terhubung ke API — gunakan data demo lokal sebagai fallback
        return DemoData.grades;
    }
  }

  /// Mengambil data DHS (Daftar Hasil Studi) dari API mockapi.io
  /// berdasarkan NPM mahasiswa yang login.
  ///
  /// Jika API gagal atau NPM tidak ditemukan, fallback ke data demo lokal.
  Future<List<DhsGrade>> fetchDhsGrades(String npm) async {
    if (simulateFailure) {
      throw Exception(
        'Data DHS gagal dimuat. Periksa koneksi lalu coba lagi.',
      );
    }

    final result = await _nilaiApi.fetchGradesByNpm(npm);

    switch (result) {
      case NilaiSuccess(:final grades):
        if (grades.isEmpty) {
          return DemoData.dhsGrades;
        }
        // Konversi Grade (dari API) menjadi DhsGrade
        // Nama MK tidak tersedia di API, gunakan kode sebagai nama sementara
        return grades
            .map(
              (g) => DhsGrade(
                courseCode: g.courseCode,
                courseName: g.courseName.isNotEmpty
                    ? g.courseName
                    : g.courseCode,
                credits: 3, // SKS tidak tersedia di endpoint nilai; pakai default
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

  Future<List<Announcement>> fetchAnnouncements() =>
      _respond(DemoData.buildAnnouncements(_now));

  /// Konversi huruf mutu ke angka mutu standar Indonesia bila am tidak tersedia.
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
