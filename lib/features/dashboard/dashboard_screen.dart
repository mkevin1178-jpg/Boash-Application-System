import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/announcement.dart';
import '../../models/assignment.dart';
import '../../models/class_session.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/menu_icon_tile.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/section_title.dart';
import '../../widgets/status_badge.dart';
import '../academic/academic_screen.dart';
import '../academic/assignment_detail_screen.dart';
import '../announcements/announcement_detail_screen.dart';
import '../announcements/announcements_screen.dart';
import '../schedule/schedule_screen.dart';

/// Data ringkasan yang dipakai dashboard.
class DashboardData {
  const DashboardData({
    required this.todaySessions,
    required this.upcomingAssignments,
    required this.announcements,
  });

  final List<ClassSession> todaySessions;
  final List<Assignment> upcomingAssignments;
  final List<Announcement> announcements;

  bool get isEmpty =>
      todaySessions.isEmpty &&
      upcomingAssignments.isEmpty &&
      announcements.isEmpty;
}

/// Halaman Beranda - pusat aktivitas mahasiswa.
///
/// Urutan konten: sapaan, jadwal hari ini, tugas terdekat, pengumuman
/// terbaru, lalu akses cepat ke fitur akademik.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AsyncController<DashboardData> _dataController;

  @override
  void initState() {
    super.initState();
    _dataController = AsyncController<DashboardData>(_loadDashboard);
    _dataController.load();
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  Future<DashboardData> _loadDashboard() async {
    final now = DateTime.now();
    final schedule = await widget.repository.fetchSchedule();
    final assignments = await widget.repository.fetchAssignments();
    final announcements = await widget.repository.fetchAnnouncements();

    final today = schedule
        .where((session) => session.weekday == now.weekday)
        .toList(growable: false);

    final upcoming =
        assignments
            .where(
              (assignment) => assignment.status != AssignmentStatus.dikumpulkan,
            )
            .toList(growable: false)
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    final latest = announcements.toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));

    return DashboardData(
      todaySessions: today,
      upcomingAssignments: upcoming,
      announcements: latest,
    );
  }

  void _openSchedule() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScheduleScreen(
          controller: widget.controller,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _openAnnouncements() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementsScreen(
          controller: widget.controller,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _openAcademic() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AcademicScreen(
          controller: widget.controller,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _dataController.load(force: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.pageBottom),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildHeader(
                session?.fullName ?? 'Mahasiswa',
                session?.initials ?? 'M',
              ),
              AsyncBuilder<DashboardData>(
                controller: _dataController,
                loadingMessage: 'Memuat ringkasan aktivitas...',
                builder: (context, data) => _buildBody(context, data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String fullName, String initials) {
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
        ? 'Selamat siang'
        : hour < 18
        ? 'Selamat sore'
        : 'Selamat malam';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${widget.controller.session?.firstName ?? fullName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Program Studi Multimedia - Semester 5',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onPrimarySoft,
                  ),
                ),
                const SizedBox(height: 10),
                const DemoNote(
                  text: 'Data simulasi - bukan data kampus resmi',
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ProfileAvatar(
            photoUrl: widget.controller.session?.photoUrl ?? '',
            initials: initials,
            radius: 26,
            borderColor: AppColors.onPrimary,
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardData data) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.xl,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: SectionTitle(
            title: 'Jadwal Hari Ini',
            subtitle: DateFormat.longDate(now),
            actionLabel: 'Lihat semua',
            onAction: _openSchedule,
          ),
        ),
        if (data.todaySessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: AppCard(
              child: Row(
                children: [
                  Icon(
                    Icons.beach_access_outlined,
                    size: 22,
                    color: AppColors.iconNavy,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Tidak ada jadwal kuliah hari ini. Nikmati hari Anda.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.todaySessions.map(
            (session) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                0,
                AppSpacing.pageH,
                AppSpacing.md,
              ),
              child: _SessionCard(session: session, isFirst: true),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.lg,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: SectionTitle(
            title: 'Tugas Terdekat',
            actionLabel: 'Semua tugas',
            onAction: _openAcademic,
          ),
        ),
        if (data.upcomingAssignments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: AppCard(
              child: Row(
                children: [
                  Icon(Icons.task_alt, size: 22, color: AppColors.iconNavy),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Tidak ada tugas yang menunggu. Semua tugas '
                      'terkumpul.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.upcomingAssignments
              .take(3)
              .map(
                (assignment) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    0,
                    AppSpacing.pageH,
                    AppSpacing.md,
                  ),
                  child: _AssignmentRow(assignment: assignment),
                ),
              ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.lg,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: SectionTitle(
            title: 'Pengumuman Terbaru',
            actionLabel: 'Semua',
            onAction: _openAnnouncements,
          ),
        ),
        if (data.announcements.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: AppCard(
              child: Text(
                'Belum ada pengumuman baru.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...data.announcements
              .take(3)
              .map(
                (announcement) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    0,
                    AppSpacing.pageH,
                    AppSpacing.md,
                  ),
                  child: _AnnouncementRow(
                    announcement: announcement,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AnnouncementDetailScreen(
                          announcement: announcement,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.lg,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: const SectionTitle(
            title: 'Akses Cepat',
            subtitle: 'Fitur akademik yang sering digunakan',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            0,
            AppSpacing.pageH,
            AppSpacing.xl,
          ),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.82,
            children: [
              MenuIconTile(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                onTap: _openSchedule,
              ),
              MenuIconTile(
                icon: Icons.school_outlined,
                label: 'Akademik',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.menu_book_outlined,
                label: 'Materi',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.assignment_outlined,
                label: 'Tugas',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.bar_chart_outlined,
                label: 'Nilai',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.fact_check_outlined,
                label: 'Presensi',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.badge_outlined,
                label: 'KTM',
                onTap: _openAcademic,
              ),
              MenuIconTile(
                icon: Icons.campaign_outlined,
                label: 'Pengumuman',
                onTap: _openAnnouncements,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu satu sesi kuliah pada dashboard.
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, this.isFirst = false});

  final ClassSession session;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Column(
              children: [
                Text(
                  session.timeRange.split(' ').first,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.timeRange.split(' ').last,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.courseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _meta(Icons.place_outlined, session.room),
                const SizedBox(height: 4),
                _meta(Icons.person_outline, session.lecturer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Baris tugas dengan badge tenggat.
class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final deadlineLabel = DateFormat.relativeDeadline(assignment.deadline);
    final isUrgent =
        assignment.deadline.difference(DateTime.now()).inHours < 48;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AssignmentDetailScreen(assignment: assignment),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 20,
              color: AppColors.iconNavy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.courseName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusBadge(
                  label: deadlineLabel,
                  color: isUrgent ? AppColors.danger : AppColors.warning,
                  background: isUrgent
                      ? AppColors.dangerBg
                      : AppColors.warningBg,
                  icon: Icons.schedule,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris pengumuman pada dashboard.
class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_outlined,
              size: 20,
              color: AppColors.iconNavy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(
                      label: announcement.category.label,
                      color: AppColors.info,
                      background: AppColors.infoBg,
                      dense: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      DateFormat.shortDate(announcement.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  announcement.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
