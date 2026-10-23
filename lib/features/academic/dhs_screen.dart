import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../data/demo_repository.dart';
import '../../models/grade.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/status_badge.dart';

/// Halaman DHS (Daftar Hasil Studi) — diakses melalui Akademik → DHS.
///
/// Menampilkan rekap nilai per semester dalam format Kartu Hasil Studi (KHS)
/// seperti pada SIAKAD Indonesia, mencakup:
/// - Kode & nama mata kuliah, SKS, nilai angka (NA), huruf mutu (HM),
///   angka mutu (AM), dan nilai mutu (AM × SKS).
/// - Ringkasan: total SKS, total mutu, IPS (Indeks Prestasi Semester), IPK.
///
/// Data diambil dari API mockapi.io berdasarkan NPM mahasiswa yang login,
/// dengan fallback ke data demo lokal jika API tidak tersedia.
class DhsScreen extends StatefulWidget {
  const DhsScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<DhsScreen> createState() => _DhsScreenState();
}

class _DhsScreenState extends State<DhsScreen> {
  late final AsyncController<List<DhsGrade>> _dhsController;

  @override
  void initState() {
    super.initState();
    final npm = widget.controller.session?.nim ?? '';
    _dhsController = AsyncController<List<DhsGrade>>(
      () => widget.repository.fetchDhsGrades(npm),
    );
    _dhsController.load();
  }

  @override
  void dispose() {
    _dhsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;
    final nim = session?.nim ?? '-';
    final name = session?.fullName ?? 'Mahasiswa Demo';
    final prodi = session?.programStudi ?? '-';
    final faculty = session?.faculty ?? '-';
    final semester = session?.semester ?? '-';
    final academicYear = session?.academicYear ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Hasil Studi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Unduh DHS',
            onPressed: () => showAppSnackBar(
              context,
              'Demo: Unduh DHS tidak tersedia pada versi ini.',
            ),
          ),
        ],
      ),
      body: AsyncBuilder<List<DhsGrade>>(
        controller: _dhsController,
        loadingMessage: 'Memuat daftar hasil studi...',
        isEmpty: (data) => data.isEmpty,
        emptyTitle: 'Belum ada data nilai',
        emptyMessage: 'Daftar hasil studi semester ini belum tersedia.',
        emptyIcon: Icons.assignment_outlined,
        builder: (context, dhsGrades) => RefreshIndicator(
          onRefresh: () => _dhsController.load(force: true),
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
                    'DHS ini adalah data contoh (simulasi). Nilai yang '
                    'ditampilkan bukan nilai resmi dari sistem akademik.',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header KHS — identitas mahasiswa
              _KhsHeader(
                nim: nim,
                name: name,
                prodi: prodi,
                faculty: faculty,
                semester: semester,
                academicYear: academicYear,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tabel nilai
              _DhsTable(dhsGrades: dhsGrades),
              const SizedBox(height: AppSpacing.lg),

              // Ringkasan IPS/IPK
              _IpsSummary(dhsGrades: dhsGrades),
              const SizedBox(height: AppSpacing.lg),

              // Legenda nilai
              const _GradeLegend(),
              const SizedBox(height: AppSpacing.md),

              // Catatan
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                showShadow: false,
                color: AppColors.surfaceAlt,
                child: const Text(
                  'DHS dapat dijadikan referensi informal. Untuk keperluan '
                  'resmi, cetak transkrip dari portal akademik kampus.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header KHS — menampilkan identitas mahasiswa seperti pada KHS cetak.
class _KhsHeader extends StatelessWidget {
  const _KhsHeader({
    required this.nim,
    required this.name,
    required this.prodi,
    required this.faculty,
    required this.semester,
    required this.academicYear,
  });

  final String nim;
  final String name;
  final String prodi;
  final String faculty;
  final String semester;
  final String academicYear;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header gradient — judul
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.bgGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UNIVERSITAS NUSANTARA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          Text(
                            'DAFTAR HASIL STUDI — DEMO',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.2,
                              color: AppColors.onPrimarySoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const DemoNote(text: 'DEMO', compact: true),
                  ],
                ),
              ],
            ),
          ),

          // Data mahasiswa
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _headerRow('NIM', nim),
                const Divider(height: 1, color: AppColors.divider),
                _headerRow('Nama', name),
                const Divider(height: 1, color: AppColors.divider),
                _headerRow('Program Studi', prodi),
                const Divider(height: 1, color: AppColors.divider),
                _headerRow('Fakultas', faculty),
                const Divider(height: 1, color: AppColors.divider),
                _headerRow('Semester', semester),
                const Divider(height: 1, color: AppColors.divider),
                _headerRow('Tahun Akademik', academicYear),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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

/// Tabel nilai DHS — format KHS SIAKAD Indonesia.
///
/// Kolom: No | Kode MK | Nama MK | SKS | NA | HM | AM | Mutu
class _DhsTable extends StatelessWidget {
  const _DhsTable({required this.dhsGrades});

  final List<DhsGrade> dhsGrades;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header tabel
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                _TH('No', flex: 1, center: true),
                _TH('Kode MK', flex: 3),
                _TH('Nama Mata Kuliah', flex: 6),
                _TH('SKS', flex: 2, center: true),
                _TH('NA', flex: 2, center: true),
                _TH('HM', flex: 2, center: true),
                _TH('AM', flex: 2, center: true),
                _TH('Mutu', flex: 2, center: true),
              ],
            ),
          ),

          // Baris data
          for (var i = 0; i < dhsGrades.length; i++) ...[
            _DhsRow(
              index: i + 1,
              grade: dhsGrades[i],
              even: i.isEven,
            ),
            if (i < dhsGrades.length - 1)
              const Divider(height: 1, color: AppColors.divider, indent: 12, endIndent: 12),
          ],

          // Footer semester jika ada info semester
          if (dhsGrades.isNotEmpty && dhsGrades.first.thnAkademik.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                dhsGrades.first.semesterLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Header kolom tabel.
class _TH extends StatelessWidget {
  const _TH(this.text, {required this.flex, this.center = false});

  final String text;
  final int flex;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Satu baris data nilai DHS.
class _DhsRow extends StatelessWidget {
  const _DhsRow({
    required this.index,
    required this.grade,
    required this.even,
  });

  final int index;
  final DhsGrade grade;
  final bool even;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: even ? AppColors.surface : AppColors.surfaceAlt.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No
          Expanded(
            flex: 1,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Kode MK
          Expanded(
            flex: 3,
            child: Text(
              grade.courseCode,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.iconNavy,
              ),
            ),
          ),
          // Nama MK
          Expanded(
            flex: 6,
            child: Text(
              grade.courseName,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // SKS
          Expanded(
            flex: 2,
            child: Text(
              '${grade.credits}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // NA
          Expanded(
            flex: 2,
            child: Text(
              grade.na.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // HM (Huruf Mutu)
          Expanded(
            flex: 2,
            child: Center(
              child: StatusBadge(
                label: grade.hm,
                color: _hmColor(grade.hm),
                background: _hmBackground(grade.hm),
                dense: true,
              ),
            ),
          ),
          // AM (Angka Mutu)
          Expanded(
            flex: 2,
            child: Text(
              grade.am.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Mutu (AM × SKS)
          Expanded(
            flex: 2,
            child: Text(
              grade.mutu.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _hmColor(String hm) {
    final upper = hm.toUpperCase().trim();
    if (upper == 'A' || upper == 'A-') return AppColors.success;
    if (upper.startsWith('B')) return AppColors.info;
    if (upper.startsWith('C')) return AppColors.warning;
    return AppColors.danger;
  }

  static Color _hmBackground(String hm) {
    final upper = hm.toUpperCase().trim();
    if (upper == 'A' || upper == 'A-') return AppColors.successBg;
    if (upper.startsWith('B')) return AppColors.infoBg;
    if (upper.startsWith('C')) return AppColors.warningBg;
    return AppColors.dangerBg;
  }
}

/// Ringkasan IPS (Indeks Prestasi Semester) berdasarkan tabel nilai.
///
/// Rumus: IPS = Total Mutu / Total SKS
class _IpsSummary extends StatelessWidget {
  const _IpsSummary({required this.dhsGrades});

  final List<DhsGrade> dhsGrades;

  @override
  Widget build(BuildContext context) {
    final totalSks = dhsGrades.fold(0, (sum, g) => sum + g.credits);
    final totalMutu = dhsGrades.fold(0.0, (sum, g) => sum + g.mutu);
    final ips = totalSks > 0 ? totalMutu / totalSks : 0.0;
    final lulusCount = dhsGrades.where((g) => g.am >= 2.0).length;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Ringkasan Hasil Studi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Total SKS',
                  value: '$totalSks',
                  icon: Icons.library_books_outlined,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Total Mutu',
                  value: totalMutu.toStringAsFixed(2),
                  icon: Icons.calculate_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'IPS',
                  value: ips.toStringAsFixed(2),
                  icon: Icons.trending_up_outlined,
                  highlight: true,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'MK Lulus',
                  value: '$lulusCount / ${dhsGrades.length}',
                  icon: Icons.check_circle_outline,
                  highlight: lulusCount == dhsGrades.length,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Bar IPS visual
          _IpsBar(ips: ips),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '* IPS = Total Mutu ÷ Total SKS. IPK dihitung dari seluruh semester.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: highlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar visual IPS dari 0–4.
class _IpsBar extends StatelessWidget {
  const _IpsBar({required this.ips});

  final double ips;

  @override
  Widget build(BuildContext context) {
    final fraction = (ips / 4.0).clamp(0.0, 1.0);
    final color = ips >= 3.5
        ? AppColors.success
        : ips >= 3.0
        ? AppColors.info
        : ips >= 2.5
        ? AppColors.warning
        : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'IPS',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              '${ips.toStringAsFixed(2)} / 4.00',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Legenda konversi huruf mutu ke angka mutu.
class _GradeLegend extends StatelessWidget {
  const _GradeLegend();

  @override
  Widget build(BuildContext context) {
    const legend = [
      ('A', '4.00', '85–100'),
      ('B+', '3.50', '75–84'),
      ('B', '3.00', '70–74'),
      ('C+', '2.50', '65–69'),
      ('C', '2.00', '60–64'),
      ('D', '1.00', '55–59'),
      ('E', '0.00', '< 55'),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      showShadow: false,
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konversi Nilai',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final item in legend)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
