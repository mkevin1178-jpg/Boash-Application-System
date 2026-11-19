import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/informasi_model.dart';

abstract class InformasiRemoteDataSource {
  Future<List<Informasi>> fetchAll();
}

class InformasiRemoteDataSourceImpl implements InformasiRemoteDataSource {
  InformasiRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<Informasi>> fetchAll() async {
    final rows = await _api.fetchList(ApiConfig.informasiUri(), 'informasi');
    return rows.map(Informasi.fromJson).toList(growable: false);
  }
}
