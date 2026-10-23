import 'dart:convert';

import 'package:bas/app/app_theme.dart';
import 'package:bas/data/demo_repository.dart';
import 'package:bas/services/auth_api.dart';
import 'package:bas/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Konstanta kredensial demo yang dipakai seluruh pengujian.
const String demoUsername = 'budi.santoso';
const String demoPassword = 'password123';

/// Payload randomuser.me tiruan untuk pengujian.
String demoUserPayload() => jsonEncode({
  'results': [
    {
      'name': {'first': 'Budi', 'last': 'Santoso'},
      'login': {'username': demoUsername, 'password': demoPassword},
      'email': 'budi.santoso@example.com',
      'picture': {'large': ''},
    },
  ],
});

/// [AuthApi] dengan klien tiruan sehingga pengujian tidak bergantung
/// jaringan.
AuthApi fakeAuthApi({int statusCode = 200, String? body}) {
  return AuthApi(
    client: MockClient(
      (request) async => http.Response(body ?? demoUserPayload(), statusCode),
    ),
  );
}

/// Repository demo tanpa penundaan (cepat dan stabil untuk pengujian).
DemoRepository fastRepository({bool simulateFailure = false}) =>
    DemoRepository(latency: Duration.zero, simulateFailure: simulateFailure);

/// Membuat controller dengan akun contoh yang sudah dimuat.
Future<AppController> createController({bool withDemoUser = true}) async {
  final controller = AppController(authApi: fakeAuthApi());
  if (withDemoUser) {
    await controller.loadDemoUser();
  }
  return controller;
}

/// Membuat controller yang sudah memiliki sesi demo (sudah "login").
Future<AppController> createLoggedInController() async {
  final controller = await createController();
  await controller.login(demoUsername, demoPassword);
  return controller;
}

/// Membungkus widget dengan tema aplikasi.
Widget wrapWithTheme(Widget child) {
  return MaterialApp(theme: AppTheme.build(), home: child);
}

/// Menonaktifkan pengambilan font saat runtime agar pengujian tidak
/// melakukan permintaan jaringan.
void disableRuntimeFontFetching() {
  GoogleFonts.config.allowRuntimeFetching = false;
}
