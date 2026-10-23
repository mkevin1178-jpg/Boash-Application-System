/// Mata kuliah yang diambil mahasiswa pada semester berjalan.
class Course {
  const Course({
    required this.code,
    required this.name,
    required this.lecturer,
    required this.credits,
    required this.room,
    this.lecturerTitle = '',
  });

  /// Kode mata kuliah, mis. "MK-01".
  final String code;
  final String name;
  final String lecturer;
  final String lecturerTitle;
  final int credits;
  final String room;

  /// Nama ringkas untuk tampilan sempit.
  String get shortName => name.length > 24 ? '${name.substring(0, 22)}…' : name;
}
