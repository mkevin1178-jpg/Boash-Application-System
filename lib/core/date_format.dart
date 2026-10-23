/// Format tanggal & waktu dalam bahasa Indonesia.
class DateFormat {
  const DateFormat._();

  static const List<String> _dayLong = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _dayShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _monthLong = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// "Kamis, 22 Oktober 2026"
  static String longDate(DateTime date) =>
      '${dayLong(date)}, ${date.day} ${monthLong(date.month - 1)} ${date.year}';

  /// "22 Okt 2026"
  static String shortDate(DateTime date) =>
      '${date.day} ${monthShort(date.month - 1)} ${date.year}';

  /// "Sen"
  static String shortDay(DateTime date) => _dayShort[date.weekday - 1];

  /// "Senin"
  static String dayLong(DateTime date) => _dayLong[date.weekday - 1];

  /// "Januari" (index 0 = Januari).
  static String monthLong(int index) => _monthLong[index];

  /// "Jan" (index 0 = Januari).
  static String monthShort(int index) => _monthShort[index];

  /// "08:00"
  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// "Sen, 22 Okt 2026 · 08:00 – 10:00"
  static String dayAndTime(DateTime date, DateTime end) =>
      '${shortDay(date)}, ${shortDate(date)} · '
      '${time(date)} – ${time(end)}';

  /// Deskripsi relatif tenggat: "Hari ini 23:59", "Besok 08:00",
  /// "3 hari lagi", "Lewat 2 hari".
  static String relativeDeadline(DateTime deadline, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) return 'Lewat ${-diffDays} hari';
    if (diffDays == 0) return 'Hari ini ${time(deadline)}';
    if (diffDays == 1) return 'Besok ${time(deadline)}';
    return '$diffDays hari lagi';
  }
}
