import 'package:flutter/foundation.dart';

import '../core/error/failure.dart';
import '../core/load_state.dart';
import '../features/finance/data/datasources/finance_remote_ds.dart';
import '../features/finance/data/repositories/finance_repository.dart';
import '../features/mahasiswa/data/datasources/mahasiswa_remote_ds.dart';
import '../features/mahasiswa/data/repositories/mahasiswa_repository.dart';
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
/// NPM diverifikasi ke endpoint `/mahasiswa`: NPM yang tidak terdaftar
/// ditolak. **Password masih divalidasi demo di sisi client** karena API
/// tidak menyediakan field password maupun endpoint autentikasi. Jadi login
/// ini belum bisa disebut autentikasi terintegrasi.
///
/// **Catatan keamanan:**
/// - Untuk produksi: verifikasi password harus dilakukan di backend melalui
///   HTTPS dengan Argon2id/bcrypt/scrypt.
/// - Password tidak pernah dicetak ke log.
class AppController extends ChangeNotifier {
  AppController({
    MahasiswaRepository? mahasiswaRepository,
    FinanceRepository? financeRepository,
  }) : _mahasiswaRepository =
           mahasiswaRepository ??
           MahasiswaRepositoryImpl(MahasiswaRemoteDataSourceImpl()),
       _financeRepository =
           financeRepository ??
           FinanceRepositoryImpl(FinanceRemoteDataSourceImpl());

  final MahasiswaRepository _mahasiswaRepository;
  final FinanceRepository _financeRepository;

  bool _disposed = false;

  AppSession? _session;
  LoginState _loginState = LoginState.idle;
  String? _loginError;

  LoadState<KrsAccess> _krsAccessState = const LoadIdle<KrsAccess>();
  String? _krsAccessNpm;
  bool _krsAccessLoading = false;

  /// Sesi yang sedang aktif, atau `null` bila belum login.
  AppSession? get session => _session;

  bool get isLoggedIn => _session != null;

  LoginState get loginState => _loginState;

  String? get loginError => _loginError;

  /// Status izin KRS hanya berlaku untuk NPM pada sesi aktif.
  /// Bila sesi berganti, status lama otomatis dianggap tidak ada.
  LoadState<KrsAccess> get krsAccessState {
    if (_krsAccessNpm != _session?.npm) return const LoadIdle<KrsAccess>();
    return _krsAccessState;
  }

  bool get isKrsAccessLoading => krsAccessState is LoadLoading<KrsAccess>;

  // ------------------------------------------------------------------ login

  /// Melakukan login dengan NPM dan password.
  ///
  /// Alur:
  /// 1. Validasi format NPM dan password di client.
  /// 2. Cari NPM ke endpoint `/mahasiswa`.
  /// 3. Bila ditemukan, sesi diisi dari profil API. Bila tidak, login ditolak.
  ///
  /// **Password belum terhubung ke backend** — API tidak punya field
  /// password. Panjang minimal 4 karakter hanya aturan demo di client.
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

    // Izin KRS dari sesi sebelumnya tidak boleh terbawa ke NPM lain.
    _resetKrsAccess();
    _loginState = LoginState.submitting;
    _loginError = null;
    _notify();

    // Validasi panjang password minimal 4 karakter
    if (password.length < 4) {
      const message = 'Password terlalu pendek (minimal 4 karakter).';
      _loginState = LoginState.failure;
      _loginError = message;
      _notify();
      return const LoginFailure(message);
    }

    // Verifikasi NPM ke endpoint /mahasiswa. Password tidak dikirim karena
    // API memang tidak memiliki field password.
    try {
      final records = await _mahasiswaRepository.fetchByNpm(trimmedNpm);
      if (records.isEmpty) {
        return _fail('NPM tidak terdaftar.');
      }

      _session = AppSession.fromMahasiswa(records.first);
      _loginState = LoginState.success;
      _loginError = null;
      _notify();
      return LoginSuccess(_session!);
    } on Failure catch (failure) {
      return _fail(failure.message);
    } catch (error) {
      debugPrint('[Login] Kesalahan tak terduga: $error');
      return _fail('Gagal menghubungi server akademik. Coba lagi.');
    }
  }

  LoginFailure _fail(String message) {
    _loginState = LoginState.failure;
    _loginError = message;
    _notify();
    return LoginFailure(message);
  }

  // ------------------------------------------------------------- izin KRS

  /// Memastikan status izin KRS untuk NPM pada sesi aktif.
  ///
  /// Mengembalikan `null` hanya bila pemeriksaan sedang berjalan. Status yang
  /// gagal diverifikasi tetap dikembalikan sebagai [KrsAccess] tertutup.
  Future<KrsAccess?> loadKrsAccess({bool force = false}) async {
    final npm = _session?.npm.trim();
    if (npm == null || npm.isEmpty) {
      return KrsAccess.unverifiable(
        'NPM tidak tersedia. Izin KRS tidak dapat diverifikasi.',
      );
    }

    final current = krsAccessState;
    if (!force && current is LoadSuccess<KrsAccess>) return current.data;
    if (!force && _krsAccessLoading) return null;

    _krsAccessNpm = npm;
    _krsAccessLoading = true;
    _krsAccessState = const LoadLoading<KrsAccess>();
    _notify();

    try {
      final access = await _financeRepository.checkKrsAccess(npm);
      // Jangan simpan hasil pemeriksaan NPM lama bila sesi sudah berganti.
      if (_session?.npm == npm) {
        _krsAccessState = LoadSuccess<KrsAccess>(access);
        _notify();
      }
      return access;
    } catch (error) {
      final access = KrsAccess.unverifiable(
        'Status izin KRS tidak dapat diverifikasi: $error',
      );
      if (_session?.npm == npm) {
        _krsAccessState = LoadSuccess<KrsAccess>(access);
        _notify();
      }
      return access;
    } finally {
      _krsAccessLoading = false;
    }
  }

  void _resetKrsAccess() {
    _krsAccessNpm = null;
    _krsAccessState = const LoadIdle<KrsAccess>();
    _krsAccessLoading = false;
  }

  /// Membersihkan sesi dan mengembalikan aplikasi ke keadaan awal.
  void logout() {
    _session = null;
    _resetKrsAccess();
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
