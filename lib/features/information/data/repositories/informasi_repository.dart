import '../../../../core/error/failure.dart';
import '../datasources/informasi_remote_ds.dart';
import '../models/informasi_model.dart';

abstract class InformasiRepository {
  /// Sumber informasi yang ditampilkan aplikasi sesuai field `informasi_dari`.
  static const String sofiSourceName = 'Sofi Putri Rahayu';

  Future<List<Informasi>> fetchAll();

  /// Hanya informasi yang `informasi_dari`-nya sama persis dengan
  /// [sofiSourceName] setelah trim.
  Future<List<Informasi>> fetchFromSofi() async {
    final records = await fetchAll();
    return List<Informasi>.unmodifiable(
      records.where((item) => item.informasiDari.trim() == sofiSourceName),
    );
  }
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

  @override
  Future<List<Informasi>> fetchFromSofi() async {
    try {
      final records = await _remote.fetchAll();
      return List<Informasi>.unmodifiable(
        records.where(
          (item) =>
              item.informasiDari.trim() == InformasiRepository.sofiSourceName,
        ),
      );
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }
}
