import 'package:flutter/foundation.dart';

import 'load_state.dart';

/// Pemuat data berbasis [ChangeNotifier] (bawaan Flutter, tanpa package
/// tambahan).
///
/// Menjamin:
/// - hanya satu permintaan berjalan pada satu waktu (anti request ganda);
/// - state `loading`, `success`, dan `error` selalu tersedia untuk UI;
/// - `dispose()` aman dipanggil saat widget dibuang.
class AsyncController<T> extends ChangeNotifier {
  AsyncController(this.fetcher, {LoadState<T>? initialState})
    : _state = initialState ?? LoadIdle<T>();

  final Future<T> Function() fetcher;

  LoadState<T> _state;
  bool _disposed = false;
  bool _running = false;

  LoadState<T> get state => _state;

  bool get isLoading => _state is LoadLoading<T>;

  /// Menjalankan [fetcher] bila belum ada permintaan yang sedang berjalan.
  Future<void> load({bool force = false}) async {
    if (_running && !force) return;
    _running = true;
    _setState(LoadLoading<T>());
    try {
      final data = await fetcher();
      _setState(LoadSuccess<T>(data));
    } catch (error) {
      _setState(LoadError<T>(_describe(error)));
    } finally {
      _running = false;
    }
  }

  /// Mengganti data secara lokal (mis. setelah mutasi status tugas) tanpa
  /// memanggil ulang repository.
  void setData(T data) => _setState(LoadSuccess<T>(data));

  void _setState(LoadState<T> next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  String _describe(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
