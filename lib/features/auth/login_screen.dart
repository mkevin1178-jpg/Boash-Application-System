import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

/// Halaman login resmi Sivitas Akademika Boash (Prototype).
///
/// Desain:
/// - Atas: latar gradien biru dengan ikon dekoratif dan nama aplikasi.
/// - Bawah: panel putih dengan sudut atas membulat besar, berisi form login.
///
/// Login menggunakan NPM dan kata sandi mahasiswa.
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
  final _npmController = TextEditingController();
  final _passwordController = TextEditingController();
  final _npmFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _npmError;
  String? _passwordError;
  bool _passwordVisible = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _npmController.dispose();
    _passwordController.dispose();
    _npmFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final npm = _npmController.text.trim();
    final password = _passwordController.text;

    // Validasi sisi klien
    String? npmErr;
    String? pwErr;

    if (npm.isEmpty) {
      npmErr = 'NPM wajib diisi';
    } else if (!RegExp(r'^\d{5,}$').hasMatch(npm)) {
      npmErr = 'NPM tidak valid (minimal 5 digit angka)';
    }

    if (password.isEmpty) {
      pwErr = 'Password wajib diisi';
    }

    setState(() {
      _npmError = npmErr;
      _passwordError = pwErr;
    });

    if (npmErr != null || pwErr != null) return;

    final outcome = await widget.controller.login(npm, password);
    if (!mounted) return;

    switch (outcome) {
      case LoginSuccess():
        // AppRoot mendeteksi isLoggedIn dan menampilkan dashboard.
        break;
      case LoginFailure(:final message):
        showAppSnackBar(context, message, variant: AppSnackBarVariant.error);
    }
  }

  void _onNpmChanged(String _) {
    widget.controller.clearLoginError();
    if (_npmError != null) setState(() => _npmError = null);
  }

  void _onPasswordChanged(String _) {
    widget.controller.clearLoginError();
    if (_passwordError != null) setState(() => _passwordError = null);
  }

  void _showForgotPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa Kata Sandi?'),
        content: const Text(
          'Untuk mengatur ulang kata sandi akun mahasiswa, silakan hubungi '
          'bagian Administrasi Akademik (BAAK) atau IT Helpdesk kampus dengan '
          'menunjukkan Kartu Tanda Mahasiswa (KTM).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Latar gradien biru — seluruh layar
          Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          ),

          // Konten scrollable
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - mq.padding.top,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header dekoratif ──────────────────────────────────
                    SizedBox(
                      height: screenHeight * 0.30,
                      child: const _HeaderDecor(),
                    ),

                    // ── Panel putih sudut atas membulat ───────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl + mq.viewInsets.bottom,
                      ),
                      child: _LoginForm(
                        npmController: _npmController,
                        passwordController: _passwordController,
                        npmFocus: _npmFocus,
                        passwordFocus: _passwordFocus,
                        npmError: _npmError,
                        passwordError: _passwordError,
                        passwordVisible: _passwordVisible,
                        rememberMe: _rememberMe,
                        onRememberMeChanged: (val) =>
                            setState(() => _rememberMe = val ?? false),
                        onPasswordVisibilityToggle: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                        onNpmChanged: _onNpmChanged,
                        onPasswordChanged: _onPasswordChanged,
                        onSubmit: _submit,
                        onForgotPassword: _showForgotPasswordDialog,
                        controller: widget.controller,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bagian header dekoratif: ikon dan nama aplikasi.
class _HeaderDecor extends StatelessWidget {
  const _HeaderDecor();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon buku dalam lingkaran blur lembut
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.40),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.menu_book,
              size: 44,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Sistem Informasi Kampus',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppColors.onPrimarySoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// Form login di dalam panel putih.
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.npmController,
    required this.passwordController,
    required this.npmFocus,
    required this.passwordFocus,
    required this.npmError,
    required this.passwordError,
    required this.passwordVisible,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onPasswordVisibilityToggle,
    required this.onNpmChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.controller,
  });

  final TextEditingController npmController;
  final TextEditingController passwordController;
  final FocusNode npmFocus;
  final FocusNode passwordFocus;
  final String? npmError;
  final String? passwordError;
  final bool passwordVisible;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<String> onNpmChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Masuk ke Akun Anda',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Silakan masukkan NPM dan kata sandi Anda untuk melanjutkan.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Field NPM ───────────────────────────────────────────────────
        _RoundedField(
          controller: npmController,
          focusNode: npmFocus,
          label: 'NPM',
          hint: 'Nomor Pokok Mahasiswa',
          icon: Icons.badge_outlined,
          errorText: npmError,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          onChanged: onNpmChanged,
          onSubmitted: (_) => passwordFocus.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Field Password ───────────────────────────────────────────────
        _RoundedField(
          controller: passwordController,
          focusNode: passwordFocus,
          label: 'Kata Sandi',
          hint: 'Masukkan kata sandi',
          icon: Icons.lock_outline,
          errorText: passwordError,
          obscureText: !passwordVisible,
          textInputAction: TextInputAction.done,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onPasswordVisibilityToggle,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Ingat Saya & Lupa Kata Sandi ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberMeChanged,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => onRememberMeChanged(!rememberMe),
                  child: const Text(
                    'Ingat saya',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lupa kata sandi?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Tombol Masuk ────────────────────────────────────────────────
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final submitting =
                controller.loginState == LoginState.submitting;
            return AppButton(
              label: submitting ? 'MEMPROSES...' : 'MASUK',
              icon: submitting ? null : Icons.login,
              isLoading: submitting,
              onPressed: submitting ? null : onSubmit,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Bantuan / Footer ───────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text(
              'Butuh bantuan? ',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            GestureDetector(
              onTap: onForgotPassword,
              child: const Text(
                'Hubungi BAAK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// Field input dengan sudut membulat seragam.
class _RoundedField extends StatelessWidget {
  const _RoundedField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
