/// Satu baris nilai mahasiswa dari endpoint `/nilai`.
///
/// Seluruh angka dari API dikirim sebagai string dan sebagian field dapat
/// kosong/null. Parsing dilakukan lewat helper yang selalu mengembalikan nilai
/// aman supaya satu record kotor tidak membuat aplikasi crash.
class Nilai {
  const Nilai({
    required this.id,
    required this.kdMatkul,
    required this.npm,
    required this.uas,
    required this.uts,
    required this.quis,
    required this.tugas,
    required this.hadir,
    required this.naUas,
    required this.naUts,
    required this.naQuis,
    required this.naTugas,
    required this.naHadir,
    required this.hm,
    required this.na,
    required this.am,
    required this.mutu,
    required this.thnAkademik,
    required this.semester,
  });

  factory Nilai.fromJson(Map<String, dynamic> json) {
    return Nilai(
      id: _toInt(json['id']),
      kdMatkul: _toText(json['kd_matkul']),
      npm: _toText(json['npm']),
      uas: toDouble(json['uas']),
      uts: toDouble(json['uts']),
      quis: toDouble(json['quis']),
      tugas: toDouble(json['tugas']),
      hadir: toDouble(json['hadir']),
      naUas: toDouble(json['na_uas']),
      naUts: toDouble(json['na_uts']),
      naQuis: toDouble(json['na_quis']),
      naTugas: toDouble(json['na_tugas']),
      naHadir: toDouble(json['na_hadir']),
      hm: _toText(json['hm']),
      na: toDouble(json['na']),
      am: toDouble(json['am']),
      mutu: toDouble(json['mutu']),
      thnAkademik: _toText(json['thn_akademik']),
      semester: _toInt(json['semester']),
    );
  }

  final int id;
  final String kdMatkul;
  final String npm;

  final double uas;
  final double uts;
  final double quis;
  final double tugas;
  final double hadir;

  final double naUas;
  final double naUts;
  final double naQuis;
  final double naTugas;
  final double naHadir;

  final String hm;
  final double na;
  final double am;
  final double mutu;
  final String thnAkademik;
  final int semester;

  /// Label semester yang enak dibaca, mis. `2023/2024 • Ganjil`.
  String get semesterLabel {
    final name = semesterName;
    if (thnAkademik.isEmpty && semester == 0) return '-';
    if (thnAkademik.isEmpty) return name;
    if (semester == 0) return thnAkademik;
    return '$thnAkademik • $name';
  }

  /// Nama semester berdasarkan nomor ganjil/genap.
  String get semesterName {
    if (semester == 0) return 'Semester -';
    return semester.isOdd ? 'Ganjil' : 'Genap';
  }

  /// Parsing angka aman: null, kosong, atau teks tidak valid menjadi `0.0`.
  ///
  /// Koma desimal juga diterima karena sebagian sumber data Indonesia
  /// mengirim `79,3` alih-alih `79.3`.
  static double toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return 0.0;

    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
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
