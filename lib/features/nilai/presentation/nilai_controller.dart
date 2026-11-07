import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../data/repositories/nilai_repository.dart';
import '../domain/ips_calculator.dart';

/// State yang dirender oleh layar daftar nilai.
sealed class NilaiState {
  const NilaiState();
}

class NilaiLoading extends NilaiState {
  const NilaiLoading();
}

class NilaiEmpty extends NilaiState {
  const NilaiEmpty(this.message);

  final String message;
}

class NilaiError extends NilaiState {
  const NilaiError(this.message);

  final String message;
}

class NilaiLoaded extends NilaiState {
  const NilaiLoaded({required this.groups, required this.summary});

  final List<SemesterGroup> groups;
  final AcademicSummary summary;
}

/// ViewModel berbasis [ChangeNotifier] — mengikuti pola state management
/// bawaan proyek (tanpa menambah package Provider/Bloc).
class NilaiController extends ChangeNotifier {
  NilaiController({required this.repository, required this.npm});

  final NilaiRepository repository;
  final String npm;

  NilaiState _state = const NilaiLoading();
  bool _running = false;
  bool _disposed = false;

  NilaiState get state => _state;

  /// Memuat nilai dari repository.
  ///
  /// Saat pull-to-refresh, panggil dengan `force: true` agar data lama tetap
  /// terlihat selama request berjalan.
  Future<void> load({bool force = false}) async {
    if (_running) return;
    _running = true;

    final hasData = _state is NilaiLoaded;
    if (!force || !hasData) {
      _setState(const NilaiLoading());
    }

    try {
      final values = await repository.fetchByNpm(npm);

      if (values.isEmpty) {
        _setState(NilaiEmpty('Belum ada data nilai untuk NPM ${npm.trim()}.'));
        return;
      }

      final groups = IpsCalculator.groupBySemester(values);
      final summary = IpsCalculator.overall(values);
      _setState(NilaiLoaded(groups: groups, summary: summary));
    } on Failure catch (failure) {
      _setState(NilaiError(failure.message));
    } catch (error) {
      debugPrint('[Nilai] Kesalahan tak terduga: $error');
      _setState(
        const NilaiError('Terjadi kesalahan yang tidak diketahui. Coba lagi.'),
      );
    } finally {
      _running = false;
    }
  }

  void _setState(NilaiState next) {
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
