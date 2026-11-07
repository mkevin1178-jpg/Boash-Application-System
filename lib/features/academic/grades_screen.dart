import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../nilai/data/repositories/nilai_repository.dart';
import '../nilai/presentation/nilai_list_screen.dart';

/// Alias lama untuk halaman nilai per mata kuliah.
///
/// Seluruh pengambilan data kini diteruskan ke `features/nilai` supaya hanya
/// ada satu jalur nilai di aplikasi.
class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key, required this.controller, this.repository});

  final AppController controller;
  final NilaiRepository? repository;

  @override
  Widget build(BuildContext context) {
    return NilaiListScreen(
      npm: controller.session?.npm ?? '',
      repository: repository,
    );
  }
}
