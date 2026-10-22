import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lingkaran ikon + label untuk grid menu Home.
/// Semua ikon memakai satu warna: [AppColors.iconNavy].
class MenuIconTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const MenuIconTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _pressed ? AppColors.iconNavy : AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 28,
              color: _pressed ? Colors.white : AppColors.iconNavy,
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
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
