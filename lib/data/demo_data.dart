import '../models/announcement.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/class_session.dart';
import '../models/course.dart';
import '../models/course_material.dart';
import '../models/grade.dart';

/// **Satu-satunya sumber data demo** aplikasi.
///
/// Seluruh layar (dashboard, jadwal, tugas, nilai, presensi, pengumuman)
/// membaca dari kelas ini agar nama mata kuliah, jadwal, dan tugas tidak
/// saling bertentangan (REVISI bagian "Kualitas dan pengujian").
///
/// Semua isi adalah **data contoh** - bukan data mahasiswa atau kampus
/// sungguhan.
class DemoData {
  const DemoData._();

  // ------------------------------------------------------------- identitas
  static const String universityName = 'Universitas Nusantara';
  static const String faculty = 'Fakultas Teknik';
  static const String programStudi = 'Multimedia';
  static const String nim = '20240001';
  static const String semester = '5';
  static const String academicYear = '2026/2027';
  static const String validUntil = '30 Jun 2027';

  // ------------------------------------------------------------ mata kuliah
  static const List<Course> courses = [
    Course(
      code: 'MK-01',
      name: 'Pemrograman Mobile',
      lecturer: 'Dr. Rina Kusuma',
      lecturerTitle: 'S.T., M.T.',
      credits: 3,
      room: 'Lab Multimedia 1',
    ),
    Course(
      code: 'MK-02',
      name: 'Basis Data',
      lecturer: 'Bagus Santoso',
      lecturerTitle: 'M.Kom.',
      credits: 3,
      room: 'Ruang D2.3',
    ),
    Course(
      code: 'MK-03',
      name: 'Jaringan Komputer',
      lecturer: 'Siti Aminah',
      lecturerTitle: 'S.T., M.T.',
      credits: 3,
      room: 'Ruang D2.1',
    ),
    Course(
      code: 'MK-04',
      name: 'Pemrograman Web',
      lecturer: 'Andi Pratama',
      lecturerTitle: 'M.Kom.',
      credits: 3,
      room: 'Lab Multimedia 2',
    ),
    Course(
      code: 'MK-05',
      name: 'Multimedia',
      lecturer: 'Dewi Lestari',
      lecturerTitle: 'M.Sn.',
      credits: 3,
      room: 'Studio Audio',
    ),
    Course(
      code: 'MK-06',
      name: 'Statistika',
      lecturer: 'Fajar Nugroho',
      lecturerTitle: 'M.Stat.',
      credits: 2,
      room: 'Ruang D2.4',
    ),
    Course(
      code: 'MK-07',
      name: 'Kecerdasan Buatan',
      lecturer: 'Nadia Puspita',
      lecturerTitle: 'S.Kom., M.Cs.',
      credits: 3,
      room: 'Lab Multimedia 3',
    ),
    Course(
      code: 'MK-08',
      name: 'Keamanan Siber',
      lecturer: 'Yoga Saputra',
      lecturerTitle: 'S.Kom.',
      credits: 3,
      room: 'Ruang D2.2',
    ),
  ];

  /// Total SKS yang diambil semester ini (dipakai pada halaman profil).
  static int get totalCredits =>
      courses.fold(0, (sum, course) => sum + course.credits);

  // ----------------------------------------------------------------- jadwal
  /// Jadwal mingguan. Jam selalu menggunakan hari Senin sebagai acuan
  /// sehingga urutan data stabil.
  static List<ClassSession> buildSchedule() {
    ClassSession session(
      String code,
      int weekday,
      int startHour,
      int startMinute,
      int endHour,
      int endMinute,
    ) {
      final course = courses.firstWhere((c) => c.code == code);
      return ClassSession(
        courseCode: course.code,
        courseName: course.name,
        lecturer: course.lecturer,
        room: course.room,
        start: DateTime(2026, 1, 5 + (weekday - 1), startHour, startMinute),
        end: DateTime(2026, 1, 5 + (weekday - 1), endHour, endMinute),
        weekday: weekday,
      );
    }

    return [
      session('MK-01', DateTime.monday, 8, 0, 10, 0),
      session('MK-02', DateTime.monday, 10, 15, 12, 15),
      session('MK-03', DateTime.tuesday, 8, 0, 10, 0),
      session('MK-04', DateTime.tuesday, 13, 0, 15, 0),
      session('MK-05', DateTime.wednesday, 8, 0, 10, 0),
      session('MK-06', DateTime.wednesday, 10, 15, 12, 15),
      session('MK-07', DateTime.thursday, 8, 0, 10, 0),
      session('MK-08', DateTime.friday, 8, 0, 10, 0),
    ];
  }

  // ------------------------------------------------------------------ tugas
  static List<Assignment> buildAssignments(DateTime now) {
    DateTime deadline(int days, int hour) =>
        DateTime(now.year, now.month, now.day + days, hour);

    return [
      Assignment(
        id: 'T-01',
        title: 'Prototype Aplikasi Mobile',
        courseCode: 'MK-01',
        courseName: 'Pemrograman Mobile',
        description:
            'Buat prototype aplikasi mobile sederhana yang menampilkan '
            'daftar jadwal kuliah. Sertakan rancangan layar dan catatan '
            'implementasi state pada tugas ini.',
        deadline: deadline(0, 23),
        status: AssignmentStatus.dikerjakan,
        attachments: const ['prototype_aplikasi.pdf', 'mockup_layar.png'],
      ),
      Assignment(
        id: 'T-02',
        title: 'Laporan Praktikum Basis Data',
        courseCode: 'MK-02',
        courseName: 'Basis Data',
        description:
            'Susun laporan praktikum SQL: rancangan basis data, query yang '
            'digunakan, analisis hasil, dan kesimpulan. Batas 6 halaman.',
        deadline: deadline(2, 21),
        status: AssignmentStatus.belumDikerjakan,
        attachments: const ['format_laporan.docx'],
      ),
      Assignment(
        id: 'T-03',
        title: 'Analisis Topologi Jaringan LAN',
        courseCode: 'MK-03',
        courseName: 'Jaringan Komputer',
        description:
            'Analisis topologi jaringan LAN untuk gedung perkuliahan: '
            'tentukan perangkat, segmentasi VLAN, dan estimasi kebutuhan '
            'bandwidth.',
        deadline: deadline(4, 17),
        status: AssignmentStatus.belumDikerjakan,
        attachments: const [],
      ),
      Assignment(
        id: 'T-04',
        title: 'Uji Validasi Data Survei',
        courseCode: 'MK-06',
        courseName: 'Statistika',
        description:
            'Lakukan uji validitas dan reliabilitas kuesioner kecil, lalu '
            'interpretasikan hasilnya. Gunakan data simulasi yang '
            'disertakan.',
        deadline: deadline(6, 12),
        status: AssignmentStatus.belumDikerjakan,
        attachments: const ['data_survei.xlsx'],
      ),
      Assignment(
        id: 'T-05',
        title: 'Poster Eksplorasi Video 4K',
        courseCode: 'MK-05',
        courseName: 'Multimedia',
        description:
            'Buat poster eksplorasi konsep video 4K beserta contoh '
            'footage dan referensi teknis. Kumpulkan dalam format A3.',
        deadline: deadline(-2, 23),
        status: AssignmentStatus.dikumpulkan,
        attachments: const ['poster_video_4k.pdf'],
        submittedAt: deadline(-3, 19),
      ),
      Assignment(
        id: 'T-06',
        title: 'Review Keamanan Kata Sandi',
        courseCode: 'MK-08',
        courseName: 'Keamanan Siber',
        description:
            'Ulas kebijakan kata sandi dan praktik thereof. Implementasikan '
            'rekomendasi pada skenario organisasi kecil.',
        deadline: deadline(9, 21),
        status: AssignmentStatus.belumDikerjakan,
        attachments: const [],
      ),
    ];
  }

  // ---------------------------------------------------------------- materi
  static List<CourseMaterial> buildMaterials(DateTime now) {
    DateTime updated(int daysAgo) => now.subtract(Duration(days: daysAgo));

    return [
      CourseMaterial(
        id: 'M-01',
        title: 'Modul 1 - Arsitektur Aplikasi Mobile',
        courseCode: 'MK-01',
        courseName: 'Pemrograman Mobile',
        type: 'PDF',
        updatedAt: updated(2),
        sizeLabel: '2,4 MB',
        description: 'Materi pengantar arsitektur aplikasi mobile.',
      ),
      CourseMaterial(
        id: 'M-02',
        title: 'Slide - Widget dan Navigasi',
        courseCode: 'MK-01',
        courseName: 'Pemrograman Mobile',
        type: 'PPT',
        updatedAt: updated(5),
        sizeLabel: '6,1 MB',
        description: 'Slide materi pertemuan 3 sampai 5.',
      ),
      CourseMaterial(
        id: 'M-03',
        title: 'Referensi SQL Praktikum',
        courseCode: 'MK-02',
        courseName: 'Basis Data',
        type: 'PDF',
        updatedAt: updated(7),
        sizeLabel: '1,8 MB',
        description: 'Cheat sheet query SQL untuk praktikum.',
      ),
      CourseMaterial(
        id: 'M-04',
        title: 'Recording - Topologi Jaringan',
        courseCode: 'MK-03',
        courseName: 'Jaringan Komputer',
        type: 'Video',
        updatedAt: updated(9),
        sizeLabel: '42 MB',
        description: 'Rekaman lectured hybride.',
      ),
      CourseMaterial(
        id: 'M-05',
        title: 'Template Poster A3',
        courseCode: 'MK-05',
        courseName: 'Multimedia',
        type: 'DOC',
        updatedAt: updated(12),
        sizeLabel: '890 KB',
        description: 'Template poster untuk tugas eksplorasi.',
      ),
      CourseMaterial(
        id: 'M-06',
        title: 'Handout Uji Hipotesis',
        courseCode: 'MK-06',
        courseName: 'Statistika',
        type: 'PDF',
        updatedAt: updated(15),
        sizeLabel: '1,1 MB',
        description: 'Handout pengujian hipotesis dan interpretasinya.',
      ),
    ];
  }

  // ----------------------------------------------------------------- nilai
  static const List<Grade> grades = [
    Grade(
      courseCode: 'MK-01',
      courseName: 'Pemrograman Mobile',
      taskScore: 85,
      midTermScore: 78,
      finalScore: 88,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-02',
      courseName: 'Basis Data',
      taskScore: 90,
      midTermScore: 82,
      finalScore: 86,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-03',
      courseName: 'Jaringan Komputer',
      taskScore: 78,
      midTermScore: 75,
      finalScore: 80,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-04',
      courseName: 'Pemrograman Web',
      taskScore: 82,
      midTermScore: 84,
      finalScore: 79,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-05',
      courseName: 'Multimedia',
      taskScore: 88,
      midTermScore: 81,
      finalScore: 85,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-06',
      courseName: 'Statistika',
      taskScore: 76,
      midTermScore: 74,
      finalScore: 79,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-07',
      courseName: 'Kecerdasan Buatan',
      taskScore: 80,
      midTermScore: 77,
      finalScore: 81,
      weight: 40,
    ),
    Grade(
      courseCode: 'MK-08',
      courseName: 'Keamanan Siber',
      taskScore: 87,
      midTermScore: 85,
      finalScore: 88,
      weight: 40,
    ),
  ];

  /// Rata-rata seluruh nilai (IPK, data contoh).
  static double get gpa =>
      grades.fold(0.0, (sum, grade) => sum + grade.totalScore) / grades.length;

  // ------------------------------------------------------- DHS (Daftar Hasil Studi)
  /// Data DHS demo — dipakai sebagai fallback ketika API tidak tersedia.
  ///
  /// Format mengikuti Kartu Hasil Studi (KHS) SIAKAD Indonesia:
  /// kode MK, nama MK, SKS, nilai angka (NA), huruf mutu (HM),
  /// angka mutu (AM), dan mutu = AM × SKS.
  static const List<DhsGrade> dhsGrades = [
    DhsGrade(
      courseCode: 'MK-01',
      courseName: 'Pemrograman Mobile',
      credits: 3,
      na: 85.5,
      hm: 'A',
      am: 4.0,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-02',
      courseName: 'Basis Data',
      credits: 3,
      na: 84.8,
      hm: 'B+',
      am: 3.5,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-03',
      courseName: 'Jaringan Komputer',
      credits: 3,
      na: 77.6,
      hm: 'B',
      am: 3.0,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-04',
      courseName: 'Pemrograman Web',
      credits: 3,
      na: 81.4,
      hm: 'B+',
      am: 3.5,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-05',
      courseName: 'Multimedia',
      credits: 3,
      na: 83.7,
      hm: 'B+',
      am: 3.5,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-06',
      courseName: 'Statistika',
      credits: 2,
      na: 76.5,
      hm: 'B',
      am: 3.0,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-07',
      courseName: 'Kecerdasan Buatan',
      credits: 3,
      na: 79.8,
      hm: 'B',
      am: 3.0,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
    DhsGrade(
      courseCode: 'MK-08',
      courseName: 'Keamanan Siber',
      credits: 3,
      na: 86.2,
      hm: 'A',
      am: 4.0,
      thnAkademik: '2026/2027',
      semester: '5',
    ),
  ];

  // -------------------------------------------------------------- presensi
  static const List<AttendanceRecord> attendance = [
    AttendanceRecord(
      courseCode: 'MK-01',
      courseName: 'Pemrograman Mobile',
      totalMeeting: 14,
      attended: 13,
      sick: 1,
      permission: 0,
      missed: 0,
    ),
    AttendanceRecord(
      courseCode: 'MK-02',
      courseName: 'Basis Data',
      totalMeeting: 14,
      attended: 12,
      sick: 0,
      permission: 1,
      missed: 1,
    ),
    AttendanceRecord(
      courseCode: 'MK-03',
      courseName: 'Jaringan Komputer',
      totalMeeting: 12,
      attended: 12,
      sick: 0,
      permission: 0,
      missed: 0,
    ),
    AttendanceRecord(
      courseCode: 'MK-04',
      courseName: 'Pemrograman Web',
      totalMeeting: 12,
      attended: 10,
      sick: 1,
      permission: 0,
      missed: 1,
    ),
    AttendanceRecord(
      courseCode: 'MK-05',
      courseName: 'Multimedia',
      totalMeeting: 12,
      attended: 11,
      sick: 1,
      permission: 0,
      missed: 0,
    ),
    AttendanceRecord(
      courseCode: 'MK-06',
      courseName: 'Statistika',
      totalMeeting: 12,
      attended: 12,
      sick: 0,
      permission: 0,
      missed: 0,
    ),
    AttendanceRecord(
      courseCode: 'MK-07',
      courseName: 'Kecerdasan Buatan',
      totalMeeting: 12,
      attended: 9,
      sick: 1,
      permission: 1,
      missed: 1,
    ),
    AttendanceRecord(
      courseCode: 'MK-08',
      courseName: 'Keamanan Siber',
      totalMeeting: 12,
      attended: 12,
      sick: 0,
      permission: 0,
      missed: 0,
    ),
  ];

  // ------------------------------------------------------------ pengumuman
  static List<Announcement> buildAnnouncements(DateTime now) {
    DateTime published(int daysAgo) =>
        DateTime(now.year, now.month, now.day - daysAgo, 9);

    return [
      Announcement(
        id: 'AN-01',
        title: 'Pengisian KRS Semester 5 Telah Dibuka',
        category: AnnouncementCategory.akademik,
        date: published(1),
        summary:
            'Mahasiswa dapat mengisi Kartu Rencana Studi semester 5 melalui '
            'portal akademik sampai 30 Oktober 2026.',
        body:
            'Pengisian Kartu Rencana Studi (KRS) untuk semester ganjil '
            'tahun akademik 2026/2027 telah dibuka.\n\n'
            'Mahasiswa dapat mengisi KRS melalui portal akademik campus '
            'hingga 30 Oktober 2026 pukul 23.59 WIB. Pengisian KRS yang '
            'tidak selesai tepat waktu tidak dapat diperbaiki.\n\n'
            'Penyerahan KRS telah dijadwalkan pada minggu pertama bulan '
            'November 2026. Silakan cek jadwal pertemuan dengan dosen '
            'pembimbing.',
        author: 'Bagian Akademik',
      ),
      Announcement(
        id: 'AN-02',
        title: 'Jadwal Ujian Tengah Semester Diumumkan',
        category: AnnouncementCategory.akademik,
        date: published(3),
        summary:
            'Ujian tengah semester akan dilaksanakan pada 27 sampai 29 '
            'Oktober 2026. Detail per mata kuliah tersedia di menu Jadwal.',
        body:
            'Ujian tengah semester akan dilaksanakan pada 27 sampai 29 '
            'Oktober 2026 pukul 08.00 sampai 11.00 WIB.\n\n'
            'Mahasiswa wajib hadir 15 menit sebelum ujian dimulai dan '
            'membawa kartu tanda mahasiswa. Bagi yang berhalangan, '
            'pengajuan izin harus diajukan ke bagian akademik maksimal H-3 '
            'sebelum ujian.\n\n'
            'Rincian lokasi dan jam per mata kuliah dapat dilihat pada '
            'halaman Jadwal di aplikasi ini.',
        author: 'Bagian Akademik',
      ),
      Announcement(
        id: 'AN-03',
        title: 'Pameran Karya Multimedia 2026',
        category: AnnouncementCategory.acara,
        date: published(5),
        summary:
            'Pameran karya mahasiswa diselenggarakan pada 14 sampai 16 '
            'November 2026 di Lobby Utama. Pendaftaran peserta dibuka.',
        body:
            'Pameran Karya Multimedia 2026 diselenggarakan pada 14 sampai '
            '16 November 2026 di Lobby Utama Universitas Nusantara.\n\n'
            'Mahasiswa peserta dapat mendaftar pada sistem informasi '
            'Jurusan paling lambat 5 November 2026. Setiap peserta boleh '
            'menampilkan maksimal tiga karya.\n\n'
            'Penilaian diserahkan kepada juri dari industri dan dosen dari '
            'luar kampus.',
        author: 'Panitia Pameran',
      ),
      Announcement(
        id: 'AN-04',
        title: 'Perpustakaan Buka Jam Tambahan Mulai Oktober',
        category: AnnouncementCategory.kampus,
        date: published(8),
        summary:
            'Jam layanan perpustakaan diperpanjang hingga pukul 21.00 pada '
            'hari Senin sampai Kamis untuk mendukung mengerjakan tugas.',
        body:
            'Mulai Oktober 2026, layanan perpustakaan campus diperpanjang '
            'hingga pukul 21.00 WIB pada hari Senin sampai Kamis dan '
            'hingga 17.00 WIB pada hari Jumat dan Sabtu.\n\n'
            'Ruang baca kolektif lantai dua juga dapat dipakai untuk '
            'mengerjakan tugas kelompok dengan mengisi formulir '
            'peminjaman ruang secara online.\n\n'
            'Peminjaman buku tetap maksimal dua buku untuk masing-masing '
            'anggota.',
        author: 'Perpustakaan Universitas',
      ),
      Announcement(
        id: 'AN-05',
        title: 'Beasiswa Prestasi Semester Ganjil Dibuka',
        category: AnnouncementCategory.beasiswa,
        date: published(12),
        summary:
            'Pendaftaran Beasiswa Prestasi dibuka untuk mahasiswa semester 5 '
            'dengan IPK minimal 3,50.',
        body:
            'Pendaftaran Beasiswa Prestasi semester ganjil telah dibuka. '
            'Syarat utama adalah menjadi mahasiswa aktif semester 5 dengan '
            'IPK minimal 3,50 serta memiliki minimal satu prestasi akademik '
            'atau non-akademik tingkat universitas.\n\n'
            'Berkas pendukung berupa transkrip nilai dan sertifikat '
            'prestasi diunggah melalui portal kampus paling lambat 20 '
            'November 2026.\n\n'
            'Hasil seleksi diumumkan pada 5 Desember 2026.',
        author: 'Bagian Kemahasiswaan',
      ),
      Announcement(
        id: 'AN-06',
        title: 'Bakti Sosial Mahasiswa Semester Ini',
        category: AnnouncementCategory.kampus,
        date: published(15),
        summary:
            'Program bakti sosial akan dilaksanakan pada 28 November 2026. '
            'Pendaftaran peserta dibuka untuk seluruh mahasiswa.',
        body:
            'Program bakti sosial mahasiswa akan dilaksanakan pada Sabtu, 28 '
            'November 2026, mulai pukul 07.00 WIB.\n\n'
            'Kegiatan meliputi perbaikan taman, pembersihan saluran air, dan '
            'pendampingan belajar anak di lingkungan sekitar '
            'kampus. Mahasiswa yang memenuhi syarat akan memperoleh jam '
            'kegiatan sosial yang tercatat pada portofolio.\n\n'
            'Pendaftaran dilakukan melalui halaman Pengumuman di aplikasi '
            'ini.',
        author: 'Panitia Bakti Sosial',
      ),
    ];
  }
}
