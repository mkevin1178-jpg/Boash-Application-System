import '../../../../core/error/failure.dart';
import '../../../../core/json_parser.dart';
import '../datasources/finance_remote_ds.dart';
import '../models/finance_model.dart';

/// Status izin input KRS dari data Finance.
enum KrsAccessStatus { granted, pending, notGranted, unverifiable }

/// Hasil pemeriksaan izin KRS untuk satu NPM.
class KrsAccess {
  const KrsAccess({required this.status, required this.message});

  KrsAccess.unverifiable(String message)
    : this(status: KrsAccessStatus.unverifiable, message: message);

  static const String deniedMessage =
      'Akses pengisian KRS belum diberikan oleh bagian Finance. Silakan '
      'hubungi bagian Finance untuk mendapatkan persetujuan.';
  static const String pendingMessage =
      'Izin pengisian KRS sedang menunggu persetujuan bagian Finance.';
  static const String missingFieldMessage =
      'API Finance belum menyediakan field status persetujuan/input KRS. '
      'Akses tetap tertutup sampai backend menyediakan status izin eksplisit.';

  final KrsAccessStatus status;
  final String message;

  bool get canInputKrs => status == KrsAccessStatus.granted;
}

abstract class FinanceRepository {
  Future<List<FinancePayment>> fetchByNpm(String npm);

  /// Memeriksa izin KRS khusus untuk [npm].
  /// Kegagalan API tidak pernah menghasilkan akses granted.
  Future<KrsAccess> checkKrsAccess(String npm);
}

class FinanceRepositoryImpl implements FinanceRepository {
  const FinanceRepositoryImpl(this._remote);

  final FinanceRemoteDataSource _remote;

  static const List<String> _permissionTokens = <String>[
    'izin',
    'setuju',
    'persetujuan',
    'approve',
    'approval',
    'permission',
    'granted',
    'allowed',
    'akses',
  ];

  static const List<String> _grantedValues = <String>[
    '1',
    'true',
    'ya',
    'disetujui',
    'setuju',
    'approved',
    'approval',
    'granted',
    'diizinkan',
    'izin',
    'diberikan',
    'allowed',
  ];

  static const List<String> _pendingValues = <String>[
    'pending',
    'menunggu',
    'diproses',
    'process',
    'waiting',
    'inprogress',
  ];

  static const List<String> _deniedValues = <String>[
    '0',
    'false',
    'tidak',
    'belum',
    'ditolak',
    'denied',
    'rejected',
    'tidakdisetujui',
    'tidakdiizinkan',
  ];

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

  @override
  Future<KrsAccess> checkKrsAccess(String npm) async {
    final trimmed = npm.trim();
    if (trimmed.isEmpty) {
      return KrsAccess.unverifiable(
        'NPM tidak tersedia. Izin KRS tidak dapat diverifikasi.',
      );
    }

    try {
      final rows = await _remote.fetchRawByNpm(trimmed);
      final ownRows = rows
          .where((row) => ApiJson.text(row['npm']).trim() == trimmed)
          .toList(growable: false);

      if (ownRows.isEmpty) {
        return const KrsAccess(
          status: KrsAccessStatus.notGranted,
          message: KrsAccess.deniedMessage,
        );
      }

      ownRows.sort((a, b) => _entryOrder(a).compareTo(_entryOrder(b)));
      final permission = _findPermissionField(ownRows.last);
      if (permission == null) {
        return KrsAccess.unverifiable(KrsAccess.missingFieldMessage);
      }
      return _interpret(permission.value);
    } on Failure catch (failure) {
      return KrsAccess.unverifiable(
        'Gagal memverifikasi izin KRS: ${failure.message}',
      );
    } catch (error) {
      return KrsAccess.unverifiable('Gagal memverifikasi izin KRS: $error');
    }
  }

  String _entryOrder(Map<String, dynamic> row) {
    final date = ApiJson.text(row['dentry']);
    final id = ApiJson.integer(row['nid']);
    return '$date|${id.toString().padLeft(12, '0')}';
  }

  MapEntry<String, Object?>? _findPermissionField(Map<String, dynamic> row) {
    for (final entry in row.entries) {
      final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (!key.contains('krs')) continue;
      if (!_permissionTokens.any(key.contains)) continue;
      return MapEntry<String, Object?>(entry.key, entry.value);
    }
    return null;
  }

  KrsAccess _interpret(Object? value) {
    if (value is bool) {
      return value
          ? const KrsAccess(
              status: KrsAccessStatus.granted,
              message: 'Izin pengisian KRS telah diberikan bagian Finance.',
            )
          : const KrsAccess(
              status: KrsAccessStatus.notGranted,
              message: KrsAccess.deniedMessage,
            );
    }

    if (value is num) {
      if (value == 1) {
        return const KrsAccess(
          status: KrsAccessStatus.granted,
          message: 'Izin pengisian KRS telah diberikan bagian Finance.',
        );
      }
      if (value == 0) {
        return const KrsAccess(
          status: KrsAccessStatus.notGranted,
          message: KrsAccess.deniedMessage,
        );
      }
      return KrsAccess.unverifiable(KrsAccess.missingFieldMessage);
    }

    final text = ApiJson.text(value)
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    if (text.isEmpty) {
      return KrsAccess.unverifiable(KrsAccess.missingFieldMessage);
    }
    if (_deniedValues.any(text.contains)) {
      return const KrsAccess(
        status: KrsAccessStatus.notGranted,
        message: KrsAccess.deniedMessage,
      );
    }
    if (_pendingValues.any(text.contains)) {
      return const KrsAccess(
        status: KrsAccessStatus.pending,
        message: KrsAccess.pendingMessage,
      );
    }
    if (_grantedValues.any(text.contains)) {
      return const KrsAccess(
        status: KrsAccessStatus.granted,
        message: 'Izin pengisian KRS telah diberikan bagian Finance.',
      );
    }
    return KrsAccess.unverifiable(KrsAccess.missingFieldMessage);
  }
}
