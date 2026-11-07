/// Satu record mahasiswa dari endpoint `/mahasiswa`.
///
/// API mengirim hampir semua field sebagai string dan sebagian bisa kosong
/// atau `null`. Semua parsing dibuat aman agar satu record kotor tidak
/// membuat aplikasi crash. `nama` selalu di-trim karena API menambahkan spasi
/// di akhir.
class Mahasiswa {
  const Mahasiswa({
    required this.npm,
    required this.nama,
    required this.tempatLahir,
    required this.tglLahir,
    required this.agama,
    required this.kelamin,
    required this.alamat,
    required this.handphone,
    required this.email,
    required this.kdProgstudi,
    required this.kdJenjang,
    required this.kdKelas,
    required this.tahunMasuk,
    required this.foto,
    required this.status,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      npm: _toText(json['npm']),
      nama: _toText(json['nama']),
      tempatLahir: _toText(json['tempat_lahir']),
      tglLahir: _toText(json['tgl_lahir']),
      agama: _toText(json['agama']),
      kelamin: _toText(json['kelamin']),
      alamat: _toText(json['alamat']),
      handphone: _toText(json['handphone']),
      email: _toText(json['email']),
      kdProgstudi: _toText(json['kd_progstudi']),
      kdJenjang: _toText(json['kd_jenjang']),
      kdKelas: _toText(json['kd_kelas']),
      tahunMasuk: _toText(json['tahun_masuk']),
      foto: _toText(json['foto']),
      status: _toText(json['status']),
    );
  }

  final String npm;
  final String nama;
  final String tempatLahir;
  final String tglLahir;
  final String agama;
  final String kelamin;
  final String alamat;
  final String handphone;
  final String email;
  final String kdProgstudi;
  final String kdJenjang;
  final String kdKelas;
  final String tahunMasuk;

  /// Nama file foto dari API, mis. `aa_sof.png` (bukan URL penuh).
  final String foto;
  final String status;

  /// Parsing teks aman: `null` dan teks `"null"` menjadi string kosong.
  static String _toText(Object? value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }
}
