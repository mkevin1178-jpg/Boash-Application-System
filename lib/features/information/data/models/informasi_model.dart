import '../../../../core/json_parser.dart';

/// Satu record `GET /informasi`.
///
/// `tgl_posting_informasi` bisa null pada data saat ini, jadi tanggal ditangani
/// nullable. Endpoint tidak punya field kategori; `informasi_dari` dipakai
/// sebagai sumber informasi.
class Informasi {
  const Informasi({
    required this.idInformasi,
    required this.kdProgstudi,
    required this.judul,
    required this.isi,
    required this.tglPostingRaw,
    required this.tglPosting,
    required this.informasiDari,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    final tanggal = ApiJson.text(json['tgl_posting_informasi']);
    return Informasi(
      idInformasi: ApiJson.text(json['id_informasi']),
      kdProgstudi: ApiJson.integer(json['kd_progstudi']),
      judul: ApiJson.text(json['judul_informasi']),
      isi: ApiJson.text(json['isi_informasi']),
      tglPostingRaw: tanggal,
      tglPosting: ApiJson.date(tanggal),
      informasiDari: ApiJson.text(json['informasi_dari']),
    );
  }

  final String idInformasi;
  final int kdProgstudi;
  final String judul;
  final String isi;
  final String tglPostingRaw;
  final DateTime? tglPosting;
  final String informasiDari;

  /// Ringkasan singkat dari isi informasi API.
  String get ringkasan {
    const max = 120;
    if (isi.length <= max) return isi;
    return '${isi.substring(0, max).trimRight()}…';
  }
}
