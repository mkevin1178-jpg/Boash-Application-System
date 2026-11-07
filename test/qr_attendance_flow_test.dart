import 'package:bas/data/demo_repository.dart';
import 'package:bas/features/academic/academic_screen.dart';
import 'package:bas/features/academic/attendance_screen.dart';
import 'package:bas/features/academic/qr_scanner_screen.dart';
import 'package:bas/services/qr_attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'support/test_harness.dart';

final DateTime _now = DateTime(2026, 11, 2, 8, 30);
final String _validQr =
    'BAS-ATT|1|MK-01|3|${DateTime(2026, 11, 2, 9, 30).millisecondsSinceEpoch ~/ 1000}';

Widget _fakeScanner(
  BuildContext context,
  ValueChanged<BarcodeCapture> onDetect,
) => Center(
  child: ElevatedButton(
    key: const ValueKey('fake-scan'),
    onPressed: () =>
        onDetect(BarcodeCapture(barcodes: [Barcode(rawValue: _validQr)])),
    child: const Text('Emit scan'),
  ),
);

DemoRepository _repository({bool fail = false}) => DemoRepository(
  latency: Duration.zero,
  simulateFailure: fail,
  qrAttendanceService: QrAttendanceService(clock: () => _now),
);

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('scan sukses lalu scan ulang menampilkan HADIR dan duplikat', (
    tester,
  ) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);
    final repository = _repository();
    await tester.pumpWidget(
      wrapWithTheme(
        QrScannerScreen(
          controller: controller,
          repository: repository,
          scannerBuilder: _fakeScanner,
        ),
      ),
    );

    await tester.tap(find.text('Emit scan'));
    await tester.pumpAndSettle();
    expect(find.text('HADIR'), findsWidgets);
    await tester.tap(find.text('Scan lagi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emit scan'));
    await tester.pumpAndSettle();
    expect(find.text('SUDAH TERCATAT'), findsOneWidget);
  });

  testWidgets('kegagalan repository tidak menampilkan HADIR', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapWithTheme(
        QrScannerScreen(
          controller: controller,
          repository: _repository(fail: true),
          scannerBuilder: _fakeScanner,
        ),
      ),
    );

    await tester.tap(find.text('Emit scan'));
    await tester.pumpAndSettle();
    expect(find.text('HADIR'), findsNothing);
    expect(
      find.text('Scan QR gagal diproses. Silakan coba lagi.'),
      findsOneWidget,
    );
  });

  testWidgets('riwayat scan kosong menampilkan empty state', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapWithTheme(
        AttendanceScreen(controller: controller, repository: _repository()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Riwayat scan QR'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Belum ada riwayat scan QR'), findsOneWidget);
  });

  test('log QR menambah rekap demo per NPM', () async {
    final controller = await createLoggedInController();
    final repository = _repository();
    addTearDown(controller.dispose);
    final result = await repository.submitQrScan(_validQr, npm: demoNpm);
    expect(result.status, ScanStatus.hadir);
    final records = await repository.fetchAttendanceFor(demoNpm);
    final mobile = records.singleWhere(
      (record) => record.courseCode == 'MK-01',
    );
    expect(mobile.totalMeeting, 15);
    expect(mobile.attended, 14);
    expect((await repository.fetchAttendanceLogs(demoNpm)).single.meeting, 3);
    expect(await repository.fetchAttendanceLogs('99999999'), isEmpty);
    final otherStudent = await repository.fetchAttendanceFor('99999999');
    expect(
      otherStudent
          .singleWhere((record) => record.courseCode == 'MK-01')
          .attended,
      13,
    );
  });

  testWidgets('tile Scan QR tersedia di Akademik', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapWithTheme(
        AcademicScreen(controller: controller, repository: _repository()),
      ),
    );
    expect(find.text('Scan QR'), findsOneWidget);
  });
}
