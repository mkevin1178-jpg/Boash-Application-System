# Pengumpulan Pertemuan 4 — Auth Flutter

> **Nama Tugas :** Pertemuan 4 – Authentication dengan API randomuser.me  
> **Referensi  :** `Pertemuan_4_-_Auth_Flutter.md`

---

## Ringkasan Perubahan

Pada pertemuan 4 ditambahkan fitur **autentikasi (login)** yang mengambil data user secara acak dari API `https://randomuser.me/api/`, kemudian mencocokkan input username & password pengguna dengan data tersebut. Selain itu, data user yang berhasil login disimpan ke dalam sebuah **session** (`AppSession`) sehingga halaman lain (Home, Profile, KTM) dapat menampilkan nama, foto, email, dsb. secara konsisten.

### File-file yang Ditambahkan / Diubah

| File | Status | Fungsi |
|------|--------|--------|
| `lib/api/auth_api.dart` | **Baru** | Memanggil API randomuser.me, mengambil 1 user acak |
| `lib/session.dart` | **Baru** | Menyimpan data mahasiswa yang sedang login (singleton statis) |
| `lib/login.dart` | **Baru** | Halaman Login — form input + logika autentikasi + tampilan akun dari API |
| `lib/main.dart` | **Diubah** | Entry point diarahkan ke `LoginScreen` (sebelumnya langsung ke halaman utama) |
| `lib/home.dart` | **Diubah** | Header sapaan menggunakan `AppSession.firstName` dari session |
| `lib/profile.dart` | **Diubah** | Menampilkan data profil dari `AppSession` + tombol Logout |
| `lib/ktm.dart` | **Diubah** | Menampilkan data KTM dari `AppSession` (nama, foto, NIM, dll.) |
| `pubspec.yaml` | **Diubah** | Ditambahkan dependensi `http: ^1.6.0` dan `google_fonts: ^6.2.1` |

---

## Kode Lengkap

### 1. `lib/api/auth_api.dart`

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Memanggil API <https://randomuser.me/api/> untuk mengambil 1 user acak.
/// Dipakai halaman login untuk mencocokkan username & password.
class AuthApi {
  const AuthApi();

  Future<Map<String, dynamic>?> fetchRandomUser() async {
    try {
      final response = await http
          .get(Uri.parse('https://randomuser.me/api/'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.first as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
```

---

### 2. `lib/session.dart`

```dart
/// Menyimpan data mahasiswa yang sedang login (hasil autentikasi API).
/// Dipakai Home (sapaan), Profile, dan KTM agar datanya konsisten.
class AppSession {
  const AppSession._();

  static String nim = '20240001';
  static String fullName = 'Alex Johnson';
  static String username = 'alexjohnson';
  static String email = 'alex@student.ac.id';
  static String photoUrl = '';
  static String faculty = 'Fakultas Teknik';
  static String programStudi = 'Multimedia';
  static String phone = '+62 812 3456 7890';
  static String semester = '5 (Ganjil)';
  static String academicYear = '2026/2027';
  static String validUntil = '30 Jun 2027';

  static String get firstName =>
      fullName.trim().isEmpty ? 'Student' : fullName.trim().split(' ').first;

  /// Isi session dari respons API randomuser.me.
  static void setFromApiUser(Map<String, dynamic> user) {
    final name = user['name'] as Map<String, dynamic>? ?? const {};
    final first = _capitalize('${name['first'] ?? ''}');
    final last = _capitalize('${name['last'] ?? ''}');
    final full = '$first $last'.trim();
    if (full.isNotEmpty) fullName = full;

    final login = user['login'] as Map<String, dynamic>? ?? const {};
    final apiUsername = '${login['username'] ?? ''}';
    if (apiUsername.isNotEmpty) username = apiUsername;

    final apiEmail = '${user['email'] ?? ''}';
    if (apiEmail.isNotEmpty) email = apiEmail;

    final picture = user['picture'] as Map<String, dynamic>? ?? const {};
    photoUrl = '${picture['large'] ?? ''}';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
```

---

### 3. `lib/login.dart`

```dart
import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'session.dart';
import 'theme/app_colors.dart';
import 'welcome.dart';

class LoginScreen extends StatefulWidget {
  final AuthApi? authApi;

  const LoginScreen({super.key, this.authApi});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _message;
  bool _messageIsError = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final api = widget.authApi ?? const AuthApi();
    final user = await api.fetchRandomUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
      if (user == null) {
        _messageIsError = true;
        _message = 'Gagal memuat data dari API. Tekan "Ganti User Acak".';
      }
    });
  }

  void _login() {
    if (_loading) return;

    if (_user == null) {
      _showMessage('Data user belum dimuat dari API');
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username dan password wajib diisi');
      return;
    }

    // Cocokkan input dengan username & password dari API randomuser.me
    final apiUsername = '${_user!['login']?['username'] ?? ''}';
    final apiPassword = '${_user!['login']?['password'] ?? ''}';

    if (username == apiUsername && password == apiPassword) {
      AppSession.setFromApiUser(_user!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } else {
      _showMessage('Username atau password salah');
    }
  }

  void _showMessage(String text, {bool error = true}) {
    setState(() {
      _message = text;
      _messageIsError = error;
    });
  }

  void _signUp() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Sign Up is not available in this demo.',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.snackBg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.onGradientSoft),
      prefixIcon: Icon(icon, color: AppColors.onGradient),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.50),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = '${_user?['login']?['username'] ?? '-'}';
    final currentPassword = '${_user?['login']?['password'] ?? '-'}';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.menu_book,
                  size: 96,
                  color: AppColors.onGradient,
                ),
                const SizedBox(height: 16),
                const Text(
                  'STUDENT APP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.onGradient,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Login your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onGradient,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with the account from randomuser.me API',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onGradientSoft,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Username', Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Password', Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _loading ? 'MEMUAT...' : 'LOGIN',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  _buildMessage(),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account? ",
                      style: TextStyle(color: AppColors.onGradientSoft),
                    ),
                    GestureDetector(
                      onTap: _signUp,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.onGradient,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildApiHint(currentUsername, currentPassword),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            _messageIsError
                ? Icons.error_outline
                : Icons.check_circle_outline,
            size: 18,
            color: AppColors.onGradient,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.onGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu info akun dari API (untuk testing) + tombol ganti user acak.
  Widget _buildApiHint(String username, String password) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: _loading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Mengambil user dari API...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Akun login dari API (untuk testing)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.onGradientSoft,
                  ),
                ),
                const SizedBox(height: 10),
                _hintRow(Icons.person_outline, 'Username', username),
                const SizedBox(height: 6),
                _hintRow(Icons.lock_outline, 'Password', password),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: TextButton.icon(
                    onPressed: _loadUser,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onGradient,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'Ganti User Acak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _hintRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onGradientSoft),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.onGradientSoft),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onGradient,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 4. `lib/main.dart` *(diubah)*

```dart
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
```

---

### 5. `lib/home.dart` *(diubah — sapaan menggunakan AppSession)*

> Perubahan utama: `AppBar` / header kini menampilkan `AppSession.firstName`
> yang diambil dari data API setelah login berhasil.

```dart
import 'package:flutter/material.dart';

import 'ktm.dart';
import 'session.dart';
import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/menu_icon_tile.dart';
import 'widgets/section_title.dart';

class _MenuData {
  final IconData icon;
  final String label;

  const _MenuData(this.icon, this.label);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedChip = 0;

  static const List<_MenuData> _menus = [
    _MenuData(Icons.badge_outlined, 'KTM'),
    _MenuData(Icons.person_outline, 'Profile'),
    _MenuData(Icons.event, 'Events'),
    _MenuData(Icons.groups_outlined, 'Staffs'),
    _MenuData(Icons.fact_check_outlined, 'Attendance'),
    _MenuData(Icons.chat_bubble_outline, 'Chatbox'),
    _MenuData(Icons.bar_chart, 'GradeSheet'),
    _MenuData(Icons.photo_library_outlined, 'Gallery'),
    _MenuData(Icons.attach_money, 'Fees Details'),
    _MenuData(Icons.description_outlined, 'Notices'),
    _MenuData(Icons.menu_book_outlined, 'Assignments'),
    _MenuData(Icons.assignment_outlined, 'Exams'),
    _MenuData(Icons.local_library_outlined, 'Library'),
  ];

  static const List<String> _chips = ['ALL COURSE', 'DESIGN', 'VIDEO'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MenuData> get _filteredMenus {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _menus;
    return _menus
        .where((m) => m.label.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final menus = _filteredMenus;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildSearchField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildBanner(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SectionTitle(
            title: 'Menu',
            onAction: () => showAppSnackBar(context, 'All menu'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: menus.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No menu matches that search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.95,
                  children: [
                    for (final menu in menus)
                      MenuIconTile(
                        icon: menu.icon,
                        label: menu.label,
                        onTap: () => _onMenuTap(context, menu),
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: const SectionTitle(
            title: 'Top search',
            actionLabel: null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              for (var i = 0; i < _chips.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_chips[i]),
                    selected: _selectedChip == i,
                    onSelected: (_) => setState(() => _selectedChip = i),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedChip == i
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceAlt,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SectionTitle(
            title: 'Featured',
            actionLabel: null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Row(
            children: const [
              Expanded(
                child: _FeaturedCard(
                  title: 'Math MasterClass',
                  category: 'Design',
                  duration: '4h 30m',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FeaturedCard(
                  title: 'Physics Lab',
                  category: 'Video',
                  duration: '2h 10m',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMenuTap(BuildContext context, _MenuData menu) {
    if (menu.label == 'KTM') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KtmScreen()),
      );
      return;
    }
    showAppSnackBar(context, '${menu.label} opened');
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${AppSession.firstName}',   // <-- dari AppSession
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onGradient,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You are enrolled in Multimedia',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onGradientSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () =>
                        showAppSnackBar(context, 'No new notifications'),
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppColors.onGradient,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.badge,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => showAppSnackBar(context, 'Search'),
                icon: const Icon(Icons.search, color: AppColors.onGradient),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Find here',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.bgGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NEW COURSE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.onGradient,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Math MasterClass',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onGradient,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Boost your skill with our latest program.',
            style: TextStyle(fontSize: 13, color: AppColors.onGradientSoft),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showAppSnackBar(context, 'Banner opened'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: const Text(
              'VIEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;

  const _FeaturedCard({
    required this.title,
    required this.category,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.bgGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onGradient,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$category · $duration',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 6. `lib/profile.dart` *(diubah — data & logout dari AppSession)*

```dart
import 'package:flutter/material.dart';

import 'login.dart';
import 'session.dart';
import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        const SizedBox(height: 60),
        Text(
          AppSession.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'NIM ${AppSession.nim}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildStats(),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: AppColors.divider),
        _buildInfoRow(Icons.email_outlined, 'Email', AppSession.email),
        const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.divider),
        _buildInfoRow(Icons.school_outlined, 'Program Studi', AppSession.programStudi),
        const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.divider),
        _buildInfoRow(Icons.phone_outlined, 'Phone', AppSession.phone),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => showAppSnackBar(context, 'Edit profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'EDIT PROFILE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -48,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.iconBg,
                  child: ClipOval(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: AppSession.photoUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 56,
                              color: AppColors.iconNavy,
                            )
                          : Image.network(
                              AppSession.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                size: 56,
                                color: AppColors.iconNavy,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Expanded(child: _StatItem(value: '12', label: 'Courses')),
          _StatDivider(),
          Expanded(child: _StatItem(value: '3.80', label: 'GPA')),
          _StatDivider(),
          Expanded(child: _StatItem(value: '86', label: 'Credits')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.iconNavy),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }
}
```

---

### 7. `lib/ktm.dart` *(diubah — foto & data dari AppSession)*

```dart
import 'package:flutter/material.dart';

import 'session.dart';
import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/section_title.dart';

/// Halaman Kartu Tanda Mahasiswa (KTM) — desain mengikuti tema
/// "E-Learning Blue": gradient biru, kartu putih bersudut bulat,
/// ikon biru dongker, font Poppins.
class KtmScreen extends StatelessWidget {
  const KtmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _buildCard(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SectionTitle(title: 'Data Mahasiswa', actionLabel: null),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                _infoRow(Icons.email_outlined, 'Email', AppSession.email),
                _divider(),
                _infoRow(Icons.school_outlined, 'Program Studi', AppSession.programStudi),
                _divider(),
                _infoRow(Icons.account_balance_outlined, 'Fakultas', AppSession.faculty),
                _divider(),
                _infoRow(Icons.phone_outlined, 'Phone', AppSession.phone),
                _divider(),
                _infoRow(
                  Icons.calendar_month_outlined,
                  'Tahun Akademik',
                  '${AppSession.academicYear} · Semester ${AppSession.semester}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () =>
                    showAppSnackBar(context, 'KTM disimpan ke galeri (demo)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text(
                  'SIMPAN KTM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showAppSnackBar(context, 'Membagikan KTM... (demo)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'BAGIKAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(6, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.onGradient),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kartu Tanda Mahasiswa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Student Identity Card',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _cardBody(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _cardMeta(),
          ),
          _cardFooter(),
        ],
      ),
    );
  }

  Widget _cardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIVERSITAS NUSANTARA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'KARTU TANDA MAHASISWA',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _photo(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardRow('NIM', AppSession.nim),
              _cardRow('Nama', AppSession.fullName),
              _cardRow('Program Studi', AppSession.programStudi),
              _cardRow('Fakultas', AppSession.faculty),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardMeta() {
    return Row(
      children: [
        _metaBox('Semester', AppSession.semester),
        const SizedBox(width: 8),
        _metaBox('Tahun Akademik', AppSession.academicYear),
        const SizedBox(width: 8),
        _metaBox('Berlaku s/d', AppSession.validUntil),
      ],
    );
  }

  Widget _cardFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
      child: Row(
        children: [
          _barcode(),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'No. ${AppSession.nim}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onGradient,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kartu sah digunakan di kampus',
                style: TextStyle(fontSize: 9, color: AppColors.onGradientSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photo() {
    const width = 78.0;
    const height = 100.0;
    final url = AppSession.photoUrl;   // <-- foto dari API

    const fallback = Icon(Icons.person, size: 44, color: AppColors.iconNavy);

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }

  Widget _cardRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barcode() {
    return Row(
      children: [
        for (var i = 0; i < 26; i++)
          Container(
            width: i % 4 == 0 ? 3 : 1.5,
            height: 26,
            margin: const EdgeInsets.only(right: 1.5),
            color: Colors.white.withValues(alpha: i % 3 == 0 ? 1 : 0.7),
          ),
      ],
    );
  }

  Widget _divider() => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: AppColors.divider,
      );

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.iconNavy),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
```

---

### 8. `pubspec.yaml` *(diubah — dependensi baru)*

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1   # <-- BARU: font Poppins
  http: ^1.6.0           # <-- BARU: HTTP client untuk API randomuser.me
```

---

## Alur Aplikasi (Flow)

```
Buka App
   │
   ▼
LoginScreen
   ├─ initState() → _loadUser() → AuthApi.fetchRandomUser()
   │                              (HTTP GET randomuser.me/api/)
   ├─ Tampilkan username & password dari API (hint card)
   │
   ├─ Pengguna isi form → tekan LOGIN
   │     ├─ cocok  → AppSession.setFromApiUser(user)
   │     │           → Navigator.pushReplacement(WelcomeScreen)
   │     └─ salah → tampilkan pesan error
   │
   └─ Tombol "Ganti User Acak" → _loadUser() lagi
   
WelcomeScreen → MainScreen (Bottom Nav)
   ├─ HomeScreen   → Header: "Hi, {AppSession.firstName}"
   ├─ ProfileScreen → Nama, email, foto dari AppSession + Logout
   └─ KtmScreen    → Semua data KTM dari AppSession (foto dari API)
```

---

## Sumber API

**<https://randomuser.me/api/>**

Contoh field yang digunakan:
- `results[0].login.username` — dicocokkan dengan input username
- `results[0].login.password` — dicocokkan dengan input password
- `results[0].name.first` / `.last` — nama lengkap untuk session
- `results[0].email` — email untuk profile & KTM
- `results[0].picture.large` — URL foto profil
