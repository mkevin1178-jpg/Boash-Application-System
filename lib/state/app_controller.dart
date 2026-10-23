import 'package:flutter/foundation.dart';

import '../services/auth_api.dart';
import 'app_session.dart';

/// Status proses login demo.
enum LoginState { idle, submitting, success, failure }

/// Hasil percobaan login.
sealed class LoginOutcome {
  const LoginOutcome();
}

/// Login berhasil dan sesi demo tersimpan.
class LoginSuccess extends LoginOutcome {
  const LoginSuccess(this.session);

  final AppSession session;
}

/// Login ditolak — [message] menjelaskan alasannya.
class LoginFailure extends LoginOutcome {
  const LoginFailure(this.message);

  final String message;
}

/// Pengelola sesi dan alur login demo.
///
/// Menggantikan `AppSession` static global pada versi sebelumnya: sesi kini
/// menjadi instance yang bisa dibersihkan saat logout (lihat REVISI P0
/// "Logout demo: konfirmasi keluar dan penghapusan sesi lokal").
class AppController extends ChangeNotifier {
  AppController({AuthApi? authApi}) : _authApi = authApi ?? const AuthApi();

  final AuthApi _authApi;

  bool _disposed = false;

  AppSession? _session;
  LoginState _loginState = LoginState.idle;
  String? _loginError;
  Map<String, dynamic>? _demoUser;
  bool _loadingDemoUser = false;
  String? _demoUserError;

  /// Sesi demo yang sedang aktif, atau `null` bila belum login.
  AppSession? get session => _session;

  bool get isLoggedIn => _session != null;

  LoginState get loginState => _loginState;

  String? get loginError => _loginError;

  /// Profil contoh yang dipakai untuk login (dari randomuser.me).
  Map<String, dynamic>? get demoUser => _demoUser;

  bool get isLoadingDemoUser => _loadingDemoUser;

  String? get demoUserError => _demoUserError;

  /// Mengambil satu profil contoh dari API acak.
  ///
  /// Kredensial contoh pada hasil ini hanya dipakai untuk **simulasi login**.
  Future<bool> loadDemoUser() async {
    _loadingDemoUser = true;
    _demoUserError = null;
    _notify();

    final result = await _authApi.fetchRandomUser();
    if (_disposed) return false;

    switch (result) {
      case AuthSuccess(:final user):
        _demoUser = user;
        _demoUserError = null;
        _loadingDemoUser = false;
        _notify();
        return true;
      case AuthFailure(:final message):
        _loadingDemoUser = false;
        _demoUserError = message;
        _notify();
        return false;
    }
  }

  /// Melakukan login demo.
  ///
  /// Mekanisme ini **bersifat simulasi**: input pengguna dicocokkan dengan
  /// username dan password profil contoh dari randomuser.me. Tidak ada
  /// verifikasi identitas terhadap sistem kampus mana pun.
  Future<LoginOutcome> login(String username, String password) async {
    if (_loginState == LoginState.submitting) {
      return const LoginFailure('Permintaan login sedang berjalan.');
    }

    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      final message = 'Username dan password wajib diisi.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return LoginFailure(message);
    }

    final user = _demoUser;
    if (user == null) {
      const message =
          'Data contoh dari API belum tersedia. Tekan "Coba lagi" dulu.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }
    _loginState = LoginState.submitting;
    _loginError = null;
    _notify();

    final apiUsername = '${(user['login'] as Map?)?['username'] ?? ''}';
    final apiPassword = '${(user['login'] as Map?)?['password'] ?? ''}';

    if (trimmedUsername != apiUsername || password != apiPassword) {
      const message =
          'Username atau password tidak cocok dengan akun demo dari API.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    _session = AppSession.fromApiUser(user);
    _loginState = LoginState.success;
    _loginError = null;
    _notify();
    return LoginSuccess(_session!);
  }

  /// Membersihkan sesi demo dan mengembalikan aplikasi ke keadaan awal.
  void logout() {
    _session = null;
    _loginState = LoginState.idle;
    _loginError = null;
    _notify();
  }

  /// Menghapus pesan error login (dipakai saat user mengetik ulang).
  void clearLoginError() {
    if (_loginError == null) return;
    _loginError = null;
    if (_loginState == LoginState.failure) {
      _loginState = LoginState.idle;
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// `notifyListeners` yang aman setelah widget dibuang.
  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
