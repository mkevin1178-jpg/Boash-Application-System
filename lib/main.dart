import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api/auth_api.dart';
import 'login.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final AuthApi? authApi;

  const MyApp({super.key, this.authApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(authApi: authApi),
    );
  }
}
