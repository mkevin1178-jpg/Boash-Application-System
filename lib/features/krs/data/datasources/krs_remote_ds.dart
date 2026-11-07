import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_client.dart';
import '../models/krs_model.dart';

/// Kontrak pengambilan data KRS mentah dari API.
abstract class KrsRemoteDataSource {
  Future<List<KrsItem>> fetchByNpm(String npm);
}

/// Implementasi HTTP untuk endpoint `GET /krs?npm=<NPM>`.
class KrsRemoteDataSourceImpl implements KrsRemoteDataSource {
  KrsRemoteDataSourceImpl({AppHttpClient? client})
    : _client = client ?? AppHttpClient();

  final AppHttpClient _client;

  @override
  Future<List<KrsItem>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. KRS tidak dapat dimuat.',
      );
    }

    final response = await _client.get(ApiConfig.krsUri(trimmedNpm));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('[KRS] HTTP ${response.statusCode} untuk NPM $trimmedNpm');
      throw ServerFailure(
        statusCode: response.statusCode,
        message:
            'Server akademik sedang bermasalah. Coba lagi beberapa saat lagi.',
        cause: 'HTTP ${response.statusCode}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const InvalidResponseFailure(
        message: 'Data KRS tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      debugPrint('[KRS] JSON tidak valid: $error');
      throw InvalidResponseFailure(
        message: 'Data KRS tidak dapat dibaca. Coba lagi nanti.',
        cause: error,
      );
    }

    if (decoded is! List) {
      debugPrint('[KRS] Root JSON bukan List: ${decoded.runtimeType}');
      throw const InvalidResponseFailure(
        message: 'Data KRS tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    final result = <KrsItem>[];
    var mapCount = 0;

    for (final item in decoded) {
      if (item is! Map) continue;
      mapCount++;
      result.add(KrsItem.fromJson(Map<String, dynamic>.from(item)));
    }

    if (mapCount == 0 && decoded.isNotEmpty) {
      throw const InvalidResponseFailure(
        message: 'Data KRS tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    return result;
  }

  void close() => _client.close();
}
