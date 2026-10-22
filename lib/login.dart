import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'session.dart';
import 'theme/app_colors.dart';
import 'welcome.dart';

class LoginScreen extends StatefulWidget {
  final AuthApi? authApi;

  const LoginScreen({super.key, this.authApi});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _message;
  bool _messageIsError = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final api = widget.authApi ?? const AuthApi();
    final user = await api.fetchRandomUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
      if (user == null) {
        _messageIsError = true;
        _message = 'Gagal memuat data dari API. Tekan "Ganti User Acak".';
      }
    });
  }

  void _login() {
    if (_loading) return;

    if (_user == null) {
      _showMessage('Data user belum dimuat dari API');
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username dan password wajib diisi');
      return;
    }

    // Cocokkan input dengan username & password dari API randomuser.me
    final apiUsername = '${_user!['login']?['username'] ?? ''}';
    final apiPassword = '${_user!['login']?['password'] ?? ''}';

    if (username == apiUsername && password == apiPassword) {
      AppSession.setFromApiUser(_user!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } else {
      _showMessage('Username atau password salah');
    }
  }

  void _showMessage(String text, {bool error = true}) {
    setState(() {
      _message = text;
      _messageIsError = error;
    });
  }

  void _signUp() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Sign Up is not available in this demo.',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.snackBg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.onGradientSoft),
      prefixIcon: Icon(icon, color: AppColors.onGradient),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.50),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = '${_user?['login']?['username'] ?? '-'}';
    final currentPassword = '${_user?['login']?['password'] ?? '-'}';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.menu_book,
                  size: 96,
                  color: AppColors.onGradient,
                ),
                const SizedBox(height: 16),
                const Text(
                  'STUDENT APP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.onGradient,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Login your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onGradient,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with the account from randomuser.me API',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onGradientSoft,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Username', Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Password', Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _loading ? 'MEMUAT...' : 'LOGIN',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  _buildMessage(),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account? ",
                      style: TextStyle(color: AppColors.onGradientSoft),
                    ),
                    GestureDetector(
                      onTap: _signUp,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.onGradient,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildApiHint(currentUsername, currentPassword),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            _messageIsError
                ? Icons.error_outline
                : Icons.check_circle_outline,
            size: 18,
            color: AppColors.onGradient,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.onGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu info akun dari API (untuk testing) + tombol ganti user acak.
  Widget _buildApiHint(String username, String password) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: _loading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Mengambil user dari API...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Akun login dari API (untuk testing)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.onGradientSoft,
                  ),
                ),
                const SizedBox(height: 10),
                _hintRow(Icons.person_outline, 'Username', username),
                const SizedBox(height: 6),
                _hintRow(Icons.lock_outline, 'Password', password),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: TextButton.icon(
                    onPressed: _loadUser,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onGradient,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'Ganti User Acak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _hintRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onGradientSoft),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.onGradientSoft),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onGradient,
            ),
          ),
        ),
      ],
    );
  }
}
