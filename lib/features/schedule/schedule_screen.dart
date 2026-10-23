import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/class_session.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/page_header.dart';
import '../../widgets/section_title.dart';

/// Halaman Jadwal - tampilan harian dan mingguan.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final AsyncController<List<ClassSession>> _scheduleController;

  /// 0 = harian, 1 = mingguan.
  int _viewIndex = 0;

  /// Hari yang dipilih pada tampilan harian (1 = Senin ... 7 = Minggu).
  late int _selectedWeekday = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _scheduleController = AsyncController<List<ClassSession>>(
      widget.repository.fetchSchedule,
    );
    _scheduleController.load();
  }

  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(
              title: 'Jadwal',
              subtitle: 'Jadwal kuliah harian dan mingguan',
            ),
            Expanded(
              child: AsyncBuilder<List<ClassSession>>(
                controller: _scheduleController,
                loadingMessage: 'Memuat jadwal...',
                isEmpty: (data) => data.isEmpty,
                emptyTitle: 'Jadwal belum tersedia',
                emptyMessage:
                    'Belum ada sesi kuliah yang terdaftar untuk semester ini.',
                emptyIcon: Icons.calendar_month_outlined,
                builder: (context, sessions) => RefreshIndicator(
                  onRefresh: () => _scheduleController.load(force: true),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.pageBottom,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildViewSwitch(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.pageH,
                          AppSpacing.lg,
                          AppSpacing.pageH,
                          0,
                        ),
                        child: DemoNote(
                          text: 'Jadwal contoh - simulasi semester berjalan',
                          compact: true,
                        ),
                      ),
                      if (_viewIndex == 0)
                        _buildDayPicker()
                      else
                        const SizedBox(height: AppSpacing.md),
                      ..._buildContent(sessions),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSwitch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            _segment(0, 'Harian', Icons.today_outlined),
            _segment(1, 'Mingguan', Icons.calendar_view_week_outlined),
          ],
        ),
      ),
    );
  }

  Widget _segment(int index, String label, IconData icon) {
    final selected = _viewIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _viewIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final today = DateTime.now().weekday;

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          0,
        ),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final weekday = index + 1;
          final selected = weekday == _selectedWeekday;
          final isToday = weekday == today;

          return Semantics(
            button: true,
            selected: selected,
            label: '${days[index]}${isToday ? ', hari ini' : ''}',
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              onTap: () => setState(() => _selectedWeekday = weekday),
              child: Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : isToday
                        ? AppColors.primary
                        : AppColors.divider,
                    width: isToday && !selected ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isToday ? 'Hari ini' : ' ',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.onPrimarySoft
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(List<ClassSession> sessions) {
    if (_viewIndex == 0) {
      final daily = sessions
          .where((session) => session.weekday == _selectedWeekday)
          .toList(growable: false);

      if (daily.isEmpty) {
        return [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: _NoSchedule(),
          ),
        ];
      }

      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.xl,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: SectionTitle(
            title: DateFormat.dayLong(
              DateTime.now().subtract(
                Duration(days: DateTime.now().weekday - _selectedWeekday),
              ),
            ),
            subtitle: '${daily.length} sesi perkuliahan',
          ),
        ),
        ...daily.map(
          (session) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              0,
              AppSpacing.pageH,
              AppSpacing.md,
            ),
            child: _SessionCard(
              session: session,
              onTap: () => _showSessionDetail(session),
            ),
          ),
        ),
      ];
    }

    final grouped = <int, List<ClassSession>>{};
    for (final session in sessions) {
      grouped.putIfAbsent(session.weekday, () => []).add(session);
    }

    final widgets = <Widget>[];
    for (final weekday in grouped.keys.toList()..sort()) {
      final daySessions = grouped[weekday]!;
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.lg,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: SectionTitle(
            title: DateFormat.dayLong(
              DateTime.now().subtract(
                Duration(days: DateTime.now().weekday - weekday),
              ),
            ),
            subtitle: '${daySessions.length} sesi',
          ),
        ),
      );
      widgets.addAll(
        daySessions.map(
          (session) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              0,
              AppSpacing.pageH,
              AppSpacing.md,
            ),
            child: _SessionCard(
              session: session,
              onTap: () => _showSessionDetail(session),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Future<void> _showSessionDetail(ClassSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SessionDetailSheet(session: session),
    );
  }
}

/// Kartu sesi kuliah pada halaman jadwal.
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final ClassSession session;
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Text(
              session.timeRange,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
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
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
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

/// Empty state untuk hari tanpa jadwal.
class _NoSchedule extends StatelessWidget {
  const _NoSchedule();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(
            Icons.beach_access_outlined,
            size: 30,
            color: AppColors.iconNavy,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tidak ada jadwal pada hari ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih hari lain pada penyaring di atas untuk melihat '
            'jadwal mingguan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail kelas dalam bottom sheet.
class _SessionDetailSheet extends StatelessWidget {
  const _SessionDetailSheet({required this.session});

  final ClassSession session;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              session.courseName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _row(
              Icons.calendar_today_outlined,
              'Hari',
              DateFormat.dayLong(session.start),
            ),
            _row(Icons.schedule, 'Jam', session.timeRange),
            _row(Icons.place_outlined, 'Ruangan', session.room),
            _row(Icons.person_outline, 'Dosen', session.lecturer),
            _row(
              Icons.confirmation_number_outlined,
              'Kode',
              session.courseCode,
            ),
            const SizedBox(height: AppSpacing.md),
            const DemoNotice(
              text: 'Detail kelas merupakan data contoh untuk prototipe PBL.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.iconNavy),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
