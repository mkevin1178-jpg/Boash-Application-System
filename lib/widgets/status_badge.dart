import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lencana status. Selalu menampilkan **teks** status (tidak hanya warna)
/// agar dapat diakses oleh pengguna dengan gangguan penglihatan warna.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
    this.dense = false,
  });

  /// Badge netral — untuk status yang belum dapat diklasifikasikan.
  const StatusBadge.neutral(String label, {Key? key, IconData? icon})
    : this(
        label: label,
        color: AppColors.textSecondary,
        background: AppColors.surfaceAlt,
        icon: icon,
        key: key,
      );

  /// Badge sukses.
  const StatusBadge.success(String label, {Key? key, IconData? icon})
    : this(
        label: label,
        color: AppColors.success,
        background: AppColors.successBg,
        icon: icon,
        key: key,
      );

  /// Badge peringatan / tenggat dekat.
  const StatusBadge.warning(String label, {Key? key, IconData? icon})
    : this(
        label: label,
        color: AppColors.warning,
        background: AppColors.warningBg,
        icon: icon,
        key: key,
      );

  /// Badge bahaya / gagal.
  const StatusBadge.danger(String label, {Key? key, IconData? icon})
    : this(
        label: label,
        color: AppColors.danger,
        background: AppColors.dangerBg,
        icon: icon,
        key: key,
      );

  /// Badge informasi.
  const StatusBadge.info(String label, {Key? key, IconData? icon})
    : this(
        label: label,
        color: AppColors.info,
        background: AppColors.infoBg,
        icon: icon,
        key: key,
      );

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
