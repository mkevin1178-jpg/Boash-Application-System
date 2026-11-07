import 'package:flutter/material.dart';

import '../../../../shared/matkul_reference.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';
import '../../data/models/nilai_model.dart';

/// Kartu satu mata kuliah pada daftar nilai.
class NilaiCourseTile extends StatelessWidget {
  const NilaiCourseTile({super.key, required this.nilai, required this.onTap});

  final Nilai nilai;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = MatkulReference.find(nilai.kdMatkul);
    final nama = info?.nama ?? nilai.kdMatkul;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama.isEmpty ? '-' : nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      nilai.kdMatkul.isEmpty ? '-' : nilai.kdMatkul,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      info == null ? 'SKS ?' : '${info.sks} SKS',
                      style: TextStyle(
                        fontSize: 11,
                        color: info == null
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (info == null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: nilai.hm.isEmpty ? '-' : nilai.hm,
                color: _letterColor(nilai.hm),
                background: _letterBackground(nilai.hm),
                dense: true,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                nilai.na.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }

  static Color _letterColor(String letter) {
    final value = letter.toUpperCase().trim();
    if (value == 'A' || value == 'A-') return AppColors.success;
    if (value.startsWith('B')) return AppColors.info;
    if (value.startsWith('C')) return AppColors.warning;
    return AppColors.danger;
  }

  static Color _letterBackground(String letter) {
    final value = letter.toUpperCase().trim();
    if (value == 'A' || value == 'A-') return AppColors.successBg;
    if (value.startsWith('B')) return AppColors.infoBg;
    if (value.startsWith('C')) return AppColors.warningBg;
    return AppColors.dangerBg;
  }
}
