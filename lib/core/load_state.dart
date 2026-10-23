/// Status pemuatan data yang seragam untuk seluruh layar.
///
/// Pola tunggal: `idle → loading → success | error`. Layar yang memakai
/// [LoadState] selalu punya tampilan pemuatan, tampilan error dengan
/// tombol coba lagi, dan tampilan data kosong.
sealed class LoadState<T> {
  const LoadState();
}

/// Belum ada permintaan yang dijalankan.
class LoadIdle<T> extends LoadState<T> {
  const LoadIdle();
}

/// Permintaan sedang berjalan.
class LoadLoading<T> extends LoadState<T> {
  const LoadLoading();
}

/// Permintaan berhasil; [data] berisi hasil.
class LoadSuccess<T> extends LoadState<T> {
  const LoadSuccess(this.data);

  final T data;
}

/// Permintaan gagal; [message] menjelaskan penyebabnya.
class LoadError<T> extends LoadState<T> {
  const LoadError(this.message);

  final String message;
}
