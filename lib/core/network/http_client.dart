import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../error/failure.dart';

/// Pembungkus tipis `http.Client` dengan timeout dan error handling seragam.
///
/// Kelas ini sengaja tidak memakai `dart:io` agar tetap aman dikompilasi
/// untuk Flutter Web. `http.ClientException` dipakai sebagai penanda masalah
/// jaringan lintas platform.
class AppHttpClient {
  AppHttpClient({http.Client? client, this.timeout = ApiConfig.timeout})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<http.Response> get(Uri uri) async {
    try {
      return await _client.get(uri).timeout(timeout);
    } on TimeoutException catch (error) {
      throw TimeoutFailure(cause: error);
    } on http.ClientException catch (error) {
      throw NetworkFailure(cause: error);
    } on Failure {
      rethrow;
    } catch (error) {
      throw NetworkFailure(cause: error);
    }
  }

  /// POST JSON dengan header dan timeout yang sama seperti [get].
  Future<http.Response> post(Uri uri, Object body) async {
    try {
      return await _client
          .post(
            uri,
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException catch (error) {
      throw TimeoutFailure(cause: error);
    } on http.ClientException catch (error) {
      throw NetworkFailure(cause: error);
    } on Failure {
      rethrow;
    } catch (error) {
      throw NetworkFailure(cause: error);
    }
  }

  void close() => _client.close();
}
