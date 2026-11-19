import 'package:flutter/material.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../shared/api_detail_row.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/page_header.dart';
import '../data/datasources/berita_remote_ds.dart';
import '../data/models/berita_model.dart';
import '../data/repositories/berita_repository.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.repository});

  final BeritaRepository? repository;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final BeritaRepository _repository;
  late final AsyncController<List<Berita>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? BeritaRepositoryImpl(BeritaRemoteDataSourceImpl());
    _controller = AsyncController<List<Berita>>(_repository.fetchAll);
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(
              title: 'Berita Kampus',
              subtitle: 'Informasi terbaru dari server BAS',
            ),
            Expanded(
              child: AsyncBuilder<List<Berita>>(
                controller: _controller,
                isEmpty: (items) => items.isEmpty,
                loadingMessage: 'Memuat berita...',
                emptyTitle: 'Belum ada berita',
                emptyMessage: 'Berita kampus belum tersedia di server.',
                emptyIcon: Icons.article_outlined,
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
                                builder: (_) => NewsDetailScreen(item: item),
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
                                  ' · ${apiText(item.beritaDari)}',
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
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.item});

  final Berita item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Berita')),
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
                ApiDetailRow(label: 'Sumber', value: apiText(item.beritaDari)),
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
