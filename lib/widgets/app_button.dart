import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tombol seragam: varian primary, secondary (outline), dan ghost.
///
/// Dipakai di seluruh aplikasi agar tinggi, radius, dan tipografi tombol
/// selalu sama.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.85),
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.primary),
        ),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: _isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
        ),
        child: child,
      ),
      AppButtonVariant.danger => ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.45),
        ),
        child: child,
      ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  bool get _isEnabled => onPressed != null && !isLoading;

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.onPrimary,
        ),
      );
    }

    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}

/// Varian tombol yang tersedia.
enum AppButtonVariant { primary, secondary, ghost, danger }
