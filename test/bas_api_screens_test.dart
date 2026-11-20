import 'package:bas/features/attendance/data/models/kehadiran_model.dart';
import 'package:bas/features/attendance/presentation/kehadiran_screen.dart';
import 'package:bas/features/certificate/data/models/sertifikat_model.dart';
import 'package:bas/features/certificate/presentation/sertifikat_screen.dart';
import 'package:bas/features/finance/data/models/finance_model.dart';
import 'package:bas/features/finance/presentation/finance_screen.dart';
import 'package:bas/features/guidance/data/models/bimbingan_model.dart';
import 'package:bas/features/guidance/presentation/bimbingan_screen.dart';
import 'package:bas/features/information/data/models/informasi_model.dart';
import 'package:bas/features/information/presentation/informasi_screen.dart';
import 'package:bas/features/news/data/models/berita_model.dart';
import 'package:bas/features/news/data/repositories/berita_repository.dart';
import 'package:bas/features/news/presentation/news_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

Kehadiran _kehadiran() => Kehadiran.fromJson(<String, dynamic>{
  'id': 1,
  'userid': demoNpm,
  'jam_login': '08:00:00',
  'kd_matkul': 'GC327',
  'kd_kelas': 'A',
  'tanggal': '2026-11-20',
  'keterangan': '1',
  'session': '1',
  'thn_akademik': '2026/2027',
  'semester': '5',
});

Sertifikat _sertifikat() => Sertifikat.fromJson(<String, dynamic>{
  'id_sertifikat': '1',
  'npm': demoNpm,
  'nama_sertifikat': 'Sertifikat API BAS',
  'jenis_sertifikat': 'Kejuaraan',
  'kategori_sertifikat': 'Non-Akademik',
  'penyelenggara': 'Kampus',
  'tingkat_kegiatan': 'Nasional',
  'tanggal_sertifikat': 1763616000,
  'nomor_sertifikat': '123/ABC',
  'file_sertifikat': 'https://example.com/file.pdf',
  'status_verifikasi': 'Menunggu Verifikasi',
});

Bimbingan _bimbingan() => Bimbingan.fromJson(<String, dynamic>{
  'npm': demoNpm,
  'judul': 'Bimbingan API BAS',
  'topik': 'Integrasi API',
  'permasalahan': 'Belum ada',
  'nip': '198001012005011002',
  'thn_akademik': '2026/2027',
  'tgl_mulai': '2026-01-05',
  'tgl_selesai': '2026-06-20',
  'status_data': 1,
});

FinancePayment _finance() => FinancePayment.fromJson(<String, dynamic>{
  'nid': 1,
  'npm': demoNpm,
  'thn_akademik': '2026/2027',
  'semester': '5',
  'dpayment': '2026-11-20',
  'npayment': '250000',
  'cketerangan': 'Biaya semester API',
  'ntype': 'SPP',
});

Informasi _informasi() => Informasi.fromJson(<String, dynamic>{
  'id_informasi': '1',
  'kd_progstudi': 5,
  'judul_informasi': 'Informasi API BAS',
  'isi_informasi': 'Isi informasi dari server.',
  'informasi_dari': 'Sofi Putri Rahayu',
});

class _FlakyBeritaRepository implements BeritaRepository {
  int _calls = 0;
  static const _sample = Berita(
    judul: 'Berita API BAS',
    isi: 'Isi berita dari server.',
    tglPostingRaw: '2026-11-20',
    tglPosting: null,
    beritaDari: 'BAAK',
  );

  @override
  Future<List<Berita>> fetchAll() async {
    _calls++;
    if (_calls == 1) {
      throw StateError('Server berita sedang bermasalah. Coba lagi.');
    }
    return const <Berita>[_sample];
  }
}

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('Kehadiran menampilkan data API dan memvalidasi form POST', (
    tester,
  ) async {
    final repository = FakeKehadiranRepository(
      records: <Kehadiran>[_kehadiran()],
    );
    await tester.pumpWidget(
      wrapWithTheme(KehadiranScreen(npm: demoNpm, repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('GC327 · Kelas A'), findsOneWidget);

    await tester.tap(find.text('CATAT KEHADIRAN'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('KIRIM KE SERVER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KIRIM KE SERVER'));
    await tester.pump();

    expect(find.text('Kode mata kuliah wajib diisi'), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('Sertifikat menampilkan data API', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        SertifikatScreen(
          npm: demoNpm,
          repository: FakeSertifikatRepository(
            records: <Sertifikat>[_sertifikat()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sertifikat API BAS'), findsOneWidget);
    expect(find.text('Menunggu Verifikasi'), findsOneWidget);
  });

  testWidgets('Bimbingan membuka detail dari kartu API', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        BimbinganScreen(
          npm: demoNpm,
          repository: FakeBimbinganRepository(
            records: <Bimbingan>[_bimbingan()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bimbingan API BAS'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Bimbingan'), findsOneWidget);
    expect(find.text('198001012005011002'), findsOneWidget);
  });

  testWidgets('Finance menampilkan total nominal dan detail', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        FinanceScreen(
          npm: demoNpm,
          repository: FakeFinanceRepository(
            records: <FinancePayment>[_finance()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp 250.000'), findsWidgets);
    await tester.tap(find.text('Biaya semester API'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Pembayaran'), findsOneWidget);
    expect(find.text('Biaya semester API'), findsOneWidget);
  });

  testWidgets('Informasi menampilkan data API', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        InformasiScreen(
          repository: FakeInformasiRepository(
            records: <Informasi>[_informasi()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Informasi API BAS'), findsOneWidget);
    expect(find.textContaining('Sofi Putri Rahayu'), findsWidgets);
  });

  testWidgets('Informasi menyembunyikan sumber selain Sofi', (tester) async {
    await tester.pumpWidget(
      wrapWithTheme(
        InformasiScreen(
          repository: FakeInformasiRepository(
            records: <Informasi>[
              _informasi(),
              Informasi.fromJson(<String, dynamic>{
                'id_informasi': '2',
                'judul_informasi': 'Informasi sumber lain',
                'isi_informasi': 'Tidak boleh ditampilkan.',
                'informasi_dari': 'Sumber Lain',
              }),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Informasi API BAS'), findsOneWidget);
    expect(find.text('Informasi sumber lain'), findsNothing);
  });

  testWidgets('Berita menampilkan error lalu retry menampilkan data', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithTheme(NewsScreen(repository: _FlakyBeritaRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat data'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Berita API BAS'), findsOneWidget);
  });
}
