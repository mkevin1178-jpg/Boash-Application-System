import '../../../../core/error/failure.dart';
import '../datasources/mahasiswa_remote_ds.dart';
import '../models/mahasiswa_model.dart';

/// Satu-satunya pintu data mahasiswa bagi presentation layer.
abstract class MahasiswaRepository {
  Future<List<Mahasiswa>> fetchByNpm(String npm);
}

/// Implementasi repository di atas [MahasiswaRemoteDataSource].
class MahasiswaRepositoryImpl implements MahasiswaRepository {
  const MahasiswaRepositoryImpl(this._remote);

  final MahasiswaRemoteDataSource _remote;

  @override
  Future<List<Mahasiswa>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Profil mahasiswa tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmedNpm);

      // MockAPI kadang mengabaikan query `npm`, jadi filter tetap dilakukan
      // di sisi client agar data mahasiswa lain tidak ikut terbawa.
      return List<Mahasiswa>.unmodifiable(
        records.where((mahasiswa) => mahasiswa.npm.trim() == trimmedNpm),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
