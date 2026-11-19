import '../../../../core/error/failure.dart';
import '../datasources/finance_remote_ds.dart';
import '../models/finance_model.dart';

abstract class FinanceRepository {
  Future<List<FinancePayment>> fetchByNpm(String npm);
}

class FinanceRepositoryImpl implements FinanceRepository {
  const FinanceRepositoryImpl(this._remote);

  final FinanceRemoteDataSource _remote;

  @override
  Future<List<FinancePayment>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Data keuangan tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmed);
      return List<FinancePayment>.unmodifiable(
        records.where((item) => item.npm.trim() == trimmed),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
