import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../state/app_controller.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/profile_avatar.dart';

/// Halaman Kartu Tanda Mahasiswa (KTM) - versi demo.
///
/// Identitas pada kartu adalah data contoh. Barcode di bawah bersifat
/// **dekoratif** dan tidak dapat dipindai untuk verifikasi.
class KtmScreen extends StatelessWidget {
  const KtmScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    final fullName = session?.fullName ?? 'Mahasiswa Demo';
    final initials = session?.initials ?? 'MD';
    final photoUrl = session?.photoUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kartu Tanda Mahasiswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          const DemoNotice(
            text:
                'KTM demo. Barcode bersifat dekoratif dan bukan alat '
                'verifikasi. Tombol simpan dan bagikan hanya simulasi.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCard(
            context,
            fullName: fullName,
            initials: initials,
            photoUrl: photoUrl,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Data Mahasiswa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                _infoRow(
                  Icons.badge_outlined,
                  'NIM',
                  session?.nim ?? DemoData.nim,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _infoRow(Icons.email_outlined, 'Email', session?.email ?? '-'),
                const Divider(height: 1, color: AppColors.divider),
                _infoRow(
                  Icons.school_outlined,
                  'Program Studi',
                  session?.programStudi ?? DemoData.programStudi,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _infoRow(
                  Icons.account_balance_outlined,
                  'Fakultas',
                  session?.faculty ?? DemoData.faculty,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _infoRow(
                  Icons.phone_outlined,
                  'Telepon',
                  session?.phone ?? AppSession.demoPhone,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _infoRow(
                  Icons.calendar_month_outlined,
                  'Tahun Akademik',
                  '${session?.academicYear ?? DemoData.academicYear} - '
                      'Semester ${session?.semester ?? DemoData.semester}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'BAGIKAN KTM',
            icon: Icons.share_outlined,
            onPressed: () => showAppSnackBar(
              context,
              'Demo: membagikan KTM tidak tersedia pada versi ini.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'SIMPAN KTM',
            icon: Icons.download_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => showAppSnackBar(
              context,
              'Demo: KTM tidak disimpan ke galeri pada versi ini.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String fullName,
    required String initials,
    required String photoUrl,
  }) {
    final session = controller.session;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNIVERSITAS NUSANTARA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'KARTU TANDA MAHASISWA - DEMO',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: AppColors.onPrimarySoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  photoUrl: photoUrl,
                  initials: initials,
                  radius: 40,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardRow('NIM', session?.nim ?? DemoData.nim),
                      _cardRow('Nama', fullName),
                      _cardRow(
                        'Program Studi',
                        session?.programStudi ?? DemoData.programStudi,
                      ),
                      _cardRow(
                        'Fakultas',
                        session?.faculty ?? DemoData.faculty,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                _metaBox('Semester', session?.semester ?? DemoData.semester),
                const SizedBox(width: AppSpacing.sm),
                _metaBox(
                  'Tahun Akademik',
                  session?.academicYear ?? DemoData.academicYear,
                ),
                const SizedBox(width: AppSpacing.sm),
                _metaBox(
                  'Berlaku s/d',
                  session?.validUntil ?? DemoData.validUntil,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
            child: Row(
              children: [
                const _Barcode(),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'No. ${session?.nim ?? DemoData.nim}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Barcode dekoratif - bukan alat verifikasi',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.onPrimarySoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: AppColors.iconNavy),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barcode dekoratif (bukan barcode yang dapat discan).
class _Barcode extends StatelessWidget {
  const _Barcode();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 22; i++)
          Container(
            width: i % 4 == 0 ? 3 : 1.5,
            height: 24,
            margin: const EdgeInsets.only(right: 1.5),
            color: Colors.white.withValues(alpha: i % 3 == 0 ? 1 : 0.7),
          ),
      ],
    );
  }
}
