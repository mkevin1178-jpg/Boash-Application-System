import '../../../../core/json_parser.dart';

/// Satu record `GET /fin_mhs_payment`.
///
/// Api tidak menyediakan field status pembayaran eksplisit. Nilai `ntype`,
/// `bdeleted`, dan field audit lainnya disimpan apa adanya agar UI tidak
/// mengklaim status yang tidak ada di server. `npayment` dikirim sebagai
/// string angka sehingga di-parse dengan aman.
class FinancePayment {
  const FinancePayment({
    required this.nid,
    required this.npm,
    required this.thnAkademik,
    required this.semester,
    required this.dpaymentRaw,
    required this.dpayment,
    required this.npaymentRaw,
    required this.amount,
    required this.cketerangan,
    required this.cuserEntry,
    required this.dentry,
    required this.cuserUpdate,
    required this.dupdate,
    required this.bdeleted,
    required this.cuserDelete,
    required this.ddelete,
    required this.regId,
    required this.ntype,
  });

  factory FinancePayment.fromJson(Map<String, dynamic> json) {
    final dpayment = ApiJson.text(json['dpayment']);
    final npayment = ApiJson.text(json['npayment']);
    return FinancePayment(
      nid: ApiJson.text(json['nid']),
      npm: ApiJson.text(json['npm']),
      thnAkademik: ApiJson.text(json['thn_akademik']),
      semester: ApiJson.text(json['semester']),
      dpaymentRaw: dpayment,
      dpayment: ApiJson.date(dpayment),
      npaymentRaw: npayment,
      amount: ApiJson.number(npayment),
      cketerangan: ApiJson.text(json['cketerangan']),
      cuserEntry: ApiJson.text(json['cuser_entry']),
      dentry: ApiJson.text(json['dentry']),
      cuserUpdate: ApiJson.text(json['cuser_update']),
      dupdate: ApiJson.text(json['dupdate']),
      bdeleted: ApiJson.text(json['bdeleted']),
      cuserDelete: ApiJson.text(json['cuser_delete']),
      ddelete: ApiJson.text(json['ddelete']),
      regId: ApiJson.text(json['reg_id']),
      ntype: ApiJson.text(json['ntype']),
    );
  }

  final String nid;
  final String npm;
  final String thnAkademik;
  final String semester;
  final String dpaymentRaw;
  final DateTime? dpayment;
  final String npaymentRaw;
  final double amount;
  final String cketerangan;
  final String cuserEntry;
  final String dentry;
  final String cuserUpdate;
  final String dupdate;
  final String bdeleted;
  final String cuserDelete;
  final String ddelete;
  final String regId;
  final String ntype;

  /// Nominal tampilan tanpa mengubah nilai asli dari API.
  String get amountLabel {
    final value = amount.toStringAsFixed(0);
    final sign = value.startsWith('-') ? '-' : '';
    final digits = sign.isEmpty ? value : value.substring(1);
    final buffer = StringBuffer(sign);
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'Rp $buffer';
  }
}
