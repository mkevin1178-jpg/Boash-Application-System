import 'package:flutter/material.dart';

import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../academic/academic_screen.dart';
import '../announcements/announcements_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';

/// Shell aplikasi dengan lima menu bawah utama.
///
/// Halaman dibuat **sekali** lalu disimpan pada [IndexedStack] sehingga
/// state tiap menu tetap terjaga dan tidak dibangun ulang saat berpindah
/// tab.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    DashboardScreen(
      controller: widget.controller,
      repository: widget.repository,
    ),
    ScheduleScreen(
      controller: widget.controller,
      repository: widget.repository,
    ),
    AcademicScreen(
      controller: widget.controller,
      repository: widget.repository,
    ),
    AnnouncementsScreen(
      controller: widget.controller,
      repository: widget.repository,
    ),
    ProfileScreen(controller: widget.controller, repository: widget.repository),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Jadwal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Akademik',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.campaign_outlined),
                activeIcon: Icon(Icons.campaign),
                label: 'Pengumuman',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
