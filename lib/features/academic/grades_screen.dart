import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../data/demo_repository.dart';
import '../../models/grade.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/status_badge.dart';

/// Halaman nilai demo per mata kuliah beserta ringkasan semester.
///
/// Data diambil dari API mockapi.io berdasarkan NPM mahasiswa yang login.
/// Jika NPM tidak tersedia atau API gagal, fallback ke data demo lokal.
class GradesScreen extends StatefulWidget {
  const GradesScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  late final AsyncController<List<Grade>> _gradesController;

  @override
  void initState() {
    super.initState();
    final npm = widget.controller.session?.nim ?? '';
    _gradesController = AsyncController<List<Grade>>(
      () => widget.repository.fetchApiGrades(npm),
    );
    _gradesController.load();
  }

  @override
  void dispose() {
    _gradesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final npm = widget.controller.session?.nim ?? '';
    final isApiMode = npm.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nilai'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Grade>>(
        controller: _gradesController,
        loadingMessage: 'Memuat nilai...',
        isEmpty: (data) => data.isEmpty,
        emptyTitle: 'Belum ada nilai',
        emptyMessage: 'Nilai semester ini belum tersedia.',
        emptyIcon: Icons.bar_chart_outlined,
        builder: (context, grades) => RefreshIndicator(
          onRefresh: () => _gradesController.load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.lg,
              AppSpacing.pageH,
              AppSpacing.pageBottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              DemoNotice(
                text: isApiMode
                    ? 'Nilai diambil dari API mockapi.io berdasarkan NPM '
                        '$npm. Data ini adalah simulasi untuk prototipe PBL, '
                        'bukan nilai resmi dari sistem akademik.'
                    : 'Nilai di bawah adalah data contoh untuk prototipe PBL, '
                        'bukan nilai resmi dari sistem akademik.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _SummaryCard(grades: grades),
              const SizedBox(height: AppSpacing.lg),
              for (final grade in grades)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _GradeCard(grade: grade),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ringkasan semester: IPK dan jumlah nilai.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.grades});

  final List<Grade> grades;

  @override
  Widget build(BuildContext context) {
    final average = grades.isEmpty
        ? 0.0
        : grades.fold(0.0, (sum, grade) => sum + grade.totalScore) /
              grades.length;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      color: AppColors.primarySoft,
      showShadow: false,
      child: Row(
        children: [
          Expanded(
            child: _Stat(value: average.toStringAsFixed(2), label: 'Rata-rata'),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _Stat(value: '${grades.length}', label: 'Mata kuliah'),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _Stat(
              value: '${grades.where((g) => g.totalScore >= 60).length}',
              label: 'Lulus',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

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
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Kartu nilai satu mata kuliah.
class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade});

  final Grade grade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  grade.courseName.isNotEmpty
                      ? grade.courseName
                      : grade.courseCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(
                label: grade.letterGrade,
                color: _letterColor(grade.letterGrade),
                background: _letterBackground(grade.letterGrade),
              ),
            ],
          ),
          if (grade.courseName.isNotEmpty && grade.courseName != grade.courseCode)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                grade.courseCode,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Score(
                  label: 'Tugas',
                  value: grade.taskScore,
                ),
              ),
              Expanded(
                child: _Score(
                  label: 'UTS',
                  value: grade.midTermScore,
                ),
              ),
              Expanded(
                child: _Score(
                  label: 'UAS',
                  value: grade.finalScore,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Row(
              children: [
                const Text(
                  'Nilai akhir',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  grade.totalScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _letterColor(String letter) {
    if (letter == 'A' || letter == 'A-') return AppColors.success;
    if (letter.startsWith('B')) return AppColors.info;
    if (letter.startsWith('C')) return AppColors.warning;
    return AppColors.danger;
  }

  static Color _letterBackground(String letter) {
    if (letter == 'A' || letter == 'A-') return AppColors.successBg;
    if (letter.startsWith('B')) return AppColors.infoBg;
    if (letter.startsWith('C')) return AppColors.warningBg;
    return AppColors.dangerBg;
  }
}

/// Komponen nilai dengan label.
class _Score extends StatelessWidget {
  const _Score({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
