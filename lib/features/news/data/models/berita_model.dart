import '../../../../core/json_parser.dart';

/// Satu record `GET /berita`.
///
/// Endpoint hanya menyediakan judul, isi, tanggal posting, dan sumber.
/// Tidak ada field gambar maupun kategori, jadi UI tidak menampilkan keduanya.
class Berita {
  const Berita({
    required this.judul,
    required this.isi,
    required this.tglPostingRaw,
    required this.tglPosting,
    required this.beritaDari,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    final tanggal = ApiJson.text(json['tgl_posting_berita']);
    return Berita(
      judul: ApiJson.text(json['judul_berita']),
      isi: ApiJson.text(json['isi_berita']),
      tglPostingRaw: tanggal,
      tglPosting: ApiJson.date(tanggal),
      beritaDari: ApiJson.text(json['berita_dari']),
    );
  }

  final String judul;
  final String isi;
  final String tglPostingRaw;
  final DateTime? tglPosting;
  final String beritaDari;

  /// Ringkasan singkat dari isi berita API.
  String get ringkasan {
    const max = 130;
    if (isi.length <= max) return isi;
    return '${isi.substring(0, max).trimRight()}…';
  }
}
