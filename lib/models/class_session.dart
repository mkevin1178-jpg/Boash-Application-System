/// Satu sesi perkuliahan pada jadwal mingguan.
class ClassSession {
  const ClassSession({
    required this.courseCode,
    required this.courseName,
    required this.lecturer,
    required this.room,
    required this.start,
    required this.end,
    required this.weekday,
  });

  /// Kode mata kuliah, untuk mencocokkan dengan [Course].
  final String courseCode;
  final String courseName;
  final String lecturer;
  final String room;
  final DateTime start;
  final DateTime end;

  /// 1 = Senin … 7 = Minggu (mengikuti [DateTime.weekday]).
  final int weekday;

  /// Rentang jam tampil, mis. "08:00 – 10:00".
  String get timeRange => '${_hh(start)} – ${_hh(end)}';

  static String _hh(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ClassSession &&
      other.courseCode == courseCode &&
      other.start == start;

  @override
  int get hashCode => Object.hash(courseCode, start);
}
