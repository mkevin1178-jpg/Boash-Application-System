import '../../../shared/matkul_reference.dart';
import '../data/models/nilai_model.dart';

/// Ringkasan satu semester.
class SemesterSummary {
  const SemesterSummary({
    required this.totalSks,
    required this.totalMutu,
    required this.ips,
    required this.courseCount,
    required this.countedCourseCount,
    required this.unknownCourseCodes,
  });

  final int totalSks;
  final double totalMutu;
  final double ips;
  final int courseCount;
  final int countedCourseCount;
  final List<String> unknownCourseCodes;

  bool get hasUnknownCourses => unknownCourseCodes.isNotEmpty;
}

/// Ringkasan seluruh semester (IPK).
class AcademicSummary {
  const AcademicSummary({
    required this.totalSks,
    required this.totalMutu,
    required this.ipk,
    required this.courseCount,
    required this.countedCourseCount,
    required this.unknownCourseCodes,
  });

  final int totalSks;
  final double totalMutu;
  final double ipk;
  final int courseCount;
  final int countedCourseCount;
  final List<String> unknownCourseCodes;

  bool get hasUnknownCourses => unknownCourseCodes.isNotEmpty;
}

/// Satu kelompok nilai untuk tahun akademik + semester tertentu.
class SemesterGroup {
  const SemesterGroup({
    required this.thnAkademik,
    required this.semester,
    required this.values,
    required this.summary,
  });

  final String thnAkademik;
  final int semester;
  final List<Nilai> values;
  final SemesterSummary summary;

  String get key => '$thnAkademik#$semester';

  String get label {
    final name = semester == 0
        ? 'Semester -'
        : (semester.isOdd ? 'Ganjil' : 'Genap');

    if (thnAkademik.isEmpty) return name;
    return 'TA $thnAkademik • $name';
  }
}

/// Kalkulator IPS/IPK.
///
/// Rumus sesuai rancangan:
/// `IP = Σ(angka mutu × SKS) / Σ(SKS)`.
/// Matkul yang tidak ada di [MatkulReference] tidak dihitung dan dicatat
/// sebagai peringatan agar UI bisa menjelaskannya ke pengguna.
class IpsCalculator {
  const IpsCalculator._();

  static SemesterSummary forSemester(Iterable<Nilai> values) {
    var totalSks = 0;
    var totalMutu = 0.0;
    var counted = 0;
    final unknown = <String>{};

    for (final nilai in values) {
      final sks = MatkulReference.sksOf(nilai.kdMatkul);
      if (sks == null || sks <= 0) {
        unknown.add(nilai.kdMatkul.isEmpty ? '-' : nilai.kdMatkul);
        continue;
      }

      totalSks += sks;
      totalMutu += nilai.am * sks;
      counted++;
    }

    final ips = totalSks > 0 ? totalMutu / totalSks : 0.0;

    return SemesterSummary(
      totalSks: totalSks,
      totalMutu: totalMutu,
      ips: ips,
      courseCount: values.length,
      countedCourseCount: counted,
      unknownCourseCodes: unknown.toList()..sort(),
    );
  }

  static AcademicSummary overall(Iterable<Nilai> values) {
    final summary = forSemester(values);
    return AcademicSummary(
      totalSks: summary.totalSks,
      totalMutu: summary.totalMutu,
      ipk: summary.ips,
      courseCount: summary.courseCount,
      countedCourseCount: summary.countedCourseCount,
      unknownCourseCodes: summary.unknownCourseCodes,
    );
  }

  /// Mengelompokkan nilai per tahun akademik + semester.
  ///
  /// Urutan tampilan: tahun akademik terbaru dulu, lalu semester terbesar.
  /// Di dalam satu kelompok, matkul diurutkan berdasarkan kode agar stabil.
  static List<SemesterGroup> groupBySemester(Iterable<Nilai> values) {
    final grouped = <String, List<Nilai>>{};

    for (final nilai in values) {
      final key = '${nilai.thnAkademik}#${nilai.semester}';
      grouped.putIfAbsent(key, () => <Nilai>[]).add(nilai);
    }

    final groups = grouped.values.map((items) {
      final sorted = List<Nilai>.of(items)
        ..sort((a, b) => a.kdMatkul.compareTo(b.kdMatkul));
      final first = sorted.first;

      return SemesterGroup(
        thnAkademik: first.thnAkademik,
        semester: first.semester,
        values: List<Nilai>.unmodifiable(sorted),
        summary: forSemester(sorted),
      );
    }).toList();

    groups.sort((a, b) {
      final year = b.thnAkademik.compareTo(a.thnAkademik);
      if (year != 0) return year;
      return b.semester.compareTo(a.semester);
    });

    return List<SemesterGroup>.unmodifiable(groups);
  }
}
