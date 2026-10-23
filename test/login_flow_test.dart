import 'package:bas/features/auth/login_screen.dart';
import 'package:bas/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

void main() {
  setUpAll(disableRuntimeFontFetching);

  // Field finder — TextFormField: 0=NPM, 1=Password
  Finder npmField() => find.byType(TextFormField).at(0);
  Finder passwordField() => find.byType(TextFormField).at(1);

  group('Alur login demo', () {
    testWidgets('menampilkan pesan validasi saat kolom kosong', (tester) async {
      final controller = await createController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithTheme(
          LoginScreen(controller: controller, repository: fastRepository()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      expect(find.text('NPM wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('menampilkan error saat NPM tidak valid', (tester) async {
      final controller = await createController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithTheme(
          LoginScreen(controller: controller, repository: fastRepository()),
        ),
      );
      await tester.pumpAndSettle();

      // NPM kurang dari 5 digit
      await tester.enterText(npmField(), '123');
      await tester.enterText(passwordField(), demoPassword);
      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      expect(find.text('NPM tidak valid (minimal 5 digit angka)'), findsOneWidget);
      expect(controller.isLoggedIn, isFalse);
    });

    testWidgets('menampilkan error saat kredensial tidak cocok', (tester) async {
      final controller = await createController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithTheme(
          LoginScreen(controller: controller, repository: fastRepository()),
        ),
      );
      await tester.pumpAndSettle();

      // Password kurang dari 4 karakter
      await tester.enterText(npmField(), demoNpm);
      await tester.enterText(passwordField(), '123');
      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('terlalu pendek'), findsOneWidget);
      expect(controller.isLoggedIn, isFalse);
    });

    testWidgets('berhasil login dan menyimpan sesi demo', (tester) async {
      final controller = await createController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithTheme(
          LoginScreen(controller: controller, repository: fastRepository()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(npmField(), demoNpm);
      await tester.enterText(passwordField(), demoPassword);
      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pumpAndSettle();

      expect(controller.isLoggedIn, isTrue);
      expect(controller.session?.npm, equals(demoNpm));
    });

    testWidgets('menampilkan tombol isi otomatis untuk akun contoh', (
      tester,
    ) async {
      final controller = await createController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithTheme(
          LoginScreen(controller: controller, repository: fastRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Isi otomatis'), findsOneWidget);
    });
  });

  group('AppController', () {
    test('gagal login bila NPM kosong', () async {
      final controller = await createController(withDemoUser: false);
      addTearDown(controller.dispose);

      final outcome = await controller.login('', demoPassword);

      expect(outcome, isA<LoginFailure>());
      expect(controller.isLoggedIn, isFalse);
    });

    test('gagal login bila NPM tidak valid', () async {
      final controller = await createController(withDemoUser: false);
      addTearDown(controller.dispose);

      final outcome = await controller.login('abc', demoPassword);

      expect(outcome, isA<LoginFailure>());
      expect(controller.isLoggedIn, isFalse);
    });

    test('gagal login bila password terlalu pendek', () async {
      final controller = await createController();
      addTearDown(controller.dispose);

      final outcome = await controller.login(demoNpm, '123');

      expect(outcome, isA<LoginFailure>());
      expect(controller.isLoggedIn, isFalse);
    });

    test('berhasil login dengan NPM valid dan password cukup panjang',
        () async {
      final controller = await createController();
      addTearDown(controller.dispose);

      final outcome = await controller.login(demoNpm, demoPassword);

      expect(outcome, isA<LoginSuccess>());
      expect(controller.isLoggedIn, isTrue);
      expect(controller.session?.npm, equals(demoNpm));
    });

    test('logout menghapus sesi', () async {
      final controller = await createLoggedInController();
      addTearDown(controller.dispose);

      expect(controller.isLoggedIn, isTrue);

      controller.logout();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.session, isNull);
    });
  });
}
