import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avatar profil dengan fallback.
///
/// Jika [photoUrl] kosong atau gambar gagal dimuat, ditampilkan avatar
/// lokal berisi inisial sehingga layout tidak pernah rusak.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 24,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String photoUrl;
  final String initials;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final fallback = _FallbackAvatar(radius: radius, initials: initials);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        shape: BoxShape.circle,
        border: borderWidth == 0
            ? null
            : Border.all(
                color: borderColor ?? AppColors.surface,
                width: borderWidth,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isEmpty
          ? fallback
          : Image.network(
              photoUrl,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.radius, required this.initials});

  final double radius;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.66,
          fontWeight: FontWeight.bold,
          color: AppColors.iconNavy,
        ),
      ),
    );
  }
}
