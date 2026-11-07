import 'package:flutter/material.dart';

import '../../../shared/matkul_reference.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';
import '../data/models/nilai_model.dart';

/// Layar rincian komponen nilai untuk satu mata kuliah.
class NilaiDetailScreen extends StatelessWidget {
  const NilaiDetailScreen({super.key, required this.nilai});

  final Nilai nilai;

  @override
  Widget build(BuildContext context) {
    final info = MatkulReference.find(nilai.kdMatkul);
    final nama = info?.nama ?? nilai.kdMatkul;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Nilai'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          _CourseHeader(
            nama: nama.isEmpty ? '-' : nama,
            kode: nilai.kdMatkul,
            sks: info?.sks,
            hm: nilai.hm,
            semesterLabel: nilai.semesterLabel,
          ),
          if (info == null) ...[
            const SizedBox(height: AppSpacing.md),
            const _UnknownCourseNotice(),
          ],
          const SizedBox(height: AppSpacing.lg),
          _ComponentCard(nilai: nilai),
          const SizedBox(height: AppSpacing.lg),
          _ResultCard(nilai: nilai),
        ],
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.nama,
    required this.kode,
    required this.sks,
    required this.hm,
    required this.semesterLabel,
  });

  final String nama;
  final String kode;
  final int? sks;
  final String hm;
  final String semesterLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primarySoft,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              StatusBadge(
                label: hm.isEmpty ? '-' : hm,
                color: _letterColor(hm),
                background: _letterBackground(hm),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoChip(icon: Icons.tag, label: kode.isEmpty ? '-' : kode),
              _InfoChip(
                icon: Icons.menu_book_outlined,
                label: sks == null ? 'SKS belum diketahui' : '$sks SKS',
              ),
              _InfoChip(
                icon: Icons.calendar_month_outlined,
                label: semesterLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _letterColor(String letter) {
    final value = letter.toUpperCase().trim();
    if (value == 'A' || value == 'A-') return AppColors.success;
    if (value.startsWith('B')) return AppColors.info;
    if (value.startsWith('C')) return AppColors.warning;
    return AppColors.danger;
  }

  static Color _letterBackground(String letter) {
    final value = letter.toUpperCase().trim();
    if (value == 'A' || value == 'A-') return AppColors.successBg;
    if (value.startsWith('B')) return AppColors.infoBg;
    if (value.startsWith('C')) return AppColors.warningBg;
    return AppColors.dangerBg;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.nilai});

  final Nilai nilai;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Komponen Nilai',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _ComponentHeader(),
          const Divider(height: 1, color: AppColors.divider),
          _ComponentRow(label: 'UTS', raw: nilai.uts, weighted: nilai.naUts),
          _ComponentRow(label: 'UAS', raw: nilai.uas, weighted: nilai.naUas),
          _ComponentRow(label: 'Quis', raw: nilai.quis, weighted: nilai.naQuis),
          _ComponentRow(
            label: 'Tugas',
            raw: nilai.tugas,
            weighted: nilai.naTugas,
          ),
          _ComponentRow(
            label: 'Kehadiran',
            raw: nilai.hadir,
            weighted: nilai.naHadir,
          ),
        ],
      ),
    );
  }
}

class _ComponentHeader extends StatelessWidget {
  const _ComponentHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Komponen',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Nilai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Kontribusi',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({
    required this.label,
    required this.raw,
    required this.weighted,
  });

  final String label;
  final double raw;
  final double weighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              raw.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              weighted.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.nilai});

  final Nilai nilai;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Akhir',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ResultItem(
                  label: 'Nilai Akhir',
                  value: nilai.na.toStringAsFixed(2),
                  highlight: true,
                ),
              ),
              Expanded(
                child: _ResultItem(
                  label: 'Huruf Mutu',
                  value: nilai.hm.isEmpty ? '-' : nilai.hm,
                ),
              ),
              Expanded(
                child: _ResultItem(
                  label: 'Angka Mutu',
                  value: nilai.am.toStringAsFixed(2),
                ),
              ),
              Expanded(
                child: _ResultItem(
                  label: 'Mutu',
                  value: nilai.mutu.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Kontribusi = nilai komponen setelah dikalikan bobot oleh API.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: highlight ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _UnknownCourseNotice extends StatelessWidget {
  const _UnknownCourseNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kode mata kuliah ini belum terdaftar di tabel referensi lokal. '
              'Nama dan SKS belum tersedia, dan nilainya tidak dihitung '
              'dalam IPS/IPK.',
              style: TextStyle(
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
