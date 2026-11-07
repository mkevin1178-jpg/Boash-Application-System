import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_client.dart';
import '../models/mahasiswa_model.dart';

/// Kontrak pengambilan data mahasiswa mentah dari API.
abstract class MahasiswaRemoteDataSource {
  Future<List<Mahasiswa>> fetchByNpm(String npm);
}

/// Implementasi HTTP untuk endpoint `GET /mahasiswa?npm=<NPM>`.
class MahasiswaRemoteDataSourceImpl implements MahasiswaRemoteDataSource {
  MahasiswaRemoteDataSourceImpl({AppHttpClient? client})
    : _client = client ?? AppHttpClient();

  final AppHttpClient _client;

  @override
  Future<List<Mahasiswa>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Profil mahasiswa tidak dapat dimuat.',
      );
    }

    final response = await _client.get(ApiConfig.mahasiswaUri(trimmedNpm));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '[Mahasiswa] HTTP ${response.statusCode} untuk NPM $trimmedNpm',
      );
      throw ServerFailure(
        statusCode: response.statusCode,
        message:
            'Server akademik sedang bermasalah. Coba lagi beberapa saat lagi.',
        cause: 'HTTP ${response.statusCode}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const InvalidResponseFailure(
        message: 'Data mahasiswa tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      debugPrint('[Mahasiswa] JSON tidak valid: $error');
      throw InvalidResponseFailure(
        message: 'Data mahasiswa tidak dapat dibaca. Coba lagi nanti.',
        cause: error,
      );
    }

    if (decoded is! List) {
      debugPrint('[Mahasiswa] Root JSON bukan List: ${decoded.runtimeType}');
      throw const InvalidResponseFailure(
        message: 'Data mahasiswa tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    final result = <Mahasiswa>[];
    var mapCount = 0;

    for (final item in decoded) {
      if (item is! Map) continue;
      mapCount++;
      result.add(Mahasiswa.fromJson(Map<String, dynamic>.from(item)));
    }

    if (mapCount == 0 && decoded.isNotEmpty) {
      throw const InvalidResponseFailure(
        message: 'Data mahasiswa tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    return result;
  }

  void close() => _client.close();
}
