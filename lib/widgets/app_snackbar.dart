import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// SnackBar seragam: latar gelap, teks putih, sudut bulat, mengambang.
///
/// [variant] menentukan warna dan ikon sehingga aksi berhasil, gagal, dan
/// informatif dapat dibedakan.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarVariant variant = AppSnackBarVariant.info,
}) {
  final (background, foreground, icon) = switch (variant) {
    AppSnackBarVariant.info => (
      AppColors.snackBg,
      AppColors.onPrimary,
      Icons.info_outline,
    ),
    AppSnackBarVariant.success => (
      AppColors.success,
      AppColors.onPrimary,
      Icons.check_circle_outline,
    ),
    AppSnackBarVariant.error => (
      AppColors.danger,
      AppColors.onPrimary,
      Icons.error_outline,
    ),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13, height: 1.3, color: foreground),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

/// Varian snackbar aplikasi.
enum AppSnackBarVariant { info, success, error }
