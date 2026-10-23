/// Kategori pengumuman kampus.
enum AnnouncementCategory {
  akademik,
  kampus,
  acara,
  beasiswa;

  String get label => switch (this) {
    AnnouncementCategory.akademik => 'Akademik',
    AnnouncementCategory.kampus => 'Kampus',
    AnnouncementCategory.acara => 'Acara',
    AnnouncementCategory.beasiswa => 'Beasiswa',
  };
}

/// Pengumuman kampus beserta detail isinya.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    required this.body,
    this.isRead = false,
    this.author = 'Panitia Kampus',
  });

  final String id;
  final String title;
  final AnnouncementCategory category;
  final DateTime date;
  final String summary;
  final String body;

  /// Penanda pengumuman belum dibaca.
  final bool isRead;
  final String author;

  Announcement copyWith({bool? isRead}) => Announcement(
    id: id,
    title: title,
    category: category,
    date: date,
    summary: summary,
    body: body,
    isRead: isRead ?? this.isRead,
    author: author,
  );
}
