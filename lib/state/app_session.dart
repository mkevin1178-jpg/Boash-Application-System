/// Data mahasiswa yang sedang login.
///
/// Diisi dari NPM yang dipakai login, dilengkapi data kampus demo.
/// **Seluruh isinya adalah simulasi** — tidak ada koneksi ke SIAKAD.
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

  /// Buat sesi dari NPM yang dipakai login.
  ///
  /// NPM disimpan langsung dari input pengguna.
  /// Field profil lain menggunakan data kampus demo karena
  /// tidak ada endpoint profil yang diverifikasi.
  factory AppSession.fromNpm(String npm) {
    return AppSession(
      npm: npm.trim(),
      fullName: demoFullName,
      email: '${demoProgramStudi.toLowerCase().replaceAll(' ', '')}.'
          '${npm.trim()}'
          '@student.nusantara.ac.id',
      photoUrl: '',
      faculty: demoFaculty,
      programStudi: demoProgramStudi,
      phone: demoPhone,
      semester: demoSemester,
      academicYear: demoAcademicYear,
      validUntil: demoValidUntil,
    );
  }

  // ---------------------------------------------------------------- default
  static const String demoFullName = 'Mahasiswa Demo';
  static const String demoFaculty = 'Fakultas Teknik';
  static const String demoProgramStudi = 'Multimedia';
  static const String demoPhone = '+62 812 3456 7890';
  static const String demoSemester = '5 (Ganjil)';
  static const String demoAcademicYear = '2026/2027';
  static const String demoValidUntil = '30 Jun 2027';

  /// NPM yang dipakai login — digunakan sebagai query parameter ke API nilai.
  final String npm;

  /// Nama lengkap mahasiswa (demo).
  final String fullName;
  final String email;

  /// URL foto profil — kosong bila tidak tersedia.
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

  /// Inisial untuk avatar cadangan, mis. "MD".
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
