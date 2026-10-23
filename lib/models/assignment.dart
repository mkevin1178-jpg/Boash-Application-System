/// Status pengerjaan sebuah tugas.
enum AssignmentStatus {
  belumDikerjakan,
  dikerjakan,
  dikumpulkan;

  /// Label yang ditampilkan ke pengguna (selalu berupa teks, bukan warna).
  String get label => switch (this) {
    AssignmentStatus.belumDikerjakan => 'Belum dikerjakan',
    AssignmentStatus.dikerjakan => 'Dikerjakan',
    AssignmentStatus.dikumpulkan => 'Dikumpulkan',
  };
}

/// Tugas perkuliahan beserta status pengerjaannya.
class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.description,
    required this.deadline,
    required this.status,
    this.attachments = const [],
    this.submittedAt,
  });

  final String id;
  final String title;
  final String courseCode;
  final String courseName;
  final String description;
  final DateTime deadline;
  final AssignmentStatus status;

  /// Nama file pendukung contoh (isi file tidak tersedia di prototipe).
  final List<String> attachments;

  /// Waktu pengumpulan bila status sudah [AssignmentStatus.dikumpulkan].
  final DateTime? submittedAt;

  bool get isOverdue => DateTime.now().isAfter(deadline);

  Assignment copyWith({AssignmentStatus? status, DateTime? submittedAt}) {
    return Assignment(
      id: id,
      title: title,
      courseCode: courseCode,
      courseName: courseName,
      description: description,
      deadline: deadline,
      status: status ?? this.status,
      attachments: attachments,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
