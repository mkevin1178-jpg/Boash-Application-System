import '../../../../core/json_parser.dart';

/// Satu record `GET /sertifikat`.
///
/// `tanggal_sertifikat`, `tanggal_upload`, dan `tanggal_verifikasi` berupa
/// epoch detik; `tanggal_verifikasi` bisa null. `file_sertifikat` bisa URL,
/// tautan Drive, atau data URI base64.
class Sertifikat {
  const Sertifikat({
    required this.idSertifikat,
    required this.npm,
    required this.namaSertifikat,
    required this.jenisSertifikat,
    required this.kategoriSertifikat,
    required this.penyelenggara,
    required this.tingkatKegiatan,
    required this.tanggalSertifikat,
    required this.nomorSertifikat,
    required this.fileSertifikat,
    required this.tanggalUpload,
    required this.statusVerifikasi,
    required this.catatanVerifikasi,
    required this.diverifikasiOleh,
    required this.tanggalVerifikasi,
    required this.namaFile,
    required this.ekstensiFile,
  });

  factory Sertifikat.fromJson(Map<String, dynamic> json) {
    return Sertifikat(
      idSertifikat: ApiJson.text(json['id_sertifikat']),
      npm: ApiJson.text(json['npm']),
      namaSertifikat: ApiJson.text(json['nama_sertifikat']),
      jenisSertifikat: ApiJson.text(json['jenis_sertifikat']),
      kategoriSertifikat: ApiJson.text(json['kategori_sertifikat']),
      penyelenggara: ApiJson.text(json['penyelenggara']),
      tingkatKegiatan: ApiJson.text(json['tingkat_kegiatan']),
      tanggalSertifikat: ApiJson.unixSeconds(json['tanggal_sertifikat']),
      nomorSertifikat: ApiJson.text(json['nomor_sertifikat']),
      fileSertifikat: ApiJson.text(json['file_sertifikat']),
      tanggalUpload: ApiJson.unixSeconds(json['tanggal_upload']),
      statusVerifikasi: ApiJson.text(json['status_verifikasi']),
      catatanVerifikasi: ApiJson.text(json['catatan_verifikasi']),
      diverifikasiOleh: ApiJson.text(json['diverifikasi_oleh']),
      tanggalVerifikasi: ApiJson.unixSeconds(json['tanggal_verifikasi']),
      namaFile: ApiJson.text(json['nama_file']),
      ekstensiFile: ApiJson.text(json['ekstensi_file']),
    );
  }

  final String idSertifikat;
  final String npm;
  final String namaSertifikat;
  final String jenisSertifikat;
  final String kategoriSertifikat;
  final String penyelenggara;
  final String tingkatKegiatan;
  final DateTime? tanggalSertifikat;
  final String nomorSertifikat;
  final String fileSertifikat;
  final DateTime? tanggalUpload;
  final String statusVerifikasi;
  final String catatanVerifikasi;
  final String diverifikasiOleh;
  final DateTime? tanggalVerifikasi;
  final String namaFile;
  final String ekstensiFile;

  /// Apakah lampiran berupa tautan yang bisa dibuka pengguna.
  bool get isLink =>
      fileSertifikat.startsWith('http://') ||
      fileSertifikat.startsWith('https://');
}

/// Body `POST /sertifikat` — field sesuai record yang tersedia di API.
class SertifikatRequest {
  const SertifikatRequest({
    required this.npm,
    required this.namaSertifikat,
    required this.jenisSertifikat,
    required this.kategoriSertifikat,
    required this.penyelenggara,
    required this.tingkatKegiatan,
    required this.tanggalSertifikat,
    required this.nomorSertifikat,
    required this.fileSertifikat,
  });

  final String npm;
  final String namaSertifikat;
  final String jenisSertifikat;
  final String kategoriSertifikat;
  final String penyelenggara;
  final String tingkatKegiatan;
  final int tanggalSertifikat;
  final String nomorSertifikat;
  final String fileSertifikat;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'npm': npm.trim(),
    'nama_sertifikat': namaSertifikat.trim(),
    'jenis_sertifikat': jenisSertifikat.trim(),
    'kategori_sertifikat': kategoriSertifikat.trim(),
    'penyelenggara': penyelenggara.trim(),
    'tingkat_kegiatan': tingkatKegiatan.trim(),
    'tanggal_sertifikat': tanggalSertifikat,
    'nomor_sertifikat': nomorSertifikat.trim(),
    'file_sertifikat': fileSertifikat.trim(),
    'status_verifikasi': 'Menunggu Verifikasi',
  };
}
