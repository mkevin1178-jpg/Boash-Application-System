import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/profile_avatar.dart';
import '../academic/ktm_screen.dart';
import 'settings_screen.dart';

/// Halaman profil mahasiswa demo.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun demo?'),
        content: const Text(
          'Sesi demo akan dihapus dari aplikasi dan Anda kembali ke '
          'halaman login. Data contoh di dalam aplikasi tetap tersedia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    final session = controller.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.pageBottom),
          children: [
            _header(context, session),
            const SizedBox(height: AppSpacing.lg),
            _summaryCard(context),
            const SizedBox(height: AppSpacing.lg),
            _identityCard(session),
            const SizedBox(height: AppSpacing.lg),
            _menuCard(context),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
              child: DemoNotice(
                text:
                    'Seluruh data pada halaman ini adalah data contoh. '
                    'Aplikasi tidak terhubung dengan sistem akademik kampus.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
              child: AppButton(
                label: 'KELUAR DARI AKUN DEMO',
                icon: Icons.logout,
                variant: AppButtonVariant.danger,
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppSession? session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.xl,
        AppSpacing.pageH,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          ProfileAvatar(
            photoUrl: session?.photoUrl ?? '',
            initials: session?.initials ?? 'M',
            radius: 42,
            borderColor: AppColors.onPrimary,
            borderWidth: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            session?.fullName ?? 'Mahasiswa Demo',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'NIM ${session?.nim ?? DemoData.nim} - '
            '${session?.programStudi ?? DemoData.programStudi}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onPrimarySoft,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const DemoNote(
            text: 'Akun demo - profil contoh dari API acak',
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                value: '${DemoData.totalCredits}',
                label: 'Total SKS',
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            Expanded(
              child: _Stat(
                value: DemoData.gpa.toStringAsFixed(2),
                label: 'IPK',
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            Expanded(
              child: _Stat(
                value: '${DemoData.courses.length}',
                label: 'Mata kuliah',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identityCard(AppSession? session) {
    final rows = <(IconData, String, String)>[
      (Icons.badge_outlined, 'NIM / NPM', session?.nim ?? DemoData.nim),
      (
        Icons.email_outlined,
        'Email',
        session?.email.isNotEmpty == true ? session!.email : '-',
      ),
      (
        Icons.school_outlined,
        'Program Studi',
        session?.programStudi ?? DemoData.programStudi,
      ),
      (
        Icons.account_balance_outlined,
        'Fakultas',
        session?.faculty ?? DemoData.faculty,
      ),
      (
        Icons.calendar_month_outlined,
        'Semester',
        session?.semester ?? DemoData.semester,
      ),
      (
        Icons.schedule_outlined,
        'Tahun Akademik',
        session?.academicYear ?? DemoData.academicYear,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            for (final (index, row) in rows.indexed) ...[
              _row(row.$1, row.$2, row.$3),
              if (index != rows.length - 1)
                const Divider(height: 1, color: AppColors.divider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            _menuItem(
              context,
              icon: Icons.badge_outlined,
              title: 'Kartu Tanda Mahasiswa',
              subtitle: 'Lihat KTM demo',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KtmScreen(controller: controller),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _menuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Informasi aplikasi dan mode demo',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(controller: controller),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _menuItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Boash Student App',
              subtitle: 'Versi 2.0 - prototipe PBL',
              onTap: () => showAppSnackBar(
                context,
                'Boash Student App versi 2.0 - prototipe PBL.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.iconNavy),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
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
}

/// Angka ringkasan dengan label kecil.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
