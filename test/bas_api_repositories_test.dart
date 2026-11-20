import 'dart:convert';

import 'package:bas/core/error/failure.dart';
import 'package:bas/core/network/http_client.dart';
import 'package:bas/features/attendance/data/datasources/kehadiran_remote_ds.dart';
import 'package:bas/features/attendance/data/models/kehadiran_model.dart';
import 'package:bas/features/attendance/data/repositories/kehadiran_repository.dart';
import 'package:bas/features/certificate/data/datasources/sertifikat_remote_ds.dart';
import 'package:bas/features/certificate/data/models/sertifikat_model.dart';
import 'package:bas/features/certificate/data/repositories/sertifikat_repository.dart';
import 'package:bas/features/finance/data/datasources/finance_remote_ds.dart';
import 'package:bas/features/finance/data/repositories/finance_repository.dart';
import 'package:bas/features/guidance/data/datasources/bimbingan_remote_ds.dart';
import 'package:bas/features/guidance/data/repositories/bimbingan_repository.dart';
import 'package:bas/features/information/data/datasources/informasi_remote_ds.dart';
import 'package:bas/features/information/data/repositories/informasi_repository.dart';
import 'package:bas/features/news/data/datasources/berita_remote_ds.dart';
import 'package:bas/features/news/data/repositories/berita_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _npm = '12523030';
const _host = '6adab9277512f497b30020ef.mockapi.io';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: <String, String>{'content-type': 'application/json'},
);

void main() {
  group('data source dan repository API BAS', () {
    test(
      'kehadiran memakai query userid dan repository memfilter NPM',
      () async {
        final mock = MockClient((request) async {
          expect(request.url.host, _host);
          expect(request.url.path, '/kehadiran');
          expect(request.url.queryParameters['userid'], _npm);
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{'id': 1, 'userid': _npm, 'kd_matkul': 'GC327'},
            <String, dynamic>{
              'id': 2,
              'userid': '99999999',
              'kd_matkul': 'GC311',
            },
          ]);
        });
        addTearDown(mock.close);

        final repository = KehadiranRepositoryImpl(
          KehadiranRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
        );
        final items = await repository.fetchByNpm(_npm);

        expect(items, hasLength(1));
        expect(items.single.userid, _npm);
      },
    );

    test('POST kehadiran mengirim field terverifikasi', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/kehadiran');
        expect(request.headers['content-type'], contains('application/json'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['userid'], _npm);
        expect(body['kd_matkul'], 'GC327');
        expect(body['tanggal'], '2026-11-20');
        expect(body.containsKey('nama_matkul'), isFalse);
        return _json(<String, dynamic>{'id': '77', ...body});
      });
      addTearDown(mock.close);

      final repository = KehadiranRepositoryImpl(
        KehadiranRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
      );
      final created = await repository.create(
        const KehadiranRequest(
          npm: _npm,
          kdMatkul: 'GC327',
          kdKelas: 'A',
          tanggal: '2026-11-20',
          jamLogin: '08:00:00',
          session: '1',
          keterangan: '1',
        ),
      );

      expect(created.id, '77');
    });

    test('POST sertifikat mengembalikan id_sertifikat dari server', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/sertifikat');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['npm'], _npm);
        expect(body['nama_sertifikat'], 'Juara 1');
        expect(body['tanggal_sertifikat'], isA<int>());
        return _json(<String, dynamic>{'id_sertifikat': '4', ...body});
      });
      addTearDown(mock.close);

      final repository = SertifikatRepositoryImpl(
        SertifikatRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
      );
      final created = await repository.create(
        SertifikatRequest(
          npm: _npm,
          namaSertifikat: 'Juara 1',
          jenisSertifikat: 'Kejuaraan',
          kategoriSertifikat: 'Non-Akademik',
          penyelenggara: 'Kampus',
          tingkatKegiatan: 'Nasional',
          tanggalSertifikat: 1763616000,
          nomorSertifikat: '123/ABC',
          fileSertifikat: 'https://example.com/file.pdf',
        ),
      );

      expect(created.idSertifikat, '4');
    });

    test(
      'bimbingan dan finance memakai query npm dan memfilter hasil',
      () async {
        final bimbinganMock = MockClient((request) async {
          expect(request.url.path, '/bimbingan_data');
          expect(request.url.queryParameters['npm'], _npm);
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{'npm': _npm, 'judul': 'TA A'},
            <String, dynamic>{'npm': '99999999', 'judul': 'TA B'},
          ]);
        });
        final financeMock = MockClient((request) async {
          expect(request.url.path, '/fin_mhs_payment');
          expect(request.url.queryParameters['npm'], _npm);
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{'npm': _npm, 'npayment': '250000'},
            <String, dynamic>{'npm': '99999999', 'npayment': '999'},
          ]);
        });
        addTearDown(bimbinganMock.close);
        addTearDown(financeMock.close);

        final bimbingan = await BimbinganRepositoryImpl(
          BimbinganRemoteDataSourceImpl(
            client: AppHttpClient(client: bimbinganMock),
          ),
        ).fetchByNpm(_npm);
        final finance = await FinanceRepositoryImpl(
          FinanceRemoteDataSourceImpl(
            client: AppHttpClient(client: financeMock),
          ),
        ).fetchByNpm(_npm);

        expect(bimbingan, hasLength(1));
        expect(bimbingan.single.judul, 'TA A');
        expect(finance, hasLength(1));
        expect(finance.single.amount, 250000);
      },
    );

    test(
      'izin KRS tertutup bila Finance hanya berisi data pembayaran',
      () async {
        final mock = MockClient((request) async {
          expect(request.url.path, '/fin_mhs_payment');
          expect(request.url.queryParameters['npm'], _npm);
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{
              'npm': _npm,
              'npayment': '4500000',
              'cketerangan': 'Pembayaran UKT (BRI)',
              'ntype': '0',
              'bdeleted': '0',
            },
            <String, dynamic>{'npm': '99999999', 'izin_krs': 'disetujui'},
          ]);
        });
        addTearDown(mock.close);

        final access = await FinanceRepositoryImpl(
          FinanceRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
        ).checkKrsAccess(_npm);

        expect(access.canInputKrs, isFalse);
        expect(access.status, KrsAccessStatus.unverifiable);
        expect(access.message, contains('belum menyediakan'));
      },
    );

    test(
      'izin KRS memakai field eksplisit milik NPM yang sedang login',
      () async {
        final mock = MockClient((request) async {
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{
              'npm': '99999999',
              'izin_krs': 'disetujui',
              'dentry': '2026-11-20 10:00:00',
            },
            <String, dynamic>{
              'npm': _npm,
              'izin_krs': 'menunggu persetujuan',
              'dentry': '2026-11-20 09:00:00',
            },
          ]);
        });
        addTearDown(mock.close);

        final access = await FinanceRepositoryImpl(
          FinanceRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
        ).checkKrsAccess(_npm);

        expect(access.canInputKrs, isFalse);
        expect(access.status, KrsAccessStatus.pending);
        expect(access.message, KrsAccess.pendingMessage);
      },
    );

    test(
      'izin KRS disetujui hanya bila field eksplisit menyatakan disetujui',
      () async {
        final mock = MockClient((request) async {
          return _json(<Map<String, dynamic>>[
            <String, dynamic>{
              'npm': _npm,
              'izin_krs': 'disetujui',
              'dentry': '2026-11-20 09:00:00',
            },
          ]);
        });
        addTearDown(mock.close);

        final access = await FinanceRepositoryImpl(
          FinanceRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
        ).checkKrsAccess(_npm);

        expect(access.canInputKrs, isTrue);
        expect(access.status, KrsAccessStatus.granted);
      },
    );

    test('kegagalan API Finance tidak membuka akses KRS', () async {
      final mock = MockClient(
        (request) async => _json(<Map<String, dynamic>>[], 500),
      );
      addTearDown(mock.close);

      final access = await FinanceRepositoryImpl(
        FinanceRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
      ).checkKrsAccess(_npm);

      expect(access.canInputKrs, isFalse);
      expect(access.status, KrsAccessStatus.unverifiable);
    });

    test('berita dan informasi diambil tanpa query NPM', () async {
      final beritaMock = MockClient((request) async {
        expect(request.url.path, '/berita');
        expect(request.url.query, isEmpty);
        return _json(<Map<String, dynamic>>[
          <String, dynamic>{'judul_berita': 'Berita 1'},
        ]);
      });
      final informasiMock = MockClient((request) async {
        expect(request.url.path, '/informasi');
        expect(request.url.query, isEmpty);
        return _json(<Map<String, dynamic>>[
          <String, dynamic>{'judul_informasi': 'Informasi 1'},
        ]);
      });
      addTearDown(beritaMock.close);
      addTearDown(informasiMock.close);

      final berita = await BeritaRepositoryImpl(
        BeritaRemoteDataSourceImpl(client: AppHttpClient(client: beritaMock)),
      ).fetchAll();
      final informasi = await InformasiRepositoryImpl(
        InformasiRemoteDataSourceImpl(
          client: AppHttpClient(client: informasiMock),
        ),
      ).fetchAll();

      expect(berita.single.judul, 'Berita 1');
      expect(informasi.single.judul, 'Informasi 1');
    });

    test('NPM kosong dan respons invalid menghasilkan Failure', () async {
      final repository = KehadiranRepositoryImpl(
        KehadiranRemoteDataSourceImpl(
          client: AppHttpClient(
            client: MockClient(
              (request) async => _json(<Map<String, dynamic>>[]),
            ),
          ),
        ),
      );
      await expectLater(
        repository.fetchByNpm('  '),
        throwsA(isA<InvalidRequestFailure>()),
      );

      final invalidMock = MockClient(
        (request) async => http.Response('<html>bukan json</html>', 200),
      );
      addTearDown(invalidMock.close);
      await expectLater(
        BeritaRepositoryImpl(
          BeritaRemoteDataSourceImpl(
            client: AppHttpClient(client: invalidMock),
          ),
        ).fetchAll(),
        throwsA(isA<InvalidResponseFailure>()),
      );

      final errorMock = MockClient(
        (request) async => _json(<Map<String, dynamic>>[], 500),
      );
      addTearDown(errorMock.close);
      await expectLater(
        InformasiRepositoryImpl(
          InformasiRemoteDataSourceImpl(
            client: AppHttpClient(client: errorMock),
          ),
        ).fetchAll(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
