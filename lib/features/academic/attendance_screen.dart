import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/attendance.dart';
import '../../models/attendance_log.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/section_title.dart';
import '../../widgets/status_badge.dart';
import 'qr_scanner_screen.dart';

/// Halaman rekap presensi demo per mata kuliah.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final AsyncController<List<AttendanceRecord>> _attendanceController;
  late final AsyncController<List<AttendanceLog>> _logsController;

  @override
  void initState() {
    super.initState();
    _attendanceController = AsyncController<List<AttendanceRecord>>(
      () => widget.repository.fetchAttendanceFor(
        widget.controller.session?.npm ?? '',
      ),
    );
    _logsController = AsyncController<List<AttendanceLog>>(
      () => widget.repository.fetchAttendanceLogs(
        widget.controller.session?.npm ?? '',
      ),
    );
    _attendanceController.load();
    _logsController.load();
  }

  @override
  void dispose() {
    _attendanceController.dispose();
    _logsController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QrScannerScreen(
          controller: widget.controller,
          repository: widget.repository,
        ),
      ),
    );
    if (!mounted) return;
    await Future.wait([
      _attendanceController.load(force: true),
      _logsController.load(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Presensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<AttendanceRecord>>(
        controller: _attendanceController,
        loadingMessage: 'Memuat rekap presensi...',
        isEmpty: (data) => data.isEmpty,
        emptyTitle: 'Belum ada data presensi',
        emptyMessage: 'Rekap presensi semester ini belum tersedia.',
        emptyIcon: Icons.fact_check_outlined,
        builder: (context, records) => RefreshIndicator(
          onRefresh: () => _attendanceController.load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.lg,
              AppSpacing.pageH,
              AppSpacing.pageBottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              AppButton(
                label: 'Scan QR Presensi',
                icon: Icons.qr_code_scanner,
                onPressed: _scanQr,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final record in records)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _AttendanceCard(record: record),
                ),
              const SizedBox(height: AppSpacing.md),
              const SectionTitle(title: 'Riwayat scan QR'),
              const SizedBox(height: AppSpacing.md),
              AsyncBuilder<List<AttendanceLog>>(
                controller: _logsController,
                loadingMessage: 'Memuat riwayat scan...',
                errorTitle: 'Riwayat scan tidak tersedia',
                isEmpty: (logs) => logs.isEmpty,
                emptyTitle: 'Belum ada riwayat scan QR',
                emptyMessage: 'Hasil scan QR presensi akan muncul di sini.',
                emptyIcon: Icons.qr_code_scanner,
                builder: (context, logs) => Column(
                  children: [
                    for (final log in logs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _AttendanceLogCard(log: log),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceLogCard extends StatelessWidget {
  const _AttendanceLogCard({required this.log});

  final AttendanceLog log;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.iconBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.qr_code_scanner, color: AppColors.iconNavy),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.courseName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${log.courseCode} · Pertemuan ke-${log.meeting}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${DateFormat.shortDate(log.scannedAt)} · ${DateFormat.time(log.scannedAt)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const StatusBadge.success('HADIR', icon: Icons.check_circle_outline),
      ],
    ),
  );
}

/// Kartu rekap presensi satu mata kuliah.
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final percentage = record.percentage;
    final isGood = percentage >= 80;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.courseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(
                label: '${percentage.toStringAsFixed(0)}%',
                color: isGood ? AppColors.success : AppColors.warning,
                background: isGood ? AppColors.successBg : AppColors.warningBg,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGood ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _chip('Hadir', record.attended, AppColors.success),
              _chip('Sakit', record.sick, AppColors.info),
              _chip('Izin', record.permission, AppColors.warning),
              _chip('Tanpa Keterangan', record.missed, AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              height: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
