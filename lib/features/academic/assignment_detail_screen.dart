import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../models/assignment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/status_badge.dart';

/// Halaman detail tugas.
///
/// Menampilkan judul, mata kuliah, deskripsi, tenggat, lampiran contoh,
/// status, dan tombol pengumpulan yang **bersifat simulasi**.
class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({super.key, required this.assignment});

  final Assignment assignment;

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  late Assignment _assignment = widget.assignment;

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kumpulkan tugas?'),
        content: const Text(
          'Pengumpulan pada versi demo hanya mengubah status secara '
          'lokal. Berkas tidak dikirim ke sistem kampus mana pun.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _assignment = _assignment.copyWith(
        status: AssignmentStatus.dikumpulkan,
        submittedAt: DateTime.now(),
      );
    });

    showAppSnackBar(
      context,
      'Demo: tugas ditandai sudah dikumpulkan.',
      variant: AppSnackBarVariant.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignment = _assignment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
                    ),
                    const Spacer(),
                    Text(
                      assignment.id,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      assignment.courseName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  assignment.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tenggat & Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _row(
                  Icons.event_outlined,
                  'Tenggat',
                  '${DateFormat.longDate(assignment.deadline)} - '
                      '${DateFormat.time(assignment.deadline)}',
                ),
                _row(
                  Icons.schedule,
                  'Sisa waktu',
                  DateFormat.relativeDeadline(assignment.deadline),
                  valueColor: assignment.isOverdue
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
                if (assignment.submittedAt != null)
                  _row(
                    Icons.check_circle_outline,
                    'Dikumpulkan',
                    '${DateFormat.shortDate(assignment.submittedAt!)} - '
                        '${DateFormat.time(assignment.submittedAt!)}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'File Pendukung',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const DemoNote(text: 'Contoh', compact: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (assignment.attachments.isEmpty)
                  const Text(
                    'Tidak ada file pendukung pada tugas ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  for (final file in assignment.attachments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 18,
                            color: AppColors.iconNavy,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              file,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => showAppSnackBar(
                              context,
                              'Demo: berkas "$file" tidak tersedia.',
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Lihat'),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (assignment.status != AssignmentStatus.dikumpulkan)
            AppButton(
              label: 'KUMPULKAN TUGAS',
              icon: Icons.cloud_upload_outlined,
              onPressed: _submit,
            )
          else
            const AppButton(
              label: 'SUDAH DIKUMPULKAN',
              icon: Icons.check_circle_outline,
              variant: AppButtonVariant.secondary,
              onPressed: null,
            ),
          const SizedBox(height: AppSpacing.md),
          const DemoNotice(
            text:
                'Tombol pengumpulan hanya mengubah status secara lokal '
                '(simulasi). Tidak ada berkas yang dikirim ke sistem '
                'kampus.',
          ),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.iconNavy),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
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
