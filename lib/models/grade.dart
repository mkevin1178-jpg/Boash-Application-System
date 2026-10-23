/// Nilai satu mata kuliah pada semester berjalan (data demo atau API).
class Grade {
  const Grade({
    required this.courseCode,
    required this.courseName,
    required this.taskScore,
    required this.midTermScore,
    required this.finalScore,
    required this.weight,
    this.totalScoreOverride,
    this.letterGradeOverride,
    this.angkaMutu,
    this.thnAkademik,
    this.semester,
  });

  /// Factory untuk data yang berasal dari endpoint mockapi.io /nilai.
  ///
  /// Karena API mengembalikan nilai komponen yang sudah dikalikan bobot
  /// (mis. `na_uts`, `na_uas`), gunakan [totalScoreOverride] dan
  /// [letterGradeOverride] dari field `na` dan `hm` secara langsung.
  factory Grade.fromApi({
    required String courseCode,
    required String courseName,
    required double taskScore,
    required double midTermScore,
    required double finalScore,
    double? totalScoreOverride,
    String? letterGradeOverride,
    double? angkaMutu,
    String? thnAkademik,
    String? semester,
  }) {
    return Grade(
      courseCode: courseCode,
      courseName: courseName,
      taskScore: taskScore,
      midTermScore: midTermScore,
      finalScore: finalScore,
      weight: 40, // bobot default — tidak dipakai bila totalScoreOverride tersedia
      totalScoreOverride: totalScoreOverride,
      letterGradeOverride: letterGradeOverride,
      angkaMutu: angkaMutu,
      thnAkademik: thnAkademik,
      semester: semester,
    );
  }

  final String courseCode;
  final String courseName;

  /// Nilai tugas (bobot [weight]%).
  final double taskScore;
  final double midTermScore;
  final double finalScore;

  /// Bobot komponen tugas dalam persen (dipakai untuk perhitungan lokal).
  final int weight;

  /// Nilai akhir dari API (`na`) — menggantikan perhitungan lokal bila tersedia.
  final double? totalScoreOverride;

  /// Huruf mutu dari API (`hm`) — menggantikan perhitungan lokal bila tersedia.
  final String? letterGradeOverride;

  /// Angka mutu (am) dari API — dipakai untuk perhitungan mutu pada DHS.
  final double? angkaMutu;

  /// Tahun akademik dari API (mis. "2023/2024").
  final String? thnAkademik;

  /// Semester dari API (mis. "1").
  final String? semester;

  /// Nilai akhir rata-rata tertimbang.
  ///
  /// Jika data berasal dari API, gunakan [totalScoreOverride] langsung.
  double get totalScore {
    if (totalScoreOverride != null) return totalScoreOverride!;
    return (taskScore * weight +
            midTermScore * (100 - weight) * 0.4 +
            finalScore * (100 - weight) * 0.6) /
        100;
  }

  /// Grade huruf berdasarkan nilai akhir.
  ///
  /// Jika data berasal dari API, gunakan [letterGradeOverride] langsung.
  String get letterGrade {
    if (letterGradeOverride != null && letterGradeOverride!.isNotEmpty) {
      return letterGradeOverride!;
    }
    final value = totalScore;
    if (value >= 85) return 'A';
    if (value >= 75) return 'B+';
    if (value >= 70) return 'B';
    if (value >= 65) return 'C+';
    if (value >= 60) return 'C';
    if (value >= 55) return 'D';
    return 'E';
  }
}

/// Satu baris pada Daftar Hasil Studi (DHS) per semester.
///
/// DHS menampilkan rekap nilai tiap semester secara lengkap:
/// kode MK, nama MK, SKS, nilai angka, huruf mutu, angka mutu,
/// dan nilai mutu (angka mutu × SKS). Dipakai untuk menghitung IPS dan IPK.
class DhsGrade {
  const DhsGrade({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.na,
    required this.hm,
    required this.am,
    this.thnAkademik = '',
    this.semester = '',
  });

  /// Kode mata kuliah, mis. "MK-01" atau "GC327".
  final String courseCode;

  /// Nama mata kuliah.
  final String courseName;

  /// Jumlah SKS mata kuliah.
  final int credits;

  /// Nilai angka akhir (0–100).
  final double na;

  /// Huruf mutu, mis. "A", "B+", "B".
  final String hm;

  /// Angka mutu sesuai konversi nilai (0–4).
  final double am;

  /// Tahun akademik, mis. "2023/2024".
  final String thnAkademik;

  /// Semester, mis. "1", "2".
  final String semester;

  /// Nilai mutu = angka mutu × SKS.
  double get mutu => am * credits;

  /// Label semester yang dapat dibaca.
  String get semesterLabel {
    if (thnAkademik.isNotEmpty && semester.isNotEmpty) {
      final smt = int.tryParse(semester);
      final label = smt != null
          ? (smt.isOdd ? 'Ganjil' : 'Genap')
          : 'Semester $semester';
      return 'TA $thnAkademik — $label';
    }
    if (thnAkademik.isNotEmpty) return 'TA $thnAkademik';
    if (semester.isNotEmpty) return 'Semester $semester';
    return '-';
  }
}
