import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/grade.dart';

/// Hasil pemanggilan API nilai: berhasil atau gagal.
sealed class NilaiResult {
  const NilaiResult();
}

/// Berhasil — [grades] berisi daftar nilai dari endpoint mockapi.io.
class NilaiSuccess extends NilaiResult {
  const NilaiSuccess(this.grades);

  final List<Grade> grades;
}

/// Gagal — [message] menjelaskan penyebabnya dan layak ditampilkan.
class NilaiFailure extends NilaiResult {
  const NilaiFailure(this.message);

  final String message;
}

/// Service pengambil data nilai dari mockapi.io.
///
/// Endpoint: `https://6adab9277512f497b30020ef.mockapi.io/nilai?npm={npm}`
///
/// **Catatan:** endpoint ini adalah sumber data nilai simulasi untuk beta.
/// Tidak dipakai untuk autentikasi atau verifikasi identitas mahasiswa.
///
/// Skema respons yang telah diverifikasi (2026-10):
/// - `id`, `kd_matkul`, `npm`, `uas`, `uts`, `quis`, `tugas`, `hadir`
/// - `na_uas`, `na_uts`, `na_quis`, `na_tugas`, `na_hadir`
/// - `na` (nilai akhir), `hm` (huruf mutu), `am` (angka mutu / bobot nilai)
/// - `mutu` (am × SKS), `thn_akademik`, `semester`, `nip`
class NilaiApi {
  const NilaiApi({
    this.timeout = const Duration(seconds: 10),
    this.client,
  });

  static const String _baseUrl =
      'https://6adab9277512f497b30020ef.mockapi.io/nilai';

  final Duration timeout;

  /// Klien HTTP opsional — berguna untuk pengujian.
  final http.Client? client;

  /// Mengambil daftar nilai berdasarkan [npm] mahasiswa yang sedang login.
  ///
  /// NPM dipakai sebagai query parameter `npm`; tidak pernah dipakai
  /// sebagai password atau kata sandi.
  Future<NilaiResult> fetchGradesByNpm(String npm) async {
    if (npm.trim().isEmpty) {
      return const NilaiFailure('NPM tidak tersedia. Nilai tidak dapat dimuat.');
    }

    final uri = Uri.parse('$_baseUrl?npm=${Uri.encodeQueryComponent(npm.trim())}');
    http.Client? activeClient;

    try {
      activeClient = client ?? http.Client();
      final response = await activeClient.get(uri).timeout(timeout);

      if (response.statusCode != 200) {
        return NilaiFailure(
          'Server nilai merespons status ${response.statusCode}. '
          'Coba lagi beberapa saat lagi.',
        );
      }

      final decoded = json.decode(response.body);

      // Respons bisa berupa List langsung atau object dengan key "value"
      List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['value'] is List) {
        items = decoded['value'] as List;
      } else {
        return const NilaiFailure('Format respons API nilai tidak dikenali.');
      }

      final grades = <Grade>[];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final grade = _parseGrade(item);
        if (grade != null) grades.add(grade);
      }

      return NilaiSuccess(grades);
    } on TimeoutException {
      return NilaiFailure(
        'Permintaan ke API nilai melebihi batas waktu '
        '(${timeout.inSeconds} detik).',
      );
    } on FormatException {
      return const NilaiFailure('Respons API nilai tidak dapat dibaca.');
    } catch (error) {
      return NilaiFailure('Gagal mengambil data nilai: $error');
    } finally {
      if (client == null) activeClient?.close();
    }
  }

  /// Memetakan satu item JSON ke [Grade].
  ///
  /// Field yang dipakai (sesuai skema yang diverifikasi):
  /// - `kd_matkul` → courseCode
  /// - `na`  → totalScore (nilai akhir)
  /// - `na_uts` → midTermScore
  /// - `na_uas` → finalScore
  /// - `na_tugas` → taskScore
  /// - `hm`  → letterGrade (huruf mutu)
  /// - `am`  → angkaMutu
  /// - `thn_akademik` dan `semester` untuk info tambahan
  Grade? _parseGrade(Map<String, dynamic> json) {
    final kode = '${json['kd_matkul'] ?? ''}'.trim();
    if (kode.isEmpty) return null;

    // na_* adalah nilai per komponen sudah diperhitungkan bobot
    final naUts = _toDouble(json['na_uts']);
    final naUas = _toDouble(json['na_uas']);
    final naTugas = _toDouble(json['na_tugas']);
    final na = _toDouble(json['na']);
    final hm = '${json['hm'] ?? ''}'.trim();
    final am = _toDouble(json['am']);
    final thnAkademik = '${json['thn_akademik'] ?? ''}'.trim();
    final semester = '${json['semester'] ?? ''}'.trim();

    return Grade.fromApi(
      courseCode: kode,
      courseName: kode, // nama MK tidak tersedia di endpoint; gunakan kode
      taskScore: naTugas,
      midTermScore: naUts,
      finalScore: naUas,
      totalScoreOverride: na,
      letterGradeOverride: hm.isNotEmpty ? hm : null,
      angkaMutu: am,
      thnAkademik: thnAkademik,
      semester: semester,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }
}
