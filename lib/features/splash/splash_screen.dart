import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Layar pembuka aplikasi.
///
/// Ditampilkan selagi aplikasi menyiapkan akun contoh dari API acak. Setelah
/// itu, [AppRoot] yang menentukan halaman berikutnya (login atau dashboard).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/logo-boash.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'BAS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'SISTEM INFORMASI AKADEMIK',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppColors.onPrimarySoft,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistem Informasi Akademik Mahasiswa',
              style: TextStyle(fontSize: 11, color: AppColors.onPrimarySoft),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimarySoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
