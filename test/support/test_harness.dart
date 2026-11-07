import 'package:bas/app/app_theme.dart';
import 'package:bas/data/demo_repository.dart';
import 'package:bas/features/mahasiswa/data/models/mahasiswa_model.dart';
import 'package:bas/features/mahasiswa/data/repositories/mahasiswa_repository.dart';
import 'package:bas/state/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Konstanta kredensial demo yang dipakai seluruh pengujian.
///
/// NPM harus >= 5 digit angka dan password >= 4 karakter.
const String demoNpm = '12523030';
const String demoPassword = 'demo1234';

/// Alias untuk kompatibilitas test lama yang masih memakai demoUsername.
const String demoUsername = demoNpm;

/// Repository mahasiswa palsu - tidak pernah menyentuh jaringan.
class FakeMahasiswaRepository implements MahasiswaRepository {
  FakeMahasiswaRepository({this.records = const <Mahasiswa>[]});

  final List<Mahasiswa> records;

  @override
  Future<List<Mahasiswa>> fetchByNpm(String npm) async {
    final trimmed = npm.trim();
    return records
        .where((mahasiswa) => mahasiswa.npm.trim() == trimmed)
        .toList(growable: false);
  }
}

/// Profil default yang dipakai test.
const Mahasiswa demoMahasiswa = Mahasiswa(
  npm: demoNpm,
  nama: 'Siti Aminah',
  tempatLahir: 'Bandung',
  tglLahir: '2004-01-01',
  agama: 'Islam',
  kelamin: 'P',
  alamat: 'Jl. Contoh No. 1',
  handphone: '081234567890',
  email: 'siti.aminah@example.com',
  kdProgstudi: 'TRM',
  kdJenjang: 'D4',
  kdKelas: 'A',
  tahunMasuk: '2023/2024',
  foto: 'aa_sof.png',
  status: '1',
);

/// Repository demo tanpa penundaan (cepat dan stabil untuk pengujian).
DemoRepository fastRepository({bool simulateFailure = false}) =>
    DemoRepository(latency: Duration.zero, simulateFailure: simulateFailure);

/// Membuat [AppController] baru dengan data mahasiswa palsu.
///
/// [withDemoUser] tidak lagi relevan (tidak ada randomuser.me),
/// parameter dipertahankan untuk kompatibilitas test lama.
Future<AppController> createController({bool withDemoUser = true}) async {
  return AppController(
    mahasiswaRepository: FakeMahasiswaRepository(
      records: const <Mahasiswa>[demoMahasiswa],
    ),
  );
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
