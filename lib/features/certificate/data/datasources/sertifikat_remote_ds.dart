import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/sertifikat_model.dart';

abstract class SertifikatRemoteDataSource {
  Future<List<Sertifikat>> fetchByNpm(String npm);

  Future<Sertifikat> create(SertifikatRequest request);
}

class SertifikatRemoteDataSourceImpl implements SertifikatRemoteDataSource {
  SertifikatRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<Sertifikat>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Sertifikat tidak dapat dimuat.',
      );
    }
    final rows = await _api.fetchList(
      ApiConfig.sertifikatUri(trimmed),
      'sertifikat',
    );
    return rows.map(Sertifikat.fromJson).toList(growable: false);
  }

  @override
  Future<Sertifikat> create(SertifikatRequest request) async {
    final row = await _api.postMap(
      ApiConfig.postUri(ApiConfig.sertifikatPath),
      request.toJson(),
      'sertifikat',
    );
    return Sertifikat.fromJson(row);
  }
}
