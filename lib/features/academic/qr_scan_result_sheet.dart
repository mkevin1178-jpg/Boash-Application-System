import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../services/qr_attendance_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/status_badge.dart';

Future<void> showQrScanResultSheet(BuildContext context, ScanResult result) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QrScanResultSheet(result: result),
    );

class QrScanResultSheet extends StatelessWidget {
  const QrScanResultSheet({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final (label, color, background, icon) = _style(result.status);
    final log = result.log;
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
            StatusBadge(
              label: label,
              color: color,
              background: background,
              icon: icon,
            ),
            const SizedBox(height: AppSpacing.sm),
            const DemoNote(text: 'Hasil scan demo', compact: true),
            const SizedBox(height: AppSpacing.md),
            Text(
              result.message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (log != null) ...[
              const SizedBox(height: AppSpacing.md),
              _row(Icons.menu_book_outlined, 'Mata kuliah', log.courseName),
              _row(Icons.confirmation_number_outlined, 'Kode', log.courseCode),
              _row(
                Icons.event_available_outlined,
                'Pertemuan',
                'Pertemuan ke-${log.meeting}',
              ),
              _row(
                Icons.schedule,
                'Waktu scan',
                DateFormat.time(log.scannedAt),
              ),
              _row(Icons.badge_outlined, 'NPM', log.npm),
              const SizedBox(height: AppSpacing.sm),
              const DemoNotice(
                text: 'Presensi demo disimpan di memori aplikasi.',
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
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

  (String, Color, Color, IconData) _style(ScanStatus status) =>
      switch (status) {
        ScanStatus.hadir => (
          'HADIR',
          AppColors.success,
          AppColors.successBg,
          Icons.check_circle_outline,
        ),
        ScanStatus.sudahTercatat => (
          'SUDAH TERCATAT',
          AppColors.info,
          AppColors.infoBg,
          Icons.info_outline,
        ),
        ScanStatus.kedaluwarsa || ScanStatus.diLuarJadwal => (
          'DITOLAK',
          AppColors.warning,
          AppColors.warningBg,
          Icons.schedule,
        ),
        ScanStatus.formatTidakValid || ScanStatus.mataKuliahTidakDikenal => (
          'QR TIDAK VALID',
          AppColors.danger,
          AppColors.dangerBg,
          Icons.error_outline,
        ),
      };
}
