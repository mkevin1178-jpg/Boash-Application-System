import '../../../../core/json_parser.dart';

/// Satu record `GET /bimbingan_data`.
///
/// Endpoint ini tidak menyediakan `id`, jam bimbingan, atau nama dosen.
/// Identifikasi dosen hanya lewat `nip`, sehingga UI menampilkan NIP apa
/// adanya tanpa mengarang nama. Field status (0/1) disimpan mentah.
class Bimbingan {
  const Bimbingan({
    required this.thnAkademik,
    required this.npm,
    required this.tglMulaiRaw,
    required this.tglMulai,
    required this.tglSelesaiRaw,
    required this.tglSelesai,
    required this.judul,
    required this.topik,
    required this.permasalahan,
    required this.nip,
    required this.proposal,
    required this.skProposal,
    required this.statusProposal,
    required this.tugasAkhir,
    required this.skTugasAkhir,
    required this.statusTugasAkhir,
    required this.statusData,
  });

  factory Bimbingan.fromJson(Map<String, dynamic> json) {
    final mulai = ApiJson.text(json['tgl_mulai']);
    final selesai = ApiJson.text(json['tgl_selesai']);
    return Bimbingan(
      thnAkademik: ApiJson.text(json['thn_akademik']),
      npm: ApiJson.text(json['npm']),
      tglMulaiRaw: mulai,
      tglMulai: ApiJson.date(mulai),
      tglSelesaiRaw: selesai,
      tglSelesai: ApiJson.date(selesai),
      judul: ApiJson.text(json['judul']),
      topik: ApiJson.text(json['topik']),
      permasalahan: ApiJson.text(json['permasalahan']),
      nip: ApiJson.text(json['nip']),
      proposal: ApiJson.integer(json['proposal']),
      skProposal: ApiJson.text(json['sk_proposal']),
      statusProposal: ApiJson.integer(json['status_proposal']),
      tugasAkhir: ApiJson.text(json['tugas_akhir']),
      skTugasAkhir: ApiJson.text(json['sk_tugas_akhir']),
      statusTugasAkhir: ApiJson.integer(json['status_tugas_akhir']),
      statusData: ApiJson.integer(json['status_data']),
    );
  }

  final String thnAkademik;
  final String npm;
  final String tglMulaiRaw;
  final DateTime? tglMulai;
  final String tglSelesaiRaw;
  final DateTime? tglSelesai;
  final String judul;
  final String topik;
  final String permasalahan;
  final String nip;
  final int proposal;
  final String skProposal;
  final int statusProposal;
  final String tugasAkhir;
  final String skTugasAkhir;
  final int statusTugasAkhir;
  final int statusData;

  /// Kunci tampilan karena endpoint tidak punya field `id`.
  String get displayKey => '$npm|$nip|$judul';
}
