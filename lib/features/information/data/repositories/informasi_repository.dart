import '../../../../core/error/failure.dart';
import '../datasources/informasi_remote_ds.dart';
import '../models/informasi_model.dart';

abstract class InformasiRepository {
  Future<List<Informasi>> fetchAll();
}

class InformasiRepositoryImpl implements InformasiRepository {
  const InformasiRepositoryImpl(this._remote);

  final InformasiRemoteDataSource _remote;

  @override
  Future<List<Informasi>> fetchAll() async {
    try {
      return List<Informasi>.unmodifiable(await _remote.fetchAll());
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
