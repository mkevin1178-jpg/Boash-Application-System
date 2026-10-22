import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/auth_api.dart';
import 'package:bas/main.dart';

/// AuthApi palsu agar test tidak bergantung jaringan internet.
class _FakeAuthApi implements AuthApi {
  @override
  Future<Map<String, dynamic>?> fetchRandomUser() async {
    return {
      'name': {'first': 'siti', 'last': 'utami'},
      'email': 'siti.utami@mahasiswa.ac.id',
      'picture': {'large': ''},
      'login': {'username': 'siti', 'password': 'mahasiswa'},
    };
  }
}

void main() {
  testWidgets('Login dengan akun API lalu membuka menu KTM',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(authApi: _FakeAuthApi()));
    await tester.pumpAndSettle();

    expect(find.text('STUDENT APP'), findsOneWidget);
    expect(find.text('Login your account'), findsOneWidget);
    // Kredensial dari API ditampilkan sebagai petunjuk testing.
    expect(find.text('siti'), findsOneWidget);
    expect(find.text('mahasiswa'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'siti');
    await tester.enterText(find.byType(TextField).at(1), 'mahasiswa');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Info'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('News'), findsWidgets);
    expect(find.text('Hi, Siti'), findsOneWidget);

    // Buka menu KTM dari grid Home.
    await tester.ensureVisible(find.text('KTM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KTM'));
    await tester.pumpAndSettle();

    expect(find.text('Kartu Tanda Mahasiswa'), findsOneWidget);
    expect(find.text('UNIVERSITAS NUSANTARA'), findsOneWidget);
    expect(find.text('NIM'), findsOneWidget);
  });
}
