import 'package:flutter/material.dart';

import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';

/// Halaman login demo.
///
/// Alur: validasi input -> pencocokan dengan akun contoh dari API acak ->
/// simpan sesi demo. Setelah sesi tersimpan, [AppRoot] otomatis menampilkan
/// dashboard sehingga halaman ini tidak perlu melakukan navigasi manual.
///
/// **Login ini adalah simulasi.** API randomuser.me hanya menyediakan profil
/// contoh; tidak ada verifikasi identitas terhadap sistem kampus.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _usernameError = username.isEmpty ? 'Username wajib diisi' : null;
      _passwordError = password.isEmpty ? 'Password wajib diisi' : null;
    });

    if (_usernameError != null || _passwordError != null) return;

    final outcome = await widget.controller.login(username, password);
    if (!mounted) return;

    switch (outcome) {
      case LoginSuccess():
        // Sesi demo tersimpan; AppRoot yang memindahkan ke dashboard.
        break;
      case LoginFailure():
        showAppSnackBar(
          context,
          widget.controller.loginError ?? 'Login gagal. Coba lagi.',
          variant: AppSnackBarVariant.error,
        );
    }
  }

  void _showSignUpNotice() {
    showAppSnackBar(
      context,
      'Pendaftaran akun tidak tersedia pada versi demo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Icon(
                  Icons.menu_book,
                  size: 84,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'BOASH STUDENT APP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Masuk ke akun Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Gunakan akun contoh dari API acak di bawah untuk masuk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.onPrimarySoft,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _GlassField(
                  child: AppTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Masukkan username demo',
                    icon: Icons.person_outline,
                    errorText: _usernameError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => widget.controller.clearLoginError(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _GlassField(
                  child: AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Masukkan password demo',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    errorText: _passwordError,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => widget.controller.clearLoginError(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    final submitting =
                        widget.controller.loginState == LoginState.submitting;
                    return AppButton(
                      label: submitting ? 'MEMPROSES...' : 'MASUK',
                      icon: submitting ? null : Icons.login,
                      isLoading: submitting,
                      onPressed: submitting ? null : _submit,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const _DemoNotice(),
                const SizedBox(height: AppSpacing.xl),
                _DemoAccountCard(
                  controller: widget.controller,
                  onUseAccount: (username, password) {
                    _usernameController.text = username;
                    _passwordController.text = password;
                    setState(() {
                      _usernameError = null;
                      _passwordError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onPrimarySoft,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showSignUpNotice,
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kolom input dengan gaya kaca di atas latar gradien.
class _GlassField extends StatelessWidget {
  const _GlassField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            labelStyle: TextStyle(color: AppColors.onPrimarySoft),
            hintStyle: TextStyle(color: AppColors.onPrimarySoft),
            prefixIconColor: AppColors.onPrimarySoft,
            suffixIconColor: AppColors.onPrimarySoft,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Penjelasan singkat bahwa login bersifat simulasi.
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.onPrimarySoft),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Autentikasi demo - bukan sistem autentikasi kampus resmi.',
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: AppColors.onPrimarySoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu akun contoh dari API acak.
///
/// Password disembunyikan secara default dan hanya ditampilkan ketika
/// pengguna menekan tombol lihat.
class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard({
    required this.controller,
    required this.onUseAccount,
  });

  final AppController controller;
  final void Function(String username, String password) onUseAccount;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final user = controller.demoUser;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: _buildBody(context, user),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic>? user) {
    if (controller.isLoadingDemoUser) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            'Mengambil akun contoh dari API...',
            style: TextStyle(fontSize: 12, color: AppColors.onPrimarySoft),
          ),
        ],
      );
    }

    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akun demo belum tersedia',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            controller.demoUserError ??
                'Gagal memuat akun contoh dari API acak.',
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: AppColors.onPrimarySoft,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: controller.loadDemoUser,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onPrimary,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text(
              'Coba lagi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    final login = user['login'] as Map? ?? const {};
    final username = '${login['username'] ?? '-'}';
    final password = '${login['password'] ?? '-'}';

    return _DemoAccountContent(
      username: username,
      password: password,
      onUseAccount: () => onUseAccount(username, password),
      onReload: controller.loadDemoUser,
    );
  }
}

/// Isi kartu akun contoh (state reveal password terpisah).
class _DemoAccountContent extends StatefulWidget {
  const _DemoAccountContent({
    required this.username,
    required this.password,
    required this.onUseAccount,
    required this.onReload,
  });

  final String username;
  final String password;
  final VoidCallback onUseAccount;
  final VoidCallback onReload;

  @override
  State<_DemoAccountContent> createState() => _DemoAccountContentState();
}

class _DemoAccountContentState extends State<_DemoAccountContent> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKUN DEMO DARI API ACAK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.onPrimarySoft,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _row(Icons.person_outline, 'Username', widget.username),
        const SizedBox(height: AppSpacing.sm),
        _row(
          Icons.lock_outline,
          'Password',
          _revealed ? widget.password : '••••••••',
          trailing: IconButton(
            tooltip: _revealed ? 'Sembunyikan password' : 'Tampilkan password',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              _revealed
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
              color: AppColors.onPrimarySoft,
            ),
            onPressed: () => setState(() => _revealed = !_revealed),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: widget.onUseAccount,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onPrimary,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  minimumSize: const Size(0, 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: const Text(
                  'Isi otomatis',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextButton.icon(
                onPressed: widget.onReload,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onPrimary,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  minimumSize: const Size(0, 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Ganti akun',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onPrimarySoft),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.onPrimarySoft),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
