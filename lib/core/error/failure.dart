/// Kegagalan terstruktur yang bisa dipetakan menjadi pesan UI.
///
/// Data source melempar turunan [Failure], repository meneruskannya, dan
/// presentation hanya perlu membaca [message] tanpa mengetahui detail HTTP.
sealed class Failure implements Exception {
  const Failure({required this.message, this.cause});

  /// Pesan yang aman ditampilkan ke pengguna.
  final String message;

  /// Penyebab teknis — hanya untuk log, jangan ditampilkan mentah ke UI.
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Tidak ada koneksi internet atau host tidak dapat dijangkau.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
    super.cause,
  });
}

/// Request melewati batas waktu yang ditentukan.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message =
        'Permintaan memakan waktu terlalu lama. Coba lagi beberapa saat lagi.',
    super.cause,
  });
}

/// Server merespons dengan status HTTP 4xx/5xx.
class ServerFailure extends Failure {
  const ServerFailure({
    required this.statusCode,
    super.message =
        'Server nilai sedang bermasalah. Coba lagi beberapa saat lagi.',
    super.cause,
  });

  final int statusCode;
}

/// Body respons bukan JSON valid atau formatnya tidak sesuai kontrak.
class InvalidResponseFailure extends Failure {
  const InvalidResponseFailure({
    super.message = 'Data nilai tidak dapat dibaca. Coba lagi nanti.',
    super.cause,
  });
}

/// Input tidak valid, misalnya NPM kosong.
class InvalidRequestFailure extends Failure {
  const InvalidRequestFailure({
    super.message = 'NPM tidak tersedia. Nilai tidak dapat dimuat.',
    super.cause,
  });
}

/// Kegagalan tak terduga supaya UI tetap punya pesan yang layak.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Terjadi kesalahan yang tidak diketahui. Coba lagi.',
    super.cause,
  });
}
