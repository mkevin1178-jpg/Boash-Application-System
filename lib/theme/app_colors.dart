import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const gradTop = Color(0xFF0B86E0);
  static const gradMid = Color(0xFF0A4FCB);
  static const gradBottom = Color(0xFF0A2A9E);
  static const primary = Color(0xFF0B4FCB);
  static const buttonStart = Color(0xFF12A0EE);
  static const buttonEnd = Color(0xFF0B5ED7);
  static const iconNavy = Color(0xFF1A2B6D); // satu warna untuk semua ikon menu
  static const iconBg = Color(0xFFE8EFFF);
  static const surfaceAlt = Color(0xFFF3F6FE);
  static const textPrimary = Color(0xFF0F1B3D);
  static const textSecondary = Color(0xFF5F6B8A);
  static const onGradient = Color(0xFFFFFFFF);
  static const onGradientSoft = Color(0xFFCFE3FF);
  static const divider = Color(0xFFE6EBF7);
  static const badge = Color(0xFFEF4444);
  static const snackBg = Color(0xFF25304F);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradTop, gradMid, gradBottom],
    stops: [0, .45, 1],
  );

  static const buttonGradient =
      LinearGradient(colors: [buttonStart, buttonEnd]);

  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A0B4FCB),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];
}
