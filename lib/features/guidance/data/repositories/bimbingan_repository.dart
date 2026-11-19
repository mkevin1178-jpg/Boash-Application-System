import '../../../../core/error/failure.dart';
import '../datasources/bimbingan_remote_ds.dart';
import '../models/bimbingan_model.dart';

abstract class BimbinganRepository {
  Future<List<Bimbingan>> fetchByNpm(String npm);
}

class BimbinganRepositoryImpl implements BimbinganRepository {
  const BimbinganRepositoryImpl(this._remote);

  final BimbinganRemoteDataSource _remote;

  @override
  Future<List<Bimbingan>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Bimbingan tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmed);
      return List<Bimbingan>.unmodifiable(
        records.where((item) => item.npm.trim() == trimmed),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
