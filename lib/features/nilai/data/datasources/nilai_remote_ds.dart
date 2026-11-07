import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_client.dart';
import '../models/nilai_model.dart';

/// Kontrak pengambilan nilai mentah dari API.
abstract class NilaiRemoteDataSource {
  Future<List<Nilai>> fetchByNpm(String npm);
}

/// Implementasi HTTP untuk endpoint `GET /nilai?npm=<NPM>`.
class NilaiRemoteDataSourceImpl implements NilaiRemoteDataSource {
  NilaiRemoteDataSourceImpl({AppHttpClient? client})
    : _client = client ?? AppHttpClient();

  final AppHttpClient _client;

  @override
  Future<List<Nilai>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure();
    }

    final response = await _client.get(ApiConfig.nilaiUri(trimmedNpm));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Detail teknis hanya untuk log, bukan untuk UI.
      debugPrint('[Nilai] HTTP ${response.statusCode} untuk NPM $trimmedNpm');
      throw ServerFailure(
        statusCode: response.statusCode,
        cause: 'HTTP ${response.statusCode}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const InvalidResponseFailure();
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      debugPrint('[Nilai] JSON tidak valid: $error');
      throw InvalidResponseFailure(cause: error);
    }

    if (decoded is! List) {
      debugPrint('[Nilai] Root JSON bukan List: ${decoded.runtimeType}');
      throw const InvalidResponseFailure();
    }

    final result = <Nilai>[];
    var mapCount = 0;

    for (final item in decoded) {
      if (item is! Map) continue;
      mapCount++;
      result.add(Nilai.fromJson(Map<String, dynamic>.from(item)));
    }

    if (mapCount == 0 && decoded.isNotEmpty) {
      throw const InvalidResponseFailure();
    }

    return result;
  }

  void close() => _client.close();
}
