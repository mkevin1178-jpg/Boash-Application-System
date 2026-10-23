import 'package:bas/features/auth/login_screen.dart';
import 'package:bas/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

void main() {
  setUpAll(disableRuntimeFontFetching);

  Finder usernameField() => find.byType(TextFormField).at(0);
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

      expect(find.text('Username wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('menampilkan error saat kredensial tidak cocok', (
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

      await tester.enterText(usernameField(), 'salah');
      await tester.enterText(passwordField(), 'salah');
      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('tidak cocok'), findsOneWidget);
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

      await tester.enterText(usernameField(), demoUsername);
      await tester.enterText(passwordField(), demoPassword);
      await tester.ensureVisible(find.text('MASUK'));
      await tester.tap(find.text('MASUK'));
      await tester.pumpAndSettle();

      expect(controller.isLoggedIn, isTrue);
      expect(controller.session?.nim, isNotEmpty);
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
      expect(find.text(demoUsername), findsOneWidget);
    });
  });

  group('AppController', () {
    test('gagal login bila data contoh belum tersedia', () async {
      final controller = await createController(withDemoUser: false);
      addTearDown(controller.dispose);

      final outcome = await controller.login(demoUsername, demoPassword);

      expect(outcome, isA<LoginFailure>());
      expect(controller.isLoggedIn, isFalse);
    });

    test('logout menghapus sesi demo', () async {
      final controller = await createLoggedInController();
      addTearDown(controller.dispose);

      expect(controller.isLoggedIn, isTrue);

      controller.logout();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.session, isNull);
    });
  });
}
