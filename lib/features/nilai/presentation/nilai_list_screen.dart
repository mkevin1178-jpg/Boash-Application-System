import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/demo_note.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_view.dart';
import '../data/datasources/nilai_remote_ds.dart';
import '../data/repositories/nilai_repository.dart';
import '../domain/ips_calculator.dart';
import 'nilai_controller.dart';
import 'nilai_detail_screen.dart';
import 'widgets/nilai_course_tile.dart';
import 'widgets/nilai_summary_card.dart';

/// Layar daftar nilai mahasiswa, dikelompokkan per tahun akademik + semester.
class NilaiListScreen extends StatefulWidget {
  const NilaiListScreen({super.key, required this.npm, this.repository});

  /// NPM dari sesi login.
  final String npm;

  /// Opsional untuk pengujian; bila null dibuat repository HTTP default.
  final NilaiRepository? repository;

  @override
  State<NilaiListScreen> createState() => _NilaiListScreenState();
}

class _NilaiListScreenState extends State<NilaiListScreen> {
  late final NilaiRepository _repository;
  late final NilaiController _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? NilaiRepositoryImpl(NilaiRemoteDataSourceImpl());
    _controller = NilaiController(repository: _repository, npm: widget.npm)
      ..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _controller.load(force: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nilai Mahasiswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return switch (_controller.state) {
            NilaiLoading() => const LoadingView(message: 'Memuat nilai...'),
            NilaiEmpty(:final message) => _EmptyNilai(
              message: message,
              onRefresh: _refresh,
            ),
            NilaiError(:final message) => ErrorState(
              title: 'Gagal memuat nilai',
              message: message,
              onRetry: _refresh,
            ),
            NilaiLoaded(:final groups, :final summary) => _NilaiContent(
              npm: widget.npm,
              groups: groups,
              summary: summary,
              onRefresh: _refresh,
            ),
          };
        },
      ),
    );
  }
}

class _NilaiContent extends StatelessWidget {
  const _NilaiContent({
    required this.npm,
    required this.groups,
    required this.summary,
    required this.onRefresh,
  });

  final String npm;
  final List<SemesterGroup> groups;
  final AcademicSummary summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          DemoNotice(
            text:
                'Nilai diambil dari API MockAPI berdasarkan NPM '
                '${npm.trim()}. Data ini simulasi, bukan nilai resmi.',
          ),
          const SizedBox(height: AppSpacing.lg),
          NilaiSummaryCard(summary: summary),
          if (summary.hasUnknownCourses) ...[
            const SizedBox(height: AppSpacing.md),
            _UnknownOverallWarning(codes: summary.unknownCourseCodes),
          ],
          const SizedBox(height: AppSpacing.xl),
          for (final group in groups) ...[
            SemesterSummaryCard(group: group),
            const SizedBox(height: AppSpacing.md),
            for (final nilai in group.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NilaiCourseTile(
                  nilai: nilai,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NilaiDetailScreen(nilai: nilai),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _EmptyNilai extends StatelessWidget {
  const _EmptyNilai({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
          EmptyState(
            title: 'Belum ada data nilai',
            message: message,
            icon: Icons.bar_chart_outlined,
          ),
        ],
      ),
    );
  }
}

class _UnknownOverallWarning extends StatelessWidget {
  const _UnknownOverallWarning({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Matkul ${codes.join(', ')} tidak ditemukan di tabel '
              'referensi lokal sehingga tidak dihitung dalam IPK.',
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
