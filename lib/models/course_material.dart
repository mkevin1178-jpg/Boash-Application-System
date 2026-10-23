/// Materi perkuliahan yang dapat dibuka/diunduh (versi demo).
class CourseMaterial {
  const CourseMaterial({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.type,
    required this.updatedAt,
    required this.sizeLabel,
    this.description = '',
  });

  final String id;
  final String title;
  final String courseCode;
  final String courseName;

  /// Jenis berkas contoh: "PDF", "PPT", "DOC", "Video".
  final String type;
  final DateTime updatedAt;

  /// Ukuran berkas contoh, mis. "2,4 MB".
  final String sizeLabel;
  final String description;
}
