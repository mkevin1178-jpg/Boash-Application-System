/// Data mahasiswa demo yang sedang login.
///
/// Diisi dari profil contoh randomuser.me dan dilengkapi data kampus
/// contoh. **Seluruh isinya adalah simulasi.**
class AppSession {
  const AppSession({
    required this.fullName,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.nim,
    required this.faculty,
    required this.programStudi,
    required this.phone,
    required this.semester,
    required this.academicYear,
    required this.validUntil,
  });

  /// Profil contoh dari API randomuser.me.
  factory AppSession.fromApiUser(Map<String, dynamic> user) {
    final name = user['name'] as Map<String, dynamic>? ?? const {};
    final login = user['login'] as Map<String, dynamic>? ?? const {};
    final picture = user['picture'] as Map<String, dynamic>? ?? const {};

    final first = _capitalize('${name['first'] ?? ''}'.trim());
    final last = _capitalize('${name['last'] ?? ''}'.trim());
    final full = '$first $last'.trim();

    return AppSession(
      fullName: full.isEmpty ? 'Mahasiswa Demo' : full,
      username: '${login['username'] ?? ''}'.trim(),
      email: '${user['email'] ?? ''}'.trim(),
      photoUrl: '${picture['large'] ?? ''}'.trim(),
      nim: demoNim,
      faculty: demoFaculty,
      programStudi: demoProgramStudi,
      phone: demoPhone,
      semester: demoSemester,
      academicYear: demoAcademicYear,
      validUntil: demoValidUntil,
    );
  }

  static const String demoNim = '20240001';
  static const String demoFaculty = 'Fakultas Teknik';
  static const String demoProgramStudi = 'Multimedia';
  static const String demoPhone = '+62 812 3456 7890';
  static const String demoSemester = '5 (Ganjil)';
  static const String demoAcademicYear = '2026/2027';
  static const String demoValidUntil = '30 Jun 2027';

  final String fullName;
  final String username;
  final String email;
  final String photoUrl;
  final String nim;
  final String faculty;
  final String programStudi;
  final String phone;
  final String semester;
  final String academicYear;
  final String validUntil;

  /// Nama depan untuk sapaan di dashboard.
  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Student';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Inisial untuk avatar cadangan, mis. "AJ".
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
