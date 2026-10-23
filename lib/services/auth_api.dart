import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Hasil pemanggilan API: berhasil, gagal, atau tidak tersedia.
sealed class AuthResult {
  const AuthResult();
}

/// Berhasil — [user] berisi data profil contoh dari randomuser.me.
class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  final Map<String, dynamic> user;
}

/// Gagal — [message] menjelaskan penyebabnya dan layak ditampilkan.
class AuthFailure extends AuthResult {
  const AuthFailure(this.message);

  final String message;
}

/// Service pemanggilan API acak randomuser.me.
///
/// **Penting:** API ini hanya menyediakan **profil contoh**. Autentikasi
/// yang dipakai aplikasi adalah simulasi, bukan autentikasi kampus resmi.
class AuthApi {
  const AuthApi({this.timeout = const Duration(seconds: 10), this.client});

  static const String baseUrl = 'https://randomuser.me/api/';

  final Duration timeout;

  /// Klien HTTP opsional - berguna untuk pengujian.
  final http.Client? client;

  Future<AuthResult> fetchRandomUser() async {
    final uri = Uri.parse('$baseUrl?results=1&nat=id');
    http.Client? activeClient;

    try {
      activeClient = client ?? http.Client();
      final response = await activeClient.get(uri).timeout(timeout);

      if (response.statusCode != 200) {
        return AuthFailure(
          'Server API acak merespons status ${response.statusCode}. '
          'Coba lagi beberapa saat lagi.',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const AuthFailure('Respons API tidak dikenali.');
      }

      final results = decoded['results'];
      if (results is! List || results.isEmpty) {
        return const AuthFailure('API acak tidak mengembalikan data pengguna.');
      }

      final user = results.first;
      if (user is! Map<String, dynamic>) {
        return const AuthFailure('Data pengguna dari API tidak valid.');
      }

      return AuthSuccess(user);
    } on TimeoutException {
      return AuthFailure(
        'Permintaan ke API acak melebihi batas waktu '
        '(${timeout.inSeconds} detik).',
      );
    } on FormatException {
      return const AuthFailure('Respons API acak tidak dapat dibaca.');
    } catch (error) {
      return AuthFailure('Gagal menghubungi API acak: $error');
    } finally {
      if (client == null) activeClient?.close();
    }
  }
}
