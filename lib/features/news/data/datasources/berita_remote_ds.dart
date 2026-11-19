import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/berita_model.dart';

abstract class BeritaRemoteDataSource {
  Future<List<Berita>> fetchAll();
}

class BeritaRemoteDataSourceImpl implements BeritaRemoteDataSource {
  BeritaRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<Berita>> fetchAll() async {
    final rows = await _api.fetchList(ApiConfig.beritaUri(), 'berita');
    return rows.map(Berita.fromJson).toList(growable: false);
  }
}
