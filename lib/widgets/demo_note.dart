import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Penanda visual bahwa sebuah data atau aksi masih berupa simulasi.
///
/// Wajib dipakai pada semua fitur yang belum terhubung ke sistem kampus
/// sungguhan (lihat WORKFLOW §9 dan REVISI §3).
class DemoNote extends StatelessWidget {
  const DemoNote({
    super.key,
    this.text = 'Data simulasi',
    this.icon = Icons.science_outlined,
    this.compact = false,
  });

  final String text;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: AppColors.warning),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris catatan panjang di dalam kartu (bukan badge).
class DemoNotice extends StatelessWidget {
  const DemoNotice({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
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
