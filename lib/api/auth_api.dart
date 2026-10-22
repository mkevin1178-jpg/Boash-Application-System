import 'dart:convert';

import 'package:http/http.dart' as http;

/// Memanggil API <https://randomuser.me/api/> untuk mengambil 1 user acak.
/// Dipakai halaman login untuk mencocokkan username & password.
class AuthApi {
  const AuthApi();

  Future<Map<String, dynamic>?> fetchRandomUser() async {
    try {
      final response = await http
          .get(Uri.parse('https://randomuser.me/api/'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.first as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
