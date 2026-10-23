import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lingkaran ikon + label untuk grid menu.
///
/// Semua ikon memakai satu warna: [AppColors.iconNavy].
class MenuIconTile extends StatefulWidget {
  const MenuIconTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.description,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? description;

  @override
  State<MenuIconTile> createState() => _MenuIconTileState();
}

class _MenuIconTileState extends State<MenuIconTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Semantics(
        button: true,
        label: widget.description ?? widget.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _pressed ? AppColors.iconNavy : AppColors.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 26,
                color: _pressed ? AppColors.onPrimary : AppColors.iconNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
