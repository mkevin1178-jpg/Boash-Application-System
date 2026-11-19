import 'package:flutter/foundation.dart';

import 'error/failure.dart';
import 'load_state.dart';

/// Penjalankan POST dengan state yang bisa dipantau UI.
class SubmitController extends ChangeNotifier {
  SubmitState _state = const SubmitIdle();
  bool _running = false;
  bool _disposed = false;

  SubmitState get state => _state;
  bool get isSubmitting => _state is Submitting;

  /// Menjalankan [action]. Mengembalikan `true` hanya bila tidak ada error.
  Future<bool> run(Future<void> Function() action) async {
    if (_running) return false;
    _running = true;
    _set(const Submitting());
    try {
      await action();
      _set(const SubmitSuccess());
      return true;
    } catch (error) {
      final message = error is Failure
          ? error.message
          : error.toString().replaceFirst('Exception: ', '');
      _set(SubmitFailure(message));
      return false;
    } finally {
      _running = false;
    }
  }

  void reset() => _set(const SubmitIdle());

  void _set(SubmitState next) {
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
