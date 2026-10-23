/// Skala jarak (spacing) aplikasi.
///
/// Semua jarak memakai kelipatan 4/8 agar tampilan konsisten di seluruh
/// halaman. Gunakan konstanta ini, bukan angka literal.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Padding horizontal standar untuk konten halaman.
  static const double pageH = 20;

  /// Padding bawah standar agar konten tidak tertutup bottom navigation.
  static const double pageBottom = 24;
}
