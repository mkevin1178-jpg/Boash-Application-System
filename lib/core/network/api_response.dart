import 'dart:convert';

import '../error/failure.dart';

/// Decode body JSON yang dipakai bersama oleh seluruh data source BAS.
class ApiResponse {
  const ApiResponse._();

  /// Respons daftar harus berupa array of object.
  static List<Map<String, dynamic>> decodeList(String body) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (error) {
      throw InvalidResponseFailure(
        message: 'Data dari server tidak dapat dibaca. Coba lagi nanti.',
        cause: error,
      );
    }

    if (decoded is! List) {
      throw const InvalidResponseFailure(
        message: 'Data dari server tidak dapat dibaca. Coba lagi nanti.',
      );
    }

    final result = <Map<String, dynamic>>[];
    for (final item in decoded) {
      if (item is Map) result.add(Map<String, dynamic>.from(item));
    }
    if (result.isEmpty && decoded.isNotEmpty) {
      throw const InvalidResponseFailure(
        message: 'Data dari server tidak dapat dibaca. Coba lagi nanti.',
      );
    }
    return result;
  }

  /// Respons POST harus berupa object.
  static Map<String, dynamic> decodeMap(String body) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (error) {
      throw InvalidResponseFailure(
        message: 'Balasan server tidak dapat dibaca. Coba lagi nanti.',
        cause: error,
      );
    }

    if (decoded is! Map) {
      throw const InvalidResponseFailure(
        message: 'Balasan server tidak dapat dibaca. Coba lagi nanti.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }
}
