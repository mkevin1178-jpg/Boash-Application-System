import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_view.dart';
import 'async_controller.dart';
import 'load_state.dart';

/// Widget pembungkus [AsyncController] yang merender status yang berbeda
/// secara seragam: loading, error (dengan tombol coba lagi), dan success.
class AsyncBuilder<T> extends StatelessWidget {
  const AsyncBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.isEmpty,
    this.emptyTitle = 'Belum ada data',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingMessage,
    this.errorTitle = 'Gagal memuat data',
  });

  final AsyncController<T> controller;
  final Widget Function(BuildContext context, T data) builder;

  /// Penentu apakah [data] dianggap kosong (menampilkan empty state).
  final bool Function(T data)? isEmpty;

  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final String? loadingMessage;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;

        return switch (state) {
          LoadIdle<T>() => LoadingView(message: loadingMessage),
          LoadLoading<T>() => LoadingView(message: loadingMessage),
          LoadError<T>(:final message) => ErrorState(
            title: errorTitle,
            message: message,
            onRetry: controller.load,
          ),
          LoadSuccess<T>(:final data) => _buildSuccess(context, data),
        };
      },
    );
  }

  Widget _buildSuccess(BuildContext context, T data) {
    final empty = isEmpty?.call(data) ?? false;
    if (empty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
      );
    }
    return builder(context, data);
  }
}
