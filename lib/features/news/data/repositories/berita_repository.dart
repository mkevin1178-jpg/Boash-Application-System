import '../../../../core/error/failure.dart';
import '../datasources/berita_remote_ds.dart';
import '../models/berita_model.dart';

abstract class BeritaRepository {
  Future<List<Berita>> fetchAll();
}

class BeritaRepositoryImpl implements BeritaRepository {
  const BeritaRepositoryImpl(this._remote);

  final BeritaRemoteDataSource _remote;

  @override
  Future<List<Berita>> fetchAll() async {
    try {
      return List<Berita>.unmodifiable(await _remote.fetchAll());
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
