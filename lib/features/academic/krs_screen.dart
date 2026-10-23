import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../data/demo_repository.dart';
import '../../models/course.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/status_badge.dart';

/// Halaman KRS (Kartu Rencana Studi) — diakses melalui Akademik → KRS.
///
/// Menampilkan daftar mata kuliah yang tersedia dan memungkinkan mahasiswa
/// memilih mata kuliah untuk rencana studi semester mendatang.
///
/// **Status backend:** belum terhubung ke API penyimpanan KRS.
/// Pilihan hanya tersimpan di memori selama sesi berlangsung.
class KrsScreen extends StatefulWidget {
  const KrsScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<KrsScreen> createState() => _KrsScreenState();
}

class _KrsScreenState extends State<KrsScreen> {
  late final AsyncController<List<Course>> _coursesController;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _coursesController = AsyncController<List<Course>>(
      widget.repository.fetchCourses,
    );
    _coursesController.load();
  }

  @override
  void dispose() {
    _coursesController.dispose();
    super.dispose();
  }

  void _toggle(String code) {
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else {
        _selected.add(code);
      }
    });
  }

  int _totalSks(List<Course> courses) {
    return courses
        .where((c) => _selected.contains(c.code))
        .fold(0, (sum, c) => sum + c.credits);
  }

  void _submit(List<Course> courses) {
    if (_selected.isEmpty) {
      showAppSnackBar(
        context,
        'Pilih minimal satu mata kuliah sebelum mengajukan KRS.',
        variant: AppSnackBarVariant.error,
      );
      return;
    }
    // Backend KRS belum tersedia — tampilkan status jujur
    showAppSnackBar(
      context,
      'Demo: KRS tidak disimpan ke server pada versi ini. '
      'Fitur penyimpanan akan tersedia setelah API KRS terhubung.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;
    final nim = session?.nim ?? '-';
    final name = session?.fullName ?? 'Mahasiswa Demo';
    final prodi = session?.programStudi ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kartu Rencana Studi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Course>>(
        controller: _coursesController,
        loadingMessage: 'Memuat daftar mata kuliah...',
        isEmpty: (data) => data.isEmpty,
        emptyTitle: 'Tidak ada mata kuliah',
        emptyMessage: 'Daftar mata kuliah belum tersedia.',
        emptyIcon: Icons.list_alt_outlined,
        builder: (context, courses) {
          final totalSks = _totalSks(courses);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    AppSpacing.lg,
                    AppSpacing.pageH,
                    AppSpacing.md,
                  ),
                  children: [
                    const DemoNotice(
                      text:
                          'KRS ini adalah data contoh. Pilihan mata kuliah '
                          'tidak tersimpan ke sistem akademik. Backend KRS '
                          'belum terhubung.',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Identitas mahasiswa
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      color: AppColors.primarySoft,
                      showShadow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Text(
                                'Data Mahasiswa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _infoRow('NIM', nim),
                          _infoRow('Nama', name),
                          _infoRow('Program Studi', prodi),
                          _infoRow(
                            'Semester',
                            session?.semester ?? '-',
                          ),
                          _infoRow(
                            'Tahun Akademik',
                            session?.academicYear ?? '-',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Ringkasan SKS
                    _SksSummary(
                      totalSelected: _selected.length,
                      totalSks: totalSks,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Label daftar
                    Row(
                      children: [
                        const Text(
                          'Daftar Mata Kuliah Tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        DemoNote(
                          text: '${courses.length} MK',
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Daftar mata kuliah dengan checkbox
                    for (final course in courses)
                      _CourseCheckCard(
                        course: course,
                        selected: _selected.contains(course.code),
                        onToggle: () => _toggle(course.code),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),

              // Tombol ajukan di bawah
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH,
                  AppSpacing.md,
                  AppSpacing.pageH,
                  AppSpacing.pageBottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(
                  label: _selected.isEmpty
                      ? 'PILIH MATA KULIAH DULU'
                      : 'AJUKAN KRS ($totalSks SKS)',
                  icon: Icons.send_outlined,
                  onPressed: () => _submit(courses),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan jumlah MK dipilih dan total SKS.
class _SksSummary extends StatelessWidget {
  const _SksSummary({
    required this.totalSelected,
    required this.totalSks,
  });

  final int totalSelected;
  final int totalSks;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: '$totalSelected',
              label: 'MK Dipilih',
              highlighted: totalSelected > 0,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _Stat(
              value: '$totalSks',
              label: 'Total SKS',
              highlighted: totalSks > 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.primary : AppColors.textMuted;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Kartu satu mata kuliah dengan checkbox pilih.
class _CourseCheckCard extends StatelessWidget {
  const _CourseCheckCard({
    required this.course,
    required this.selected,
    required this.onToggle,
  });

  final Course course;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: onToggle,
        borderColor: selected ? AppColors.primary : null,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check : Icons.school_outlined,
                size: 20,
                color: selected ? AppColors.onPrimary : AppColors.iconNavy,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${course.code} · ${course.lecturer}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    course.room,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(
                  label: '${course.credits} SKS',
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  background: selected
                      ? AppColors.primarySoft
                      : AppColors.surfaceAlt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
