import 'dart:developer' as developer;

import '../error/failure.dart';
import 'api_response.dart';
import 'http_client.dart';

/// Pengambilan data HTTP bersama untuk seluruh fitur BAS.
///
/// Menangani status code, body kosong, dan decoding JSON sekali saja supaya
/// tiap data source tidak mengulang logika yang sama.
class ApiFetcher {
  const ApiFetcher(this._client);

  final AppHttpClient _client;

  Future<List<Map<String, dynamic>>> fetchList(Uri uri, String label) async {
    final response = await _client.get(uri);
    _checkStatus(response.statusCode, label);

    if (response.body.trim().isEmpty) {
      throw InvalidResponseFailure(
        message: 'Data $label tidak dapat dibaca. Coba lagi nanti.',
      );
    }
    return ApiResponse.decodeList(response.body);
  }

  Future<Map<String, dynamic>> postMap(
    Uri uri,
    Object body,
    String label,
  ) async {
    final response = await _client.post(uri, body);
    _checkStatus(response.statusCode, label);

    if (response.body.trim().isEmpty) {
      throw InvalidResponseFailure(
        message: 'Balasan $label tidak dapat dibaca. Coba lagi nanti.',
      );
    }
    return ApiResponse.decodeMap(response.body);
  }

  void _checkStatus(int statusCode, String label) {
    if (statusCode >= 200 && statusCode < 300) return;
    developer.log('[BAS API] $label HTTP $statusCode');
    throw ServerFailure(
      statusCode: statusCode,
      message: 'Server $label sedang bermasalah. Coba lagi beberapa saat lagi.',
      cause: 'HTTP $statusCode',
    );
  }
}
