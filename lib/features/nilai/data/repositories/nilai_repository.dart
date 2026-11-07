import '../../../../core/error/failure.dart';
import '../datasources/nilai_remote_ds.dart';
import '../models/nilai_model.dart';

/// Satu-satunya pintu data nilai bagi presentation layer.
abstract class NilaiRepository {
  Future<List<Nilai>> fetchByNpm(String npm);
}

/// Implementasi repository di atas [NilaiRemoteDataSource].
class NilaiRepositoryImpl implements NilaiRepository {
  const NilaiRepositoryImpl(this._remote);

  final NilaiRemoteDataSource _remote;

  @override
  Future<List<Nilai>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure();
    }

    try {
      final records = await _remote.fetchByNpm(trimmedNpm);

      // MockAPI kadang mengabaikan query `npm`, jadi filter tetap dilakukan
      // di sisi client agar mahasiswa tidak melihat nilai orang lain.
      return List<Nilai>.unmodifiable(
        records.where((nilai) => nilai.npm.trim() == trimmedNpm),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
