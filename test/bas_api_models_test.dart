import 'package:bas/features/attendance/data/models/kehadiran_model.dart';
import 'package:bas/features/certificate/data/models/sertifikat_model.dart';
import 'package:bas/features/finance/data/models/finance_model.dart';
import 'package:bas/features/guidance/data/models/bimbingan_model.dart';
import 'package:bas/features/information/data/models/informasi_model.dart';
import 'package:bas/features/news/data/models/berita_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('model API BAS', () {
    test('Kehadiran menerima id int/string dan field nullable', () {
      final item = Kehadiran.fromJson(<String, dynamic>{
        'id': 1567839,
        'userid': ' 12523030 ',
        'jam_login': '08:00:00',
        'kd_matkul': 'GC327',
        'kd_kelas': 'A',
        'tanggal': '2026-11-20 08:00:00',
        'keterangan': null,
        'session': '1',
        'thn_akademik': '2026/2027',
        'semester': '5',
        'group_id_nonreg': 'null',
        'cuser_update': null,
        'dupdate': '2026-11-20 09:00:00',
        'bhadir_check': 1,
        'bganti_check': 0,
        'cuser_pic': 'admin',
        'dpic_check': null,
      });

      expect(item.id, '1567839');
      expect(item.userid, '12523030');
      expect(item.keterangan, isEmpty);
      expect(item.groupIdNonreg, isEmpty);
      expect(item.tanggal, isNotNull);
      expect(item.tanggal!.hour, 8);
      expect(item.bhadirCheck, '1');
      expect(item.dpicCheckRaw, isEmpty);
    });

    test('Sertifikat mem-parsing epoch detik dan mendeteksi tautan', () {
      const stamp = 1763616000;
      final item = Sertifikat.fromJson(<String, dynamic>{
        'id_sertifikat': '4',
        'npm': '12523030',
        'nama_sertifikat': 'Juara 1',
        'jenis_sertifikat': 'Kejuaraan',
        'kategori_sertifikat': 'Non-Akademik',
        'penyelenggara': 'Kampus',
        'tingkat_kegiatan': 'Nasional',
        'tanggal_sertifikat': stamp,
        'nomor_sertifikat': '123/ABC',
        'file_sertifikat': 'https://example.com/sertifikat.pdf',
        'tanggal_upload': stamp.toString(),
        'status_verifikasi': 'Menunggu Verifikasi',
        'catatan_verifikasi': null,
        'diverifikasi_oleh': 'null',
        'tanggal_verifikasi': null,
      });

      expect(item.idSertifikat, '4');
      expect(item.tanggalSertifikat!.millisecondsSinceEpoch, stamp * 1000);
      expect(item.tanggalUpload!.millisecondsSinceEpoch, stamp * 1000);
      expect(item.tanggalVerifikasi, isNull);
      expect(item.isLink, isTrue);
      expect(item.catatanVerifikasi, isEmpty);
    });

    test('Bimbingan menyimpan status mentah tanpa mengarang field', () {
      final item = Bimbingan.fromJson(<String, dynamic>{
        'thn_akademik': '2026/2027',
        'npm': '12523030',
        'tgl_mulai': '2026-01-05',
        'tgl_selesai': '2026-06-20',
        'judul': 'Skripsi BAS',
        'topik': 'Integrasi API',
        'permasalahan': null,
        'nip': '198001012005011002',
        'proposal': '1',
        'sk_proposal': 'SK-1',
        'status_proposal': 1,
        'tugas_akhir': 'TA BAS',
        'sk_tugas_akhir': '',
        'status_tugas_akhir': '0',
        'status_data': 1,
      });

      expect(item.permasalahan, isEmpty);
      expect(item.proposal, 1);
      expect(item.statusTugasAkhir, 0);
      expect(item.displayKey, '12523030|198001012005011002|Skripsi BAS');
      expect(item.tglMulai!.day, 5);
    });

    test('FinancePayment mem-parsing npayment string menjadi angka', () {
      final item = FinancePayment.fromJson(<String, dynamic>{
        'nid': 10,
        'npm': '12523030',
        'thn_akademik': '2026/2027',
        'semester': '5',
        'dpayment': '2026-11-20',
        'npayment': '1500000',
        'cketerangan': 'Biaya semester',
        'cuser_entry': 'admin',
        'dentry': '2026-11-20 08:00:00',
        'cuser_update': null,
        'dupdate': '',
        'bdeleted': 0,
        'cuser_delete': '',
        'ddelete': 'null',
        'reg_id': null,
        'ntype': 'SPP',
      });

      expect(item.amount, 1500000);
      expect(item.amountLabel, 'Rp 1.500.000');
      expect(item.bdeleted, '0');
      expect(item.regId, isEmpty);
      expect(item.dpayment!.day, 20);
    });

    test(
      'Berita dan Informasi aman terhadap tanggal kosong dan isi panjang',
      () {
        final berita = Berita.fromJson(<String, dynamic>{
          'judul_berita': 'Berita BAS',
          'isi_berita': 'A' * 160,
          'tgl_posting_berita': null,
          'berita_dari': 'BAAK',
        });
        final informasi = Informasi.fromJson(<String, dynamic>{
          'kd_progstudi': '5',
          'judul_informasi': 'Informasi BAS',
          'isi_berita': 'tidak dipakai',
          'isi_informasi': 'B' * 160,
          'tgl_posting_informasi': null,
          'informasi_dari': 'Kampus',
          'id_informasi': '7',
        });

        expect(berita.tglPosting, isNull);
        expect(berita.ringkasan.length, 131);
        expect(berita.ringkasan.endsWith('…'), isTrue);
        expect(informasi.kdProgstudi, 5);
        expect(informasi.tglPosting, isNull);
        expect(informasi.ringkasan.endsWith('…'), isTrue);
      },
    );
  });
}
