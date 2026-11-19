import '../../../../core/json_parser.dart';

/// Satu record `GET /kehadiran`.
///
/// Field `id` dan `group_id_nonreg` campur int/string, serta beberapa field
/// bisa null. Semua disimpan sebagai teks agar UI tidak perlu menebak tipe.
class Kehadiran {
  const Kehadiran({
    required this.id,
    required this.userid,
    required this.jamLogin,
    required this.kdMatkul,
    required this.kdKelas,
    required this.tanggalRaw,
    required this.tanggal,
    required this.keterangan,
    required this.session,
    required this.thnAkademik,
    required this.semester,
    required this.groupIdNonreg,
    required this.cuserUpdate,
    required this.dupdateRaw,
    required this.bhadirCheck,
    required this.bgantiCheck,
    required this.cuserPic,
    required this.dpicCheckRaw,
  });

  factory Kehadiran.fromJson(Map<String, dynamic> json) {
    final tanggalRaw = ApiJson.text(json['tanggal']);
    return Kehadiran(
      id: ApiJson.text(json['id']),
      userid: ApiJson.text(json['userid']),
      jamLogin: ApiJson.text(json['jam_login']),
      kdMatkul: ApiJson.text(json['kd_matkul']),
      kdKelas: ApiJson.text(json['kd_kelas']),
      tanggalRaw: tanggalRaw,
      tanggal: ApiJson.date(tanggalRaw),
      keterangan: ApiJson.text(json['keterangan']),
      session: ApiJson.text(json['session']),
      thnAkademik: ApiJson.text(json['thn_akademik']),
      semester: ApiJson.text(json['semester']),
      groupIdNonreg: ApiJson.text(json['group_id_nonreg']),
      cuserUpdate: ApiJson.text(json['cuser_update']),
      dupdateRaw: ApiJson.text(json['dupdate']),
      bhadirCheck: ApiJson.text(json['bhadir_check']),
      bgantiCheck: ApiJson.text(json['bganti_check']),
      cuserPic: ApiJson.text(json['cuser_pic']),
      dpicCheckRaw: ApiJson.text(json['dpic_check']),
    );
  }

  final String id;
  final String userid;
  final String jamLogin;
  final String kdMatkul;
  final String kdKelas;
  final String tanggalRaw;
  final DateTime? tanggal;
  final String keterangan;
  final String session;
  final String thnAkademik;
  final String semester;
  final String groupIdNonreg;
  final String cuserUpdate;
  final String dupdateRaw;
  final String bhadirCheck;
  final String bgantiCheck;
  final String cuserPic;
  final String dpicCheckRaw;
}

/// Body `POST /kehadiran` — hanya field yang terlihat pada respons API.
class KehadiranRequest {
  const KehadiranRequest({
    required this.npm,
    required this.kdMatkul,
    required this.kdKelas,
    required this.tanggal,
    required this.jamLogin,
    required this.session,
    required this.keterangan,
  });

  final String npm;
  final String kdMatkul;
  final String kdKelas;
  final String tanggal;
  final String jamLogin;
  final String session;
  final String keterangan;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userid': npm.trim(),
    'kd_matkul': kdMatkul.trim(),
    'kd_kelas': kdKelas.trim(),
    'tanggal': tanggal.trim(),
    'jam_login': jamLogin.trim(),
    'session': session.trim(),
    'keterangan': keterangan.trim(),
  };
}
