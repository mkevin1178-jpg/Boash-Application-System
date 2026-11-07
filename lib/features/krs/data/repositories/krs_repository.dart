import '../../../../core/error/failure.dart';
import '../datasources/krs_remote_ds.dart';
import '../models/krs_model.dart';

/// Satu-satunya pintu data KRS bagi presentation layer.
abstract class KrsRepository {
  Future<List<KrsItem>> fetchByNpm(String npm);
}

/// Implementasi repository di atas [KrsRemoteDataSource].
///
/// Tanggung jawab:
/// - memfilter ulang hasil berdasarkan NPM (MockAPI kadang mengabaikan query);
/// - menghapus duplikat `(kd_matkul, thn_akademik, semester)`;
/// - mengurutkan per tahun akademik, semester, lalu kode matkul.
class KrsRepositoryImpl implements KrsRepository {
  const KrsRepositoryImpl(this._remote);

  final KrsRemoteDataSource _remote;

  @override
  Future<List<KrsItem>> fetchByNpm(String npm) async {
    final trimmedNpm = npm.trim();
    if (trimmedNpm.isEmpty) {
      throw const InvalidRequestFailure(
        message: 'NPM tidak tersedia. KRS tidak dapat dimuat.',
      );
    }

    try {
      final records = await _remote.fetchByNpm(trimmedNpm);

      final filtered = records.where((item) => item.npm.trim() == trimmedNpm);
      final deduped = _dedupe(filtered)..sort(_compare);

      return List<KrsItem>.unmodifiable(deduped);
    } on Failure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(cause: error);
    }
  }

  static List<KrsItem> _dedupe(Iterable<KrsItem> items) {
    final byKey = <String, KrsItem>{};

    for (final item in items) {
      final key = '${item.kdMatkul}#${item.thnAkademik}#${item.semester}';
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = item;
      } else {
        byKey[key] = _prefer(existing, item);
      }
    }

    return byKey.values.toList();
  }

  /// Utamakan record `status == 1`; bila sama, pilih `id` numerik terkecil.
  static KrsItem _prefer(KrsItem a, KrsItem b) {
    if (a.statusRaw == 1 && b.statusRaw != 1) return a;
    if (b.statusRaw == 1 && a.statusRaw != 1) return b;
    return a.id <= b.id ? a : b;
  }

  static int _compare(KrsItem a, KrsItem b) {
    final year = a.thnAkademik.compareTo(b.thnAkademik);
    if (year != 0) return year;

    final semester = a.semester.compareTo(b.semester);
    if (semester != 0) return semester;

    return a.kdMatkul.compareTo(b.kdMatkul);
  }
}
