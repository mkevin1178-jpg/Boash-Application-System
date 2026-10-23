import 'package:bas/app/app_theme.dart';
import 'package:bas/data/demo_repository.dart';
import 'package:bas/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Konstanta kredensial demo yang dipakai seluruh pengujian.
///
/// NPM harus ≥5 digit angka dan password ≥4 karakter.
const String demoNpm = '12523030';
const String demoPassword = 'demo1234';

/// Alias untuk kompatibilitas test lama yang masih memakai demoUsername.
const String demoUsername = demoNpm;

/// Repository demo tanpa penundaan (cepat dan stabil untuk pengujian).
DemoRepository fastRepository({bool simulateFailure = false}) =>
    DemoRepository(latency: Duration.zero, simulateFailure: simulateFailure);

/// Membuat [AppController] baru.
///
/// [withDemoUser] tidak lagi relevan (tidak ada randomuser.me),
/// parameter dipertahankan untuk kompatibilitas test lama.
Future<AppController> createController({bool withDemoUser = true}) async {
  final controller = AppController();
  // Tidak ada loadDemoUser() — login sekarang berbasis NPM lokal.
  return controller;
}

/// Membuat controller yang sudah memiliki sesi (sudah "login").
Future<AppController> createLoggedInController() async {
  final controller = await createController();
  await controller.login(demoNpm, demoPassword);
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
