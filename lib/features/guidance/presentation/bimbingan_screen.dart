import 'package:flutter/material.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../shared/api_detail_row.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';
import '../data/datasources/bimbingan_remote_ds.dart';
import '../data/models/bimbingan_model.dart';
import '../data/repositories/bimbingan_repository.dart';

class BimbinganScreen extends StatefulWidget {
  const BimbinganScreen({super.key, required this.npm, this.repository});

  final String npm;
  final BimbinganRepository? repository;

  @override
  State<BimbinganScreen> createState() => _BimbinganScreenState();
}

class _BimbinganScreenState extends State<BimbinganScreen> {
  late final BimbinganRepository _repository;
  late final AsyncController<List<Bimbingan>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        BimbinganRepositoryImpl(BimbinganRemoteDataSourceImpl());
    _controller = AsyncController<List<Bimbingan>>(
      () => _repository.fetchByNpm(widget.npm),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bimbingan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Bimbingan>>(
        controller: _controller,
        isEmpty: (items) => items.isEmpty,
        loadingMessage: 'Memuat data bimbingan...',
        emptyTitle: 'Belum ada data bimbingan',
        emptyMessage: 'Data bimbingan untuk NPM ini belum tersedia.',
        emptyIcon: Icons.school_outlined,
        builder: (context, items) => RefreshIndicator(
          onRefresh: () => _controller.load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.lg,
              AppSpacing.pageH,
              AppSpacing.pageBottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text(
                'Riwayat bimbingan (${items.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BimbinganDetailScreen(item: item),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apiText(item.judul),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          apiText(item.topik),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            StatusBadge.neutral('NIP ${apiText(item.nip)}'),
                            const SizedBox(width: AppSpacing.xs),
                            StatusBadge.neutral(
                              'Status data ${item.statusData}',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${_dateLabel(item.tglMulai, item.tglMulaiRaw)}'
                          ' s.d. '
                          '${_dateLabel(item.tglSelesai, item.tglSelesaiRaw)}'
                          ' · ${apiText(item.thnAkademik)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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

class BimbinganDetailScreen extends StatelessWidget {
  const BimbinganDetailScreen({super.key, required this.item});

  final Bimbingan item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Bimbingan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apiText(item.judul),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ApiDetailRow(label: 'Topik', value: apiText(item.topik)),
                ApiDetailRow(
                  label: 'Permasalahan',
                  value: apiText(item.permasalahan),
                ),
                ApiDetailRow(label: 'NPM', value: apiText(item.npm)),
                ApiDetailRow(label: 'NIP dosen', value: apiText(item.nip)),
                ApiDetailRow(
                  label: 'Tahun akademik',
                  value: apiText(item.thnAkademik),
                ),
                ApiDetailRow(
                  label: 'Tanggal mulai',
                  value: _dateLabel(item.tglMulai, item.tglMulaiRaw),
                ),
                ApiDetailRow(
                  label: 'Tanggal selesai',
                  value: _dateLabel(item.tglSelesai, item.tglSelesaiRaw),
                ),
                ApiDetailRow(
                  label: 'Proposal',
                  value: apiText(item.proposal.toString()),
                ),
                ApiDetailRow(
                  label: 'SK proposal',
                  value: apiText(item.skProposal),
                ),
                ApiDetailRow(
                  label: 'Status proposal',
                  value: item.statusProposal.toString(),
                ),
                ApiDetailRow(
                  label: 'Tugas akhir',
                  value: apiText(item.tugasAkhir),
                ),
                ApiDetailRow(
                  label: 'SK tugas akhir',
                  value: apiText(item.skTugasAkhir),
                ),
                ApiDetailRow(
                  label: 'Status tugas akhir',
                  value: item.statusTugasAkhir.toString(),
                ),
                ApiDetailRow(
                  label: 'Status data',
                  value: item.statusData.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime? date, String raw) =>
    date == null ? apiText(raw) : DateFormat.shortDate(date);
