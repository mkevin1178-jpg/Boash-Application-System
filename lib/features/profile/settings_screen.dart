import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';

/// Halaman pengaturan aplikasi.
///
/// Karena seluruh aplikasi berjalan pada **mode demo**, pengaturan yang
/// tersedia hanya informasional (tema, refresh akun contoh, dan logout).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
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
                'Aplikasi berjalan pada mode demo. Tidak ada pengaturan '
                'akun resmi karena belum terhubung ke sistem kampus.',
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Tampilan'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                _tile(
                  icon: Icons.palette_outlined,
                  title: 'Tema aplikasi',
                  subtitle: 'Terang (hanya tema yang tersedia)',
                ),
                const Divider(height: 1, color: AppColors.divider),
                _tile(
                  icon: Icons.text_fields,
                  title: 'Ukuran teks',
                  subtitle: 'Mengikuti pengaturan sistem perangkat',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Akun demo'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                _tile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Akun aktif',
                  subtitle: controller.session?.npm.isNotEmpty == true
                      ? 'NPM: ${controller.session!.npm}'
                      : 'Belum ada sesi aktif',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Aplikasi'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                _tile(
                  icon: Icons.info_outline,
                  title: 'Tentang aplikasi',
                  subtitle: 'Boash Student App versi 2.0 (prototipe PBL)',
                ),
                const Divider(height: 1, color: AppColors.divider),
                _tile(
                  icon: Icons.school_outlined,
                  title: 'Kampus',
                  subtitle: '${DemoData.universityName} - ${DemoData.faculty}',
                ),
                const Divider(height: 1, color: AppColors.divider),
                _tile(
                  icon: Icons.science_outlined,
                  title: 'Sumber data',
                  subtitle: 'Data lokal (demo) dan randomuser.me',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'KELUAR DARI AKUN DEMO',
            icon: Icons.logout,
            variant: AppButtonVariant.danger,
            onPressed: () {
              controller.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          const DemoNotice(
            text:
                'Keluar akan menghapus sesi demo yang tersimpan di memori '
                'aplikasi. Data contoh tidak ikut terhapus.',
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

/// Label seksi pengaturan.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      ),
    );
  }
}
