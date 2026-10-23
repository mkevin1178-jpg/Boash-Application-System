import 'package:flutter/material.dart';

import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/menu_icon_tile.dart';
import '../../widgets/page_header.dart';
import 'assignments_screen.dart';
import 'attendance_screen.dart';
import 'dhs_screen.dart';
import 'grades_screen.dart';
import 'krs_screen.dart';
import 'ktm_screen.dart';
import 'materials_screen.dart';

/// Halaman Akademik — satu pintu ke Materi, Tugas, Nilai, Presensi, KTM,
/// KRS, dan DHS.
class AcademicScreen extends StatefulWidget {
  const AcademicScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  Future<void> _open(Widget screen) {
    return Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.pageBottom),
          children: [
            const PageHeader(
              title: 'Akademik',
              subtitle:
                  'Materi, tugas, nilai, presensi, KTM, KRS, dan DHS demo',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.xl,
                AppSpacing.pageH,
                AppSpacing.md,
              ),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
                children: [
                  MenuIconTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Materi',
                    onTap: () => _open(
                      MaterialsScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                  MenuIconTile(
                    icon: Icons.assignment_outlined,
                    label: 'Tugas',
                    onTap: () => _open(
                      AssignmentsScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                  MenuIconTile(
                    icon: Icons.bar_chart_outlined,
                    label: 'Nilai',
                    onTap: () => _open(
                      GradesScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                  MenuIconTile(
                    icon: Icons.fact_check_outlined,
                    label: 'Presensi',
                    onTap: () => _open(
                      AttendanceScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                  MenuIconTile(
                    icon: Icons.badge_outlined,
                    label: 'KTM',
                    onTap: () =>
                        _open(KtmScreen(controller: widget.controller)),
                  ),
                  MenuIconTile(
                    icon: Icons.edit_note_outlined,
                    label: 'KRS',
                    onTap: () => _open(
                      KrsScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                  MenuIconTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'DHS',
                    onTap: () => _open(
                      DhsScreen(
                        controller: widget.controller,
                        repository: widget.repository,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.md,
                AppSpacing.pageH,
                AppSpacing.lg,
              ),
              child: const DemoNotice(
                text:
                    'Seluruh isi Akademik adalah data contoh. Tidak terhubung '
                    'dengan SIAKAD atau sistem kampus mana pun.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                0,
                AppSpacing.pageH,
                AppSpacing.md,
              ),
              child: const Text(
                'Mata kuliah semester berjalan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ..._courseCards(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _courseCards(BuildContext context) {
    const courses = [
      ('MK-01', 'Pemrograman Mobile', 'Dr. Rina Kusuma', 3),
      ('MK-02', 'Basis Data', 'Bagus Santoso', 3),
      ('MK-03', 'Jaringan Komputer', 'Siti Aminah', 3),
      ('MK-04', 'Pemrograman Web', 'Andi Pratama', 3),
      ('MK-05', 'Multimedia', 'Dewi Lestari', 3),
      ('MK-06', 'Statistika', 'Fajar Nugroho', 2),
      ('MK-07', 'Kecerdasan Buatan', 'Nadia Puspita', 3),
      ('MK-08', 'Keamanan Siber', 'Yoga Saputra', 3),
    ];

    return [
      for (final course in courses)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            0,
            AppSpacing.pageH,
            AppSpacing.md,
          ),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            onTap: () => _open(
              MaterialsScreen(
                controller: widget.controller,
                repository: widget.repository,
                courseCode: course.$1,
                courseName: course.$2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      course.$1,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.iconNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${course.$3} - ${course.$4} SKS',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
