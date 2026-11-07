import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../../domain/ips_calculator.dart';

/// Kartu ringkasan seluruh semester: IPK, total SKS, dan jumlah matkul.
class NilaiSummaryCard extends StatelessWidget {
  const NilaiSummaryCard({super.key, required this.summary});

  final AcademicSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primarySoft,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Ringkasan Akademik',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  value: summary.ipk.toStringAsFixed(2),
                  label: 'IPK',
                  highlight: true,
                ),
              ),
              _Divider(),
              Expanded(
                child: _SummaryStat(
                  value: '${summary.totalSks}',
                  label: 'Total SKS',
                ),
              ),
              _Divider(),
              Expanded(
                child: _SummaryStat(
                  value: '${summary.courseCount}',
                  label: 'Mata kuliah',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (summary.ipk / 4.0).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'IPK = Σ(angka mutu × SKS) ÷ Σ(SKS) dari seluruh semester.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu ringkasan satu semester: IPS, SKS, dan jumlah matkul.
class SemesterSummaryCard extends StatelessWidget {
  const SemesterSummaryCard({super.key, required this.group});

  final SemesterGroup group;

  @override
  Widget build(BuildContext context) {
    final summary = group.summary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  group.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${summary.courseCount} MK',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SemesterStat(
                  label: 'IPS',
                  value: summary.ips.toStringAsFixed(2),
                  highlight: true,
                ),
              ),
              Expanded(
                child: _SemesterStat(
                  label: 'SKS',
                  value: '${summary.totalSks}',
                ),
              ),
              Expanded(
                child: _SemesterStat(
                  label: 'Mutu',
                  value: summary.totalMutu.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          if (summary.hasUnknownCourses) ...[
            const SizedBox(height: AppSpacing.md),
            _UnknownCourseWarning(codes: summary.unknownCourseCodes),
          ],
        ],
      ),
    );
  }
}

class _SemesterStat extends StatelessWidget {
  const _SemesterStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: highlight ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppColors.divider);
  }
}

class _UnknownCourseWarning extends StatelessWidget {
  const _UnknownCourseWarning({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kode ${codes.join(', ')} belum ada di tabel referensi. '
              'Nilai tetap tampil, tetapi tidak dihitung dalam IPS/IPK.',
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
