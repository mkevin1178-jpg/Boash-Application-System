import 'package:flutter/material.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../shared/api_detail_row.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../data/datasources/informasi_remote_ds.dart';
import '../data/models/informasi_model.dart';
import '../data/repositories/informasi_repository.dart';

class InformasiScreen extends StatefulWidget {
  const InformasiScreen({super.key, this.repository});

  final InformasiRepository? repository;

  @override
  State<InformasiScreen> createState() => _InformasiScreenState();
}

class _InformasiScreenState extends State<InformasiScreen> {
  late final InformasiRepository _repository;
  late final AsyncController<List<Informasi>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        InformasiRepositoryImpl(InformasiRemoteDataSourceImpl());
    _controller = AsyncController<List<Informasi>>(_repository.fetchFromSofi);
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
        title: const Text('Informasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Informasi>>(
        controller: _controller,
        isEmpty: (items) => items.isEmpty,
        loadingMessage: 'Memuat informasi...',
        emptyTitle: 'Belum ada informasi',
        emptyMessage:
            'Tidak ada informasi dari ${InformasiRepository.sofiSourceName} '
            'pada server.',
        emptyIcon: Icons.info_outline,
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
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => InformasiDetailScreen(item: item),
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
                          '${_dateLabel(item.tglPosting, item.tglPostingRaw)}'
                          ' · ${apiText(item.informasiDari)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.ringkasan.isEmpty ? '-' : item.ringkasan,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.textSecondary,
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

class InformasiDetailScreen extends StatelessWidget {
  const InformasiDetailScreen({super.key, required this.item});

  final Informasi item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Informasi')),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ApiDetailRow(
                  label: 'Tanggal',
                  value: _dateLabel(item.tglPosting, item.tglPostingRaw),
                ),
                ApiDetailRow(
                  label: 'Sumber',
                  value: apiText(item.informasiDari),
                ),
                ApiDetailRow(
                  label: 'Kode program studi',
                  value: item.kdProgstudi.toString(),
                ),
                ApiDetailRow(
                  label: 'ID informasi',
                  value: apiText(item.idInformasi),
                ),
                const Divider(height: AppSpacing.xl),
                Text(
                  item.isi.isEmpty ? '-' : item.isi,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
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

String _dateLabel(DateTime? date, String raw) =>
    date == null ? apiText(raw) : DateFormat.shortDate(date);
