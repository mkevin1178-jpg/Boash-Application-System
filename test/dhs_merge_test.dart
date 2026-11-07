import 'package:bas/features/academic/dhs_screen.dart';
import 'package:bas/features/krs/data/models/krs_model.dart';
import 'package:bas/features/krs/data/repositories/krs_repository.dart';
import 'package:bas/features/nilai/data/models/nilai_model.dart';
import 'package:bas/features/nilai/data/repositories/nilai_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

class _FakeNilaiRepository implements NilaiRepository {
  _FakeNilaiRepository(this.records);

  final List<Nilai> records;

  @override
  Future<List<Nilai>> fetchByNpm(String npm) async => records;
}

class _FakeKrsRepository implements KrsRepository {
  _FakeKrsRepository(this.records);

  final List<KrsItem> records;

  @override
  Future<List<KrsItem>> fetchByNpm(String npm) async => records;
}

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('DHS menggabungkan KRS tanpa nilai dan tidak menghitung IPS', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    final nilai = Nilai.fromJson(<String, dynamic>{
      'id': 1,
      'kd_matkul': 'GC327',
      'npm': demoNpm,
      'uas': '80',
      'uts': '80',
      'quis': '80',
      'tugas': '80',
      'hadir': '100',
      'na_uas': '20',
      'na_uts': '20',
      'na_quis': '12',
      'na_tugas': '20',
      'na_hadir': '20',
      'hm': 'A',
      'na': '92',
      'am': '4',
      'mutu': '12',
      'thn_akademik': '2024/2025',
      'semester': '1',
    });

    final krs = KrsItem.fromJson(<String, dynamic>{
      'id': '2',
      'npm': demoNpm,
      'kd_matkul': 'GC302',
      'kd_kelas': 'A',
      'thn_akademik': '2024/2025',
      'semester': '1',
      'status': '1',
    });

    await tester.pumpWidget(
      wrapWithTheme(
        DhsScreen(
          controller: controller,
          nilaiRepository: _FakeNilaiRepository(<Nilai>[nilai]),
          krsRepository: _FakeKrsRepository(<KrsItem>[krs]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GC327'), findsOneWidget);
    expect(find.text('GC302'), findsOneWidget);
    expect(find.text('Belum ada nilai'), findsOneWidget);
    expect(find.text('IPS'), findsWidgets);
    expect(find.text('4.00 / 4.00'), findsOneWidget);
    // Bila KRS tanpa nilai ikut dihitung, IPS akan menjadi 2.00.
    expect(find.text('2.00 / 4.00'), findsNothing);
  });
}
