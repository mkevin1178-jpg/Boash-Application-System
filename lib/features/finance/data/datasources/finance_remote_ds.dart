import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_fetcher.dart';
import '../../../../core/network/http_client.dart';
import '../models/finance_model.dart';

abstract class FinanceRemoteDataSource {
  Future<List<FinancePayment>> fetchByNpm(String npm);

  /// Data mentah untuk pemeriksaan field izin KRS yang benar-benar ada
  /// pada respons API.
  Future<List<Map<String, dynamic>>> fetchRawByNpm(String npm);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  FinanceRemoteDataSourceImpl({AppHttpClient? client})
    : _api = ApiFetcher(client ?? AppHttpClient());

  final ApiFetcher _api;

  @override
  Future<List<FinancePayment>> fetchByNpm(String npm) async {
    final rows = await fetchRawByNpm(npm);
    return rows.map(FinancePayment.fromJson).toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRawByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Data keuangan tidak dapat dimuat.',
      );
    }
    return _api.fetchList(ApiConfig.financeUri(trimmed), 'pembayaran');
  }
}
