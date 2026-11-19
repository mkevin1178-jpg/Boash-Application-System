import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/kehadiran_model.dart';

abstract class KehadiranRemoteDataSource {
  Future<List<Kehadiran>> fetchByNpm(String npm);

  Future<Kehadiran> create(KehadiranRequest request);
}

class KehadiranRemoteDataSourceImpl implements KehadiranRemoteDataSource {
  KehadiranRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<Kehadiran>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Kehadiran tidak dapat dimuat.',
      );
    }
    final rows = await _api.fetchList(
      ApiConfig.kehadiranUri(trimmed),
      'kehadiran',
    );
    return rows.map(Kehadiran.fromJson).toList(growable: false);
  }

  @override
  Future<Kehadiran> create(KehadiranRequest request) async {
    final row = await _api.postMap(
      ApiConfig.postUri(ApiConfig.kehadiranPath),
      request.toJson(),
      'kehadiran',
    );
    return Kehadiran.fromJson(row);
  }
}
