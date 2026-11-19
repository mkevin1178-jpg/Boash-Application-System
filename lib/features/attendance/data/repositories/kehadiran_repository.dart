import '../../../../core/error/failure.dart';
import '../datasources/kehadiran_remote_ds.dart';
import '../models/kehadiran_model.dart';

abstract class KehadiranRepository {
  Future<List<Kehadiran>> fetchByNpm(String npm);

  Future<Kehadiran> create(KehadiranRequest request);
}

class KehadiranRepositoryImpl implements KehadiranRepository {
  const KehadiranRepositoryImpl(this._remote);

  final KehadiranRemoteDataSource _remote;

  @override
  Future<List<Kehadiran>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Kehadiran tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmed);
      // MockAPI dapat mengabaikan query, jadi filter ulang di client.
      return List<Kehadiran>.unmodifiable(
        records.where((item) => item.userid.trim() == trimmed),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }

  @override
  Future<Kehadiran> create(KehadiranRequest request) async {
    if (request.npm.trim().isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Kehadiran tidak dapat dikirim.',
      );
    }
    try {
      return await _remote.create(request);
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
