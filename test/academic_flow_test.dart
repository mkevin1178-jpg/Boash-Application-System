import 'package:bas/features/academic/academic_screen.dart';
import 'package:bas/features/academic/assignments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('hub Akademik menampilkan tujuh fitur akademik', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AcademicScreen(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Materi'), findsOneWidget);
    expect(find.text('Tugas'), findsOneWidget);
    expect(find.text('Nilai'), findsOneWidget);
    expect(find.text('Presensi'), findsOneWidget);
    expect(find.text('KTM'), findsOneWidget);
    expect(find.text('KRS'), findsOneWidget);
    expect(find.text('DHS'), findsOneWidget);
  });

  testWidgets('daftar tugas menampilkan tugas contoh dan dapat difilter', (
    tester,
  ) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prototype Aplikasi Mobile'), findsOneWidget);
    expect(find.text('Semua (6)'), findsOneWidget);
    expect(find.text('Belum dikerjakan (4)'), findsOneWidget);
  });

  testWidgets('detail tugas menampilkan tombol pengumpulan simulasi', (
    tester,
  ) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prototype Aplikasi Mobile'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Tugas'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('KUMPULKAN TUGAS'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('KUMPULKAN TUGAS'), findsOneWidget);
  });

  testWidgets('pengumpulan tugas meminta konfirmasi', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prototype Aplikasi Mobile'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('KUMPULKAN TUGAS'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('KUMPULKAN TUGAS'));
    await tester.pumpAndSettle();

    expect(find.text('Kumpulkan tugas?'), findsOneWidget);

    await tester.tap(find.text('Kumpulkan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('SUDAH DIKUMPULKAN'), findsOneWidget);
  });
}
