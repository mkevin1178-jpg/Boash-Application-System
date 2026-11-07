import '../features/mahasiswa/data/models/mahasiswa_model.dart';

/// Data mahasiswa yang sedang login.
///
/// Identitas utama (NPM, nama, email, kode prodi, tahun masuk, foto)
/// diambil dari endpoint `/mahasiswa`. Field yang tidak tersedia di API
/// (fakultas, semester berjalan, masa berlaku KTM) masih memakai nilai demo
/// dan diberi label "demo" agar tidak disalahartikan sebagai data resmi.
class AppSession {
  const AppSession({
    required this.npm,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.faculty,
    required this.programStudi,
    required this.phone,
    required this.semester,
    required this.academicYear,
    required this.validUntil,
  });

  /// Membuat sesi dari profil `/mahasiswa`.
  factory AppSession.fromMahasiswa(Mahasiswa mahasiswa) {
    return AppSession(
      npm: mahasiswa.npm.trim(),
      fullName: mahasiswa.nama.trim(),
      email: mahasiswa.email,
      photoUrl: _photoUrl(mahasiswa.foto),
      faculty: demoFaculty,
      programStudi: mahasiswa.kdProgstudi.isNotEmpty
          ? mahasiswa.kdProgstudi
          : demoProgramStudi,
      phone: mahasiswa.handphone,
      semester: demoSemester,
      academicYear: mahasiswa.tahunMasuk.isNotEmpty
          ? mahasiswa.tahunMasuk
          : demoAcademicYear,
      validUntil: demoValidUntil,
    );
  }

  // ---------------------------------------------------------------- default
  // Nilai di bawah hanya dipakai untuk field yang memang tidak disediakan
  // endpoint `/mahasiswa`. Semuanya diberi label demo di UI.
  static const String demoFaculty = 'Fakultas Teknologi Sains dan Informasi';
  static const String demoProgramStudi = 'Program Studi (demo)';
  static const String demoSemester = '5 (Ganjil) (demo)';
  static const String demoAcademicYear = '2026/2027 (demo)';
  static const String demoValidUntil = '30 Jun 2027 (demo)';

  /// NPM yang dipakai login — digunakan sebagai query parameter ke API.
  final String npm;

  /// Nama lengkap mahasiswa dari `/mahasiswa` (sudah di-trim).
  final String fullName;
  final String email;

  /// URL foto profil — kosong bila API hanya mengirim nama file.
  final String photoUrl;
  final String faculty;
  final String programStudi;
  final String phone;
  final String semester;
  final String academicYear;
  final String validUntil;

  /// Alias `nim` → `npm` untuk kompatibilitas layar yang masih memakai `.nim`.
  String get nim => npm;

  /// Nama depan untuk sapaan di dashboard.
  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Mahasiswa';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Inisial untuk avatar cadangan, mis. "SA".
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// API `/mahasiswa` mengirim `foto` sebagai nama file, bukan URL penuh.
  /// Hanya terima nilai yang benar-benar URL agar avatar tidak mencoba
  /// memuat path relatif.
  static String _photoUrl(String foto) {
    final trimmed = foto.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '';
  }
}
