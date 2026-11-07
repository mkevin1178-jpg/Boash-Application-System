import 'dart:convert';

import 'package:bas/core/network/http_client.dart';
import 'package:bas/features/mahasiswa/data/datasources/mahasiswa_remote_ds.dart';
import 'package:bas/features/mahasiswa/data/models/mahasiswa_model.dart';
import 'package:bas/state/app_controller.dart';
import 'package:bas/state/app_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/test_harness.dart';

void main() {
  group('Mahasiswa.fromJson', () {
    test('trim nama dan ubah null/"null" menjadi string kosong', () {
      final mahasiswa = Mahasiswa.fromJson(<String, dynamic>{
        'npm': ' 12523030 ',
        'nama': 'Siti Aminah   ',
        'tempat_lahir': null,
        'tgl_lahir': 'null',
        'alamat': '',
        'email': 'siti@example.com',
        'kd_progstudi': 'TRM',
        'tahun_masuk': '2023/2024',
        'foto': 'aa_sof.png',
      });

      expect(mahasiswa.npm, demoNpm);
      expect(mahasiswa.nama, 'Siti Aminah');
      expect(mahasiswa.tempatLahir, isEmpty);
      expect(mahasiswa.tglLahir, isEmpty);
      expect(mahasiswa.alamat, isEmpty);
      expect(mahasiswa.email, 'siti@example.com');
      expect(mahasiswa.kdProgstudi, 'TRM');
      expect(mahasiswa.tahunMasuk, '2023/2024');
    });
  });

  group('AppSession.fromMahasiswa', () {
    test('memakai identitas API dan tidak memakai nama file sebagai URL', () {
      final session = AppSession.fromMahasiswa(demoMahasiswa);

      expect(session.npm, demoNpm);
      expect(session.fullName, 'Siti Aminah');
      expect(session.email, 'siti.aminah@example.com');
      expect(session.programStudi, 'TRM');
      expect(session.academicYear, '2023/2024');
      expect(session.phone, '081234567890');
      expect(session.photoUrl, isEmpty);
    });

    test('menerima URL foto absolut', () {
      final session = AppSession.fromMahasiswa(
        const Mahasiswa(
          npm: demoNpm,
          nama: 'Siti Aminah',
          tempatLahir: '',
          tglLahir: '',
          agama: '',
          kelamin: '',
          alamat: '',
          handphone: '',
          email: '',
          kdProgstudi: '',
          kdJenjang: '',
          kdKelas: '',
          tahunMasuk: '',
          foto: 'https://example.com/foto.png',
          status: '',
        ),
      );

      expect(session.photoUrl, 'https://example.com/foto.png');
    });
  });

  test('data source mahasiswa memakai Host B dan query NPM', () async {
    final mock = MockClient((request) async {
      expect(request.url.host, '6aed363dfc3b911e6fd60ab2.mockapi.io');
      expect(request.url.path, '/mahasiswa');
      expect(request.url.queryParameters['npm'], demoNpm);

      return http.Response(
        jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'npm': demoNpm,
            'nama': 'Siti Aminah   ',
            'email': 'siti.aminah@example.com',
            'kd_progstudi': 'TRM',
            'tahun_masuk': '2023/2024',
            'foto': 'aa_sof.png',
          },
        ]),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    addTearDown(mock.close);

    final datasource = MahasiswaRemoteDataSourceImpl(
      client: AppHttpClient(client: mock),
    );
    final records = await datasource.fetchByNpm(demoNpm);

    expect(records, hasLength(1));
    expect(records.single.nama, 'Siti Aminah');
  });

  group('AppController login via /mahasiswa', () {
    test('berhasil memakai profil dari repository mahasiswa', () async {
      final controller = await createController();
      addTearDown(controller.dispose);

      final outcome = await controller.login(demoNpm, demoPassword);

      expect(outcome, isA<LoginSuccess>());
      expect(controller.session?.fullName, 'Siti Aminah');
      expect(controller.session?.npm, demoNpm);
    });

    test('gagal bila NPM tidak terdaftar', () async {
      final controller = AppController(
        mahasiswaRepository: FakeMahasiswaRepository(),
      );
      addTearDown(controller.dispose);

      final outcome = await controller.login(demoNpm, demoPassword);

      expect(outcome, isA<LoginFailure>());
      expect((outcome as LoginFailure).message, 'NPM tidak terdaftar.');
      expect(controller.isLoggedIn, isFalse);
    });
  });
}
