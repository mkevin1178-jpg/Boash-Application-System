import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/assignment.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'assignment_detail_screen.dart';

/// Halaman daftar tugas perkuliahan.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late final AsyncController<List<Assignment>> _assignmentsController;

  /// Filter status yang sedang aktif (null = semua).
  AssignmentStatus? _filter;

  @override
  void initState() {
    super.initState();
    _assignmentsController = AsyncController<List<Assignment>>(
      widget.repository.fetchAssignments,
    );
    _assignmentsController.load();
  }

  @override
  void dispose() {
    _assignmentsController.dispose();
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
              title: 'Tugas',
              subtitle: 'Daftar tugas dan status pengerjaan',
            ),
            Expanded(
              child: AsyncBuilder<List<Assignment>>(
                controller: _assignmentsController,
                loadingMessage: 'Memuat daftar tugas...',
                builder: (context, assignments) {
                  final filtered = _filter == null
                      ? assignments
                      : assignments
                            .where((item) => item.status == _filter)
                            .toList(growable: false);

                  return RefreshIndicator(
                    onRefresh: () => _assignmentsController.load(force: true),
                    child: ListView(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.pageBottom,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildFilters(assignments),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageH,
                            AppSpacing.md,
                            AppSpacing.pageH,
                            AppSpacing.md,
                          ),
                          child: DemoNote(
                            text:
                                'Tugas dan tenggat di bawah adalah data '
                                'contoh untuk prototipe PBL.',
                            compact: true,
                          ),
                        ),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageH,
                            ),
                            child: AppCard(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: 30,
                                    color: AppColors.iconNavy,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Tidak ada tugas pada filter ini',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pilih status lain untuk melihat '
                                    'tugas yang tersedia.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (assignment) => Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pageH,
                                0,
                                AppSpacing.pageH,
                                AppSpacing.md,
                              ),
                              child: _AssignmentCard(
                                assignment: assignment,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AssignmentDetailScreen(
                                      assignment: assignment,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<Assignment> assignments) {
    final counts = {
      for (final status in AssignmentStatus.values)
        status: assignments.where((item) => item.status == status).length,
    };

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          0,
        ),
        children: [
          _chip('Semua', null, assignments.length),
          for (final status in AssignmentStatus.values)
            _chip(status.label, status, counts[status] ?? 0),
        ],
      ),
    );
  }

  Widget _chip(String label, AssignmentStatus? status, int count) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = status),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.onPrimary : AppColors.textPrimary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          side: BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}

/// Kartu tugas pada daftar.
class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment, required this.onTap});

  final Assignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deadline = DateFormat.relativeDeadline(assignment.deadline);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: assignment.status.label,
                color: _statusColor(assignment.status),
                background: _statusBackground(assignment.status),
                icon: _statusIcon(assignment.status),
                dense: true,
              ),
              const Spacer(),
              Text(
                deadline,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: assignment.isOverdue
                      ? AppColors.danger
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            assignment.title,
            style: const TextStyle(
              fontSize: 15,
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
          Text(
            assignment.description,
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
    );
  }

  static Color _statusColor(AssignmentStatus status) => switch (status) {
    AssignmentStatus.belumDikerjakan => AppColors.danger,
    AssignmentStatus.dikerjakan => AppColors.warning,
    AssignmentStatus.dikumpulkan => AppColors.success,
  };

  static Color _statusBackground(AssignmentStatus status) => switch (status) {
    AssignmentStatus.belumDikerjakan => AppColors.dangerBg,
    AssignmentStatus.dikerjakan => AppColors.warningBg,
    AssignmentStatus.dikumpulkan => AppColors.successBg,
  };

  static IconData _statusIcon(AssignmentStatus status) => switch (status) {
    AssignmentStatus.belumDikerjakan => Icons.radio_button_unchecked,
    AssignmentStatus.dikerjakan => Icons.edit_note,
    AssignmentStatus.dikumpulkan => Icons.check_circle_outline,
  };
}
