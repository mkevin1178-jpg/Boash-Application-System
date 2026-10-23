import 'package:flutter/material.dart';

/// Token warna tunggal aplikasi.
///
/// Semua halaman harus memakai token ini; jangan menuliskan nilai hex
/// langsung di dalam widget. Identitas visual: biru utama, latar terang
/// netral, permukaan kartu putih.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------- brand
  static const primary = Color(0xFF0B4FCB);
  static const primaryDark = Color(0xFF093C9E);
  static const primarySoft = Color(0xFFE8EFFF);
  static const accent = Color(0xFF12A0EE);

  // ------------------------------------------------------------- surface
  static const background = Color(0xFFF4F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3F6FE);

  // ----------------------------------------------------------------- text
  static const textPrimary = Color(0xFF17233F);
  static const textSecondary = Color(0xFF5F6B8A);
  static const textMuted = Color(0xFF8A94B0);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimarySoft = Color(0xFFCFE3FF);

  // ------------------------------------------------------- lines & icons
  static const divider = Color(0xFFE6EBF7);

  /// Warna tunggal untuk seluruh ikon menu & ikon daftar (aturan design.md §3.4).
  static const iconNavy = Color(0xFF1A2B6D);
  static const iconBg = Color(0xFFE8EFFF);

  // --------------------------------------------------------------- status
  static const success = Color(0xFF15803D);
  static const successBg = Color(0xFFE7F6EC);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFB91C1C);
  static const dangerBg = Color(0xFFFDE7E7);
  static const info = Color(0xFF0B4FCB);
  static const infoBg = Color(0xFFE8EFFF);

  // ----------------------------------------------------------------- misc
  static const badge = Color(0xFFEF4444);
  static const snackBg = Color(0xFF25304F);

  // ------------------------------------------------------------ gradients
  static const gradTop = Color(0xFF0B86E0);
  static const gradMid = Color(0xFF0A4FCB);
  static const gradBottom = Color(0xFF0A2A9E);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradTop, gradMid, gradBottom],
    stops: [0, .45, 1],
  );

  static const buttonGradient = LinearGradient(colors: [accent, primary]);

  static const cardShadow = [
    BoxShadow(color: Color(0x1A0B4FCB), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const softShadow = [
    BoxShadow(color: Color(0x0F0B4FCB), blurRadius: 10, offset: Offset(0, 2)),
  ];
}
