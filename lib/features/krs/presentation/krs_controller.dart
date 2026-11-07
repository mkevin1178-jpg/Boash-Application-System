import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../shared/matkul_reference.dart';
import '../data/models/krs_model.dart';
import '../data/repositories/krs_repository.dart';

/// Satu kelompok KRS untuk tahun akademik + semester tertentu.
class KrsGroup {
  const KrsGroup({
    required this.thnAkademik,
    required this.semester,
    required this.items,
    required this.totalSks,
    required this.unknownCourseCodes,
  });

  final String thnAkademik;
  final int semester;
  final List<KrsItem> items;
  final int totalSks;
  final List<String> unknownCourseCodes;

  String get label {
    if (thnAkademik.isEmpty && semester == 0) return '-';
    final name = semester == 0
        ? 'Semester -'
        : (semester.isOdd ? 'Ganjil' : 'Genap');
    if (thnAkademik.isEmpty) return name;
    return 'TA $thnAkademik • $name';
  }

  bool get hasUnknownCourses => unknownCourseCodes.isNotEmpty;
}

/// State yang dirender oleh layar KRS.
sealed class KrsState {
  const KrsState();
}

class KrsLoading extends KrsState {
  const KrsLoading();
}

class KrsEmpty extends KrsState {
  const KrsEmpty(this.message);

  final String message;
}

class KrsError extends KrsState {
  const KrsError(this.message);

  final String message;
}

class KrsLoaded extends KrsState {
  const KrsLoaded(this.groups);

  final List<KrsGroup> groups;
}

/// ViewModel layar KRS berbasis [ChangeNotifier].
class KrsController extends ChangeNotifier {
  KrsController({required this.repository, required this.npm});

  final KrsRepository repository;
  final String npm;

  KrsState _state = const KrsLoading();
  bool _running = false;
  bool _disposed = false;

  KrsState get state => _state;

  Future<void> load({bool force = false}) async {
    if (_running) return;
    _running = true;

    final hasData = _state is KrsLoaded;
    if (!force || !hasData) {
      _setState(const KrsLoading());
    }

    try {
      final items = await repository.fetchByNpm(npm);

      if (items.isEmpty) {
        _setState(KrsEmpty('Belum ada data KRS untuk NPM ${npm.trim()}.'));
        return;
      }

      _setState(KrsLoaded(_group(items)));
    } on Failure catch (failure) {
      _setState(KrsError(failure.message));
    } catch (error) {
      debugPrint('[KRS] Kesalahan tak terduga: $error');
      _setState(
        const KrsError('Terjadi kesalahan yang tidak diketahui. Coba lagi.'),
      );
    } finally {
      _running = false;
    }
  }

  static List<KrsGroup> _group(List<KrsItem> items) {
    final grouped = <String, List<KrsItem>>{};

    for (final item in items) {
      final key = '${item.thnAkademik}#${item.semester}';
      grouped.putIfAbsent(key, () => <KrsItem>[]).add(item);
    }

    final groups = grouped.values.map((groupItems) {
      final sorted = List<KrsItem>.of(groupItems)
        ..sort((a, b) => a.kdMatkul.compareTo(b.kdMatkul));
      final first = sorted.first;

      var totalSks = 0;
      final unknown = <String>{};
      for (final item in sorted) {
        final sks = MatkulReference.sksOf(item.kdMatkul);
        if (sks == null || sks <= 0) {
          unknown.add(item.kdMatkul.isEmpty ? '-' : item.kdMatkul);
        } else {
          totalSks += sks;
        }
      }

      return KrsGroup(
        thnAkademik: first.thnAkademik,
        semester: first.semester,
        items: List<KrsItem>.unmodifiable(sorted),
        totalSks: totalSks,
        unknownCourseCodes: unknown.toList()..sort(),
      );
    }).toList();

    groups.sort((a, b) {
      final year = a.thnAkademik.compareTo(b.thnAkademik);
      if (year != 0) return year;
      return a.semester.compareTo(b.semester);
    });

    return List<KrsGroup>.unmodifiable(groups);
  }

  void _setState(KrsState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
