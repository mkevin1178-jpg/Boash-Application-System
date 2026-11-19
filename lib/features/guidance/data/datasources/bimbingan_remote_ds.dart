import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/bimbingan_model.dart';

abstract class BimbinganRemoteDataSource {
  Future<List<Bimbingan>> fetchByNpm(String npm);
}

class BimbinganRemoteDataSourceImpl implements BimbinganRemoteDataSource {
  BimbinganRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<Bimbingan>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Bimbingan tidak dapat dimuat.',
      );
    }
    final rows = await _api.fetchList(
      ApiConfig.bimbinganUri(trimmed),
      'bimbingan',
    );
    return rows.map(Bimbingan.fromJson).toList(growable: false);
  }
}
