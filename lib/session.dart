/// Menyimpan data mahasiswa yang sedang login (hasil autentikasi API).
/// Dipakai Home (sapaan), Profile, dan KTM agar datanya konsisten.
class AppSession {
  const AppSession._();

  static String nim = '20240001';
  static String fullName = 'Alex Johnson';
  static String username = 'alexjohnson';
  static String email = 'alex@student.ac.id';
  static String photoUrl = '';
  static String faculty = 'Fakultas Teknik';
  static String programStudi = 'Multimedia';
  static String phone = '+62 812 3456 7890';
  static String semester = '5 (Ganjil)';
  static String academicYear = '2026/2027';
  static String validUntil = '30 Jun 2027';

  static String get firstName =>
      fullName.trim().isEmpty ? 'Student' : fullName.trim().split(' ').first;

  /// Isi session dari respons API randomuser.me.
  static void setFromApiUser(Map<String, dynamic> user) {
    final name = user['name'] as Map<String, dynamic>? ?? const {};
    final first = _capitalize('${name['first'] ?? ''}');
    final last = _capitalize('${name['last'] ?? ''}');
    final full = '$first $last'.trim();
    if (full.isNotEmpty) fullName = full;

    final login = user['login'] as Map<String, dynamic>? ?? const {};
    final apiUsername = '${login['username'] ?? ''}';
    if (apiUsername.isNotEmpty) username = apiUsername;

    final apiEmail = '${user['email'] ?? ''}';
    if (apiEmail.isNotEmpty) email = apiEmail;

    final picture = user['picture'] as Map<String, dynamic>? ?? const {};
    photoUrl = '${picture['large'] ?? ''}';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
