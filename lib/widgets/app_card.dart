import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// Kartu permukaan seragam (putih, radius 16, bayangan lembut).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor,
    this.showShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.card,
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: showShadow ? AppColors.softShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
