import '../../../../core/error/failure.dart';
import '../datasources/sertifikat_remote_ds.dart';
import '../models/sertifikat_model.dart';

abstract class SertifikatRepository {
  Future<List<Sertifikat>> fetchByNpm(String npm);

  Future<Sertifikat> create(SertifikatRequest request);
}

class SertifikatRepositoryImpl implements SertifikatRepository {
  const SertifikatRepositoryImpl(this._remote);

  final SertifikatRemoteDataSource _remote;

  @override
  Future<List<Sertifikat>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Sertifikat tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmed);
      return List<Sertifikat>.unmodifiable(
        records.where((item) => item.npm.trim() == trimmed),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }

  @override
  Future<Sertifikat> create(SertifikatRequest request) async {
    if (request.npm.trim().isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. Sertifikat tidak dapat dikirim.',
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
