/// Satu baris KRS mahasiswa dari endpoint `/krs`.
///
/// Field `id` dari API campur tipe (int dan string), sedangkan `semester`
/// dan `status` juga bisa berbentuk string. Semua di-parse dengan aman.
/// Field `tahun` dan `tri_semester` sengaja diabaikan karena isinya sampah
/// atau `null`.
class KrsItem {
  const KrsItem({
    required this.id,
    required this.npm,
    required this.kdMatkul,
    required this.kdKelas,
    required this.thnAkademik,
    required this.semester,
    required this.semesterNow,
    required this.statusRaw,
  });

  factory KrsItem.fromJson(Map<String, dynamic> json) {
    return KrsItem(
      id: _toInt(json['id']),
      npm: _toText(json['npm']),
      kdMatkul: _toText(json['kd_matkul']),
      kdKelas: _toText(json['kd_kelas']),
      thnAkademik: _toText(json['thn_akademik']),
      semester: _toInt(json['semester']),
      semesterNow: _toText(json['semester_now']),
      statusRaw: _toInt(json['status']),
    );
  }

  /// ID numerik record KRS. String numerik di-parse; nilai lain menjadi 0.
  final int id;
  final String npm;
  final String kdMatkul;
  final String kdKelas;
  final String thnAkademik;
  final int semester;
  final String semesterNow;

  /// Nilai mentah `status` (0/1). Artinya BELUM DIKONFIRMASI.
  final int statusRaw;

  String get semesterLabel {
    if (thnAkademik.isEmpty && semester == 0) return '-';
    final name = semester == 0
        ? 'Semester -'
        : (semester.isOdd ? 'Ganjil' : 'Genap');
    if (thnAkademik.isEmpty) return name;
    return 'TA $thnAkademik • $name';
  }

  static int _toInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static String _toText(Object? value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }
}
