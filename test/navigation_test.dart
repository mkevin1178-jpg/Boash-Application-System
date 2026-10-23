import 'package:bas/features/shell/main_shell.dart';
import 'package:bas/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

void main() {
  setUpAll(disableRuntimeFontFetching);

  /// Pencari label menu pada bottom navigation (bukan judul halaman).
  Finder navItem(String label) => find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  );

  /// Pencari judul pada header halaman.
  Finder headerTitle(String title) =>
      find.descendant(of: find.byType(PageHeader), matching: find.text(title));

  testWidgets('lima menu bawah dapat dipilih dan menampilkan halamannya', (
    tester,
  ) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        MainShell(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    // Halaman awal adalah Beranda.
    expect(find.text('Jadwal Hari Ini'), findsOneWidget);

    await tester.tap(navItem('Jadwal'));
    await tester.pumpAndSettle();
    expect(headerTitle('Jadwal'), findsOneWidget);
    expect(find.text('Mingguan'), findsOneWidget);

    await tester.tap(navItem('Akademik'));
    await tester.pumpAndSettle();
    expect(headerTitle('Akademik'), findsOneWidget);
    expect(find.text('Materi'), findsWidgets);

    await tester.tap(navItem('Pengumuman'));
    await tester.pumpAndSettle();
    expect(headerTitle('Pengumuman'), findsOneWidget);

    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('KELUAR DARI AKUN DEMO'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('KELUAR DARI AKUN DEMO'), findsOneWidget);
  });

  testWidgets('halaman profil menampilkan ringkasan akademik', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        MainShell(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(navItem('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Total SKS'), findsOneWidget);
    expect(find.text('IPK'), findsOneWidget);
    expect(find.text('Mata kuliah'), findsOneWidget);
  });
}
