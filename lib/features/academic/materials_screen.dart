import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/course_material.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';

/// Halaman materi perkuliahan.
///
/// [courseCode] bila diisi, daftar difilter hanya untuk mata kuliah itu.
class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({
    super.key,
    required this.controller,
    required this.repository,
    this.courseCode,
    this.courseName,
  });

  final AppController controller;
  final DemoRepository repository;
  final String? courseCode;
  final String? courseName;

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  late final AsyncController<List<CourseMaterial>> _materialsController;

  @override
  void initState() {
    super.initState();
    _materialsController = AsyncController<List<CourseMaterial>>(_load);
    _materialsController.load();
  }

  @override
  void dispose() {
    _materialsController.dispose();
    super.dispose();
  }

  Future<List<CourseMaterial>> _load() async {
    final all = await widget.repository.fetchMaterials();
    final code = widget.courseCode;
    if (code == null) return all;
    return all
        .where((material) => material.courseCode == code)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.courseName == null
        ? 'Materi Perkuliahan'
        : 'Materi ${widget.courseName}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<CourseMaterial>>(
        controller: _materialsController,
        loadingMessage: 'Memuat materi...',
        isEmpty: (data) => data.isEmpty,
        emptyTitle: 'Belum ada materi',
        emptyMessage: 'Tidak ada materi yang diunggah untuk mata kuliah ini.',
        emptyIcon: Icons.menu_book_outlined,
        builder: (context, materials) => RefreshIndicator(
          onRefresh: () => _materialsController.load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.lg,
              AppSpacing.pageH,
              AppSpacing.pageBottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const DemoNotice(
                text:
                    'Materi contoh. Aksi buka dan unduh hanya menampilkan '
                    'pesan demo karena berkas tidak disertakan.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final material in materials)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _MaterialCard(material: material),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu satu materi.
class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material});

  final CourseMaterial material;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                material.type,
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
                  material.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material.courseName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.update,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.shortDate(material.updatedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.save_outlined,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      material.sizeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showAppSnackBar(
              context,
              'Demo: materi "${material.title}" tidak dapat diunduh.',
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Buka'),
          ),
        ],
      ),
    );
  }
}
