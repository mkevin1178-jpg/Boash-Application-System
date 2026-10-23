import 'package:flutter/material.dart';

import '../../core/async_builder.dart';
import '../../core/async_controller.dart';
import '../../core/date_format.dart';
import '../../data/demo_repository.dart';
import '../../models/announcement.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/demo_note.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'announcement_detail_screen.dart';

/// Halaman daftar pengumuman kampus.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({
    super.key,
    required this.controller,
    required this.repository,
  });

  final AppController controller;
  final DemoRepository repository;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AsyncController<List<Announcement>> _announcementsController;

  /// Kategori yang sedang difilter (null = semua kategori).
  AnnouncementCategory? _category;

  /// Kata kunci pencarian (lowercase).
  String _query = '';

  @override
  void initState() {
    super.initState();
    _announcementsController = AsyncController<List<Announcement>>(
      widget.repository.fetchAnnouncements,
    );
    _announcementsController.load();
  }

  @override
  void dispose() {
    _announcementsController.dispose();
    super.dispose();
  }

  List<Announcement> _filter(List<Announcement> items) {
    final query = _query.trim().toLowerCase();

    return items
        .where((item) {
          final matchCategory = _category == null || item.category == _category;
          final matchQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.summary.toLowerCase().contains(query);
          return matchCategory && matchQuery;
        })
        .toList(growable: false);
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
              title: 'Pengumuman',
              subtitle: 'Informasi akademik dan kampus (data contoh)',
            ),
            Expanded(
              child: AsyncBuilder<List<Announcement>>(
                controller: _announcementsController,
                loadingMessage: 'Memuat pengumuman...',
                builder: (context, items) {
                  final sorted = items.toList(growable: false)
                    ..sort((a, b) => b.date.compareTo(a.date));
                  final filtered = _filter(sorted);

                  return RefreshIndicator(
                    onRefresh: () => _announcementsController.load(force: true),
                    child: ListView(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.pageBottom,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _searchField(),
                        _categoryChips(sorted),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageH,
                            AppSpacing.md,
                            AppSpacing.pageH,
                            AppSpacing.md,
                          ),
                          child: DemoNote(
                            text:
                                'Seluruh pengumuman di bawah adalah data '
                                'contoh untuk prototipe PBL.',
                            compact: true,
                          ),
                        ),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageH,
                            ),
                            child: AppCard(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 30,
                                    color: AppColors.iconNavy,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Tidak ada pengumuman yang cocok',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Ubah kata kunci atau pilih kategori '
                                    'lain.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (announcement) => Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pageH,
                                0,
                                AppSpacing.pageH,
                                AppSpacing.md,
                              ),
                              child: _AnnouncementCard(
                                announcement: announcement,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AnnouncementDetailScreen(
                                      announcement: announcement,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        AppSpacing.sm,
      ),
      child: TextField(
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Cari pengumuman...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.iconNavy,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _query = ''),
                ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _categoryChips(List<Announcement> items) {
    final counts = {
      for (final category in AnnouncementCategory.values)
        category: items.where((item) => item.category == category).length,
    };

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.xs,
          AppSpacing.pageH,
          0,
        ),
        children: [
          _chip('Semua', null, items.length),
          for (final category in AnnouncementCategory.values)
            _chip(category.label, category, counts[category] ?? 0),
        ],
      ),
    );
  }

  Widget _chip(String label, AnnouncementCategory? category, int count) {
    final selected = _category == category;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _category = category),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.onPrimary : AppColors.textPrimary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          side: BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}

/// Kartu satu pengumuman.
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: announcement.category.label,
                color: AppColors.info,
                background: AppColors.infoBg,
                icon: Icons.label_outline,
                dense: true,
              ),
              const Spacer(),
              Text(
                DateFormat.shortDate(announcement.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  announcement.author,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
