import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'data/demo_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'state/app_controller.dart';

/// Entry point aplikasi BAS.
void main() {
  runApp(const BasStudentApp());
}

/// Root aplikasi: tema, dependensi bersama, dan switch halaman.
class BasStudentApp extends StatefulWidget {
  const BasStudentApp({super.key});

  @override
  State<BasStudentApp> createState() => _BasStudentAppState();
}

class _BasStudentAppState extends State<BasStudentApp> {
  late final AppController _controller = AppController();
  final DemoRepository _repository = DemoRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: AppRoot(controller: _controller, repository: _repository),
    );
  }
}

/// Memilih halaman berdasarkan status sesi demo.
///
/// - Belum siap: layar splash.
/// - Sudah login: [MainShell] dengan lima menu utama.
/// - Belum login: [LoginScreen].
class AppRoot extends StatefulWidget {
  const AppRoot({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Tampilkan splash sebentar sebelum masuk ke halaman login.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!_ready) return const SplashScreen();

        if (widget.controller.isLoggedIn) {
          return MainShell(
            controller: widget.controller,
            repository: widget.repository,
          );
        }

        return LoginScreen(
          controller: widget.controller,
          repository: widget.repository,
        );
      },
    );
  }
}
