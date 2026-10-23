import 'package:flutter/foundation.dart';

import 'app_session.dart';

/// Status proses login.
enum LoginState { idle, submitting, success, failure }

/// Hasil percobaan login.
sealed class LoginOutcome {
  const LoginOutcome();
}

/// Login berhasil dan sesi tersimpan.
class LoginSuccess extends LoginOutcome {
  const LoginSuccess(this.session);

  final AppSession session;
}

/// Login ditolak — [message] menjelaskan alasannya.
class LoginFailure extends LoginOutcome {
  const LoginFailure(this.message);

  final String message;
}

/// Pengelola sesi dan alur login.
///
/// Login menggunakan NPM sebagai identitas dan password demo.
/// Karena endpoint autentikasi resmi belum tersedia, mekanisme ini
/// **berlabel DEMO** dan hanya memverifikasi format input minimal.
///
/// Endpoint `/nilai` hanya dipakai untuk data nilai, bukan autentikasi.
///
/// **Catatan keamanan:**
/// - SHA-1 tidak aman untuk produksi. Dipakai hanya untuk kompatibilitas
///   sementara dengan backend beta yang mungkin menyimpan hash SHA-1.
/// - Untuk produksi: verifikasi password harus dilakukan di backend melalui
///   HTTPS dengan Argon2id/bcrypt/scrypt. Jangan kirim hash SHA-1 ke
///   endpoint produksi tanpa memastikan kontrak API.
/// - Password tidak pernah dicetak ke log.
class AppController extends ChangeNotifier {
  AppController();

  bool _disposed = false;

  AppSession? _session;
  LoginState _loginState = LoginState.idle;
  String? _loginError;

  /// Sesi yang sedang aktif, atau `null` bila belum login.
  AppSession? get session => _session;

  bool get isLoggedIn => _session != null;

  LoginState get loginState => _loginState;

  String? get loginError => _loginError;

  // ------------------------------------------------------------------ login

  /// Melakukan login demo dengan NPM dan password.
  ///
  /// Karena endpoint autentikasi resmi belum tersedia, login ini adalah
  /// **simulasi**: NPM minimal 5 digit dan password minimal 4 karakter
  /// diterima. Identitas mahasiswa (profil) diisi dari data demo.
  ///
  /// NPM yang dimasukkan akan dipakai sebagai query ke API nilai.
  Future<LoginOutcome> login(String npm, String password) async {
    if (_loginState == LoginState.submitting) {
      return const LoginFailure('Permintaan login sedang berjalan.');
    }

    final trimmedNpm = npm.trim();

    // Validasi input kosong
    if (trimmedNpm.isEmpty && password.isEmpty) {
      const message = 'NPM dan password wajib diisi.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    if (trimmedNpm.isEmpty) {
      const message = 'NPM wajib diisi.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    if (password.isEmpty) {
      const message = 'Password wajib diisi.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    // Validasi format NPM minimal (hanya angka, min 5 digit)
    if (!RegExp(r'^\d{5,}$').hasMatch(trimmedNpm)) {
      const message = 'NPM tidak valid. Masukkan nomor NPM yang benar.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    _loginState = LoginState.submitting;
    _loginError = null;
    _notify();

    // Demo: password minimal 4 karakter — simulasi penolakan kredensial
    // Ini sengaja dibuat minimal agar demo tetap dapat digunakan,
    // sambil menunjukkan alur error jika password terlalu pendek.
    // Backend resmi harus menggantikan logika ini.
    if (password.length < 4) {
      const message =
          'Password terlalu pendek. '
          'Demo menerima password minimal 4 karakter.';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    // Login berhasil: buat sesi dengan NPM yang dimasukkan
    _session = AppSession.fromNpm(trimmedNpm);
    _loginState = LoginState.success;
    _loginError = null;
    _notify();
    return LoginSuccess(_session!);
  }

  /// Membersihkan sesi dan mengembalikan aplikasi ke keadaan awal.
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

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
