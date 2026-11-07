import 'package:flutter/material.dart';

import '../../shared/matkul_reference.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_badge.dart';
import '../krs/data/datasources/krs_remote_ds.dart';
import '../krs/data/models/krs_model.dart';
import '../krs/data/repositories/krs_repository.dart';
import '../krs/presentation/krs_controller.dart';

/// Halaman KRS (Kartu Rencana Studi) — diakses melalui Akademik → KRS.
///
/// Data diambil dari endpoint `/krs?npm=<NPM>` lalu dikelompokkan per tahun
/// akademik + semester. Nama matkul dan SKS berasal dari [MatkulReference].
///
/// **Status backend:** pengajuan KRS belum diimplementasikan. Tombol ajukan
/// sengaja dinonaktifkan agar tidak menampilkan sukses palsu.
class KrsScreen extends StatefulWidget {
  const KrsScreen({super.key, required this.controller, this.repository});

  final AppController controller;

  /// Opsional untuk pengujian; bila null dibuat repository HTTP default.
  final KrsRepository? repository;

  @override
  State<KrsScreen> createState() => _KrsScreenState();
}

class _KrsScreenState extends State<KrsScreen> {
  late final KrsRepository _repository;
  late final KrsController _krsController;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? KrsRepositoryImpl(KrsRemoteDataSourceImpl());
    _krsController = KrsController(
      repository: _repository,
      npm: widget.controller.session?.npm ?? '',
    )..load();
  }

  @override
  void dispose() {
    _krsController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _krsController.load(force: true);

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kartu Rencana Studi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _krsController,
              builder: (context, _) {
                return switch (_krsController.state) {
                  KrsLoading() => const LoadingView(message: 'Memuat KRS...'),
                  KrsEmpty(:final message) => _EmptyKrs(
                    message: message,
                    onRefresh: _refresh,
                  ),
                  KrsError(:final message) => ErrorState(
                    title: 'Gagal memuat KRS',
                    message: message,
                    onRetry: _refresh,
                  ),
                  KrsLoaded(:final groups) => _KrsContent(
                    npm: session?.npm ?? '-',
                    name: session?.fullName ?? 'Mahasiswa',
                    prodi: session?.programStudi ?? '-',
                    semester: session?.semester ?? '-',
                    academicYear: session?.academicYear ?? '-',
                    groups: groups,
                    onRefresh: _refresh,
                  ),
                };
              },
            ),
          ),
          const _SubmissionBar(),
        ],
      ),
    );
  }
}

/// Bar bawah dengan tombol pengajuan yang belum terhubung ke server.
class _SubmissionBar extends StatelessWidget {
  const _SubmissionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pengajuan KRS belum terhubung ke server.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppButton(
            label: 'AJUKAN KRS',
            icon: Icons.send_outlined,
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class _KrsContent extends StatelessWidget {
  const _KrsContent({
    required this.npm,
    required this.name,
    required this.prodi,
    required this.semester,
    required this.academicYear,
    required this.groups,
    required this.onRefresh,
  });

  final String npm;
  final String name;
  final String prodi;
  final String semester;
  final String academicYear;
  final List<KrsGroup> groups;
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
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.primarySoft,
            showShadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
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
                _infoRow('NIM', npm),
                _infoRow('Nama', name),
                _infoRow('Kode Prodi', prodi),
                _infoRow('Semester', semester),
                _infoRow('Tahun Akademik', academicYear),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DemoNotice(
            text:
                'KRS diambil dari API MockAPI berdasarkan NPM $npm. '
                'Nilai status ditampilkan apa adanya karena artinya belum '
                'dikonfirmasi.',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final group in groups) ...[
            _GroupHeader(group: group),
            const SizedBox(height: AppSpacing.md),
            for (final item in group.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _KrsCard(item: item),
              ),
            if (group.hasUnknownCourses) ...[
              _UnknownWarning(codes: group.unknownCourseCodes),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final KrsGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            group.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        StatusBadge(
          label: '${group.totalSks} SKS',
          color: AppColors.primary,
          background: AppColors.primarySoft,
          dense: true,
        ),
      ],
    );
  }
}

class _KrsCard extends StatelessWidget {
  const _KrsCard({required this.item});

  final KrsItem item;

  @override
  Widget build(BuildContext context) {
    final info = MatkulReference.find(item.kdMatkul);
    final nama = info?.nama ?? item.kdMatkul;
    final sksLabel = info == null ? 'SKS ?' : '${info.sks} SKS';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 20,
              color: AppColors.iconNavy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama.isEmpty ? '-' : nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.kdMatkul} · Kelas ${item.kdKelas.isEmpty ? '-' : item.kdKelas}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      sksLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: info == null
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (info == null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // TODO: arti status belum dikonfirmasi.
          StatusBadge.neutral('Status: ${item.statusRaw}'),
        ],
      ),
    );
  }
}

class _UnknownWarning extends StatelessWidget {
  const _UnknownWarning({required this.codes});

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
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kode ${codes.join(', ')} belum ada di tabel referensi '
              'sehingga SKS-nya tidak dihitung pada total semester.',
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

class _EmptyKrs extends StatelessWidget {
  const _EmptyKrs({required this.message, required this.onRefresh});

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
            title: 'Belum ada data KRS',
            message: message,
            icon: Icons.list_alt_outlined,
            actionLabel: 'Coba lagi',
            onAction: onRefresh,
          ),
        ],
      ),
    );
  }
}
