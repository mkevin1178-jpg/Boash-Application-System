import 'dart:convert';

import 'package:bas/core/network/http_client.dart';
import 'package:bas/features/krs/data/datasources/krs_remote_ds.dart';
import 'package:bas/features/krs/data/repositories/krs_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/test_harness.dart';

void main() {
  test('data source memakai Host B, path /krs, dan query NPM', () async {
    final mock = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, '6aed363dfc3b911e6fd60ab2.mockapi.io');
      expect(request.url.path, '/krs');
      expect(request.url.queryParameters['npm'], demoNpm);

      return http.Response(
        jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'id': '3',
            'npm': demoNpm,
            'kd_matkul': 'GC327',
            'kd_kelas': 'A',
            'thn_akademik': '2023/2024',
            'semester': '1',
            'semester_now': '5',
            'status': '0',
          },
        ]),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    addTearDown(mock.close);

    final datasource = KrsRemoteDataSourceImpl(
      client: AppHttpClient(client: mock),
    );
    final records = await datasource.fetchByNpm(demoNpm);

    expect(records, hasLength(1));
    expect(records.single.id, 3);
    expect(records.single.semester, 1);
    expect(records.single.statusRaw, 0);
  });

  test('repository memfilter NPM, dedupe, dan mengurutkan KRS', () async {
    final mock = MockClient((request) async {
      return http.Response(
        jsonEncode(<Map<String, dynamic>>[
          // Duplikat kode+years+semester yang sama. Semua status 1:
          // pilih id numerik terkecil (9), bukan 20.
          <String, dynamic>{
            'id': 20,
            'npm': demoNpm,
            'kd_matkul': 'GC302',
            'thn_akademik': '2024/2025',
            'semester': '1',
            'status': 1,
          },
          <String, dynamic>{
            'id': '9',
            'npm': demoNpm,
            'kd_matkul': 'GC302',
            'thn_akademik': '2024/2025',
            'semester': '1',
            'status': '1',
          },
          // Status 0 tidak boleh mengalahkan status 1.
          <String, dynamic>{
            'id': 2,
            'npm': demoNpm,
            'kd_matkul': 'GC302',
            'thn_akademik': '2024/2025',
            'semester': '1',
            'status': 0,
          },
          // Dua status 0: pilih id terkecil (1).
          <String, dynamic>{
            'id': '3',
            'npm': demoNpm,
            'kd_matkul': 'GC327',
            'thn_akademik': '2023/2024',
            'semester': '1',
            'status': '0',
          },
          <String, dynamic>{
            'id': '1',
            'npm': demoNpm,
            'kd_matkul': 'GC327',
            'thn_akademik': '2023/2024',
            'semester': '1',
            'status': '0',
          },
          <String, dynamic>{
            'id': 7,
            'npm': demoNpm,
            'kd_matkul': 'IF501',
            'thn_akademik': '2024/2025',
            'semester': '2',
            'status': 0,
          },
          // NPM lain harus dibuang walau endpoint mengembalikannya.
          <String, dynamic>{
            'id': 4,
            'npm': '99999999',
            'kd_matkul': 'GC311',
            'thn_akademik': '2023/2024',
            'semester': '1',
            'status': 1,
          },
        ]),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    addTearDown(mock.close);

    final repository = KrsRepositoryImpl(
      KrsRemoteDataSourceImpl(client: AppHttpClient(client: mock)),
    );
    final records = await repository.fetchByNpm(' $demoNpm ');

    expect(records.map((item) => item.kdMatkul), <String>[
      'GC327',
      'GC302',
      'IF501',
    ]);
    expect(records.map((item) => item.id), <int>[1, 9, 7]);
    expect(records.every((item) => item.npm == demoNpm), isTrue);
  });
}
