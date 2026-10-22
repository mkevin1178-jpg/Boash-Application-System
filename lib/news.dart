import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';

class _NewsItem {
  final String title;
  final String date;
  final String category;
  final String summary;

  const _NewsItem(this.title, this.date, this.category, this.summary);
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const List<String> _categories = ['All', 'Campus', 'Event', 'Academic'];
  String _selectedCategory = 'All';

  static const List<_NewsItem> _news = [
    _NewsItem(
      'New Library Opens Downtown',
      '7 Oct 2026',
      'Campus',
      'A brand new library facility is now available for all students.',
    ),
    _NewsItem(
      'Multimedia Exhibition 2026',
      '6 Oct 2026',
      'Event',
      'Showcase your best work at the annual multimedia exhibition.',
    ),
    _NewsItem(
      'Final Exam Schedule Released',
      '5 Oct 2026',
      'Academic',
      'Check the official schedule for the upcoming final exams.',
    ),
    _NewsItem(
      'Scholarship Opportunity',
      '4 Oct 2026',
      'Academic',
      'Apply now for the merit-based scholarship for next semester.',
    ),
  ];

  List<_NewsItem> get _filteredNews {
    if (_selectedCategory == 'All') return _news;
    return _news
        .where((n) => n.category == _selectedCategory)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredNews;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final category = _categories[i];
              final selected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _selectedCategory = category),
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceAlt,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildMainNews(context),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Text(
            'Latest News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No news in this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                for (final item in items) _buildNewsTile(context, item),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'News',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onGradient,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Latest updates from around campus',
            style: TextStyle(fontSize: 13, color: AppColors.onGradientSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNews(BuildContext context) {
    return GestureDetector(
      onTap: () => showAppSnackBar(context, 'Opening: Library Week 2026'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.onGradient,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Library Week 2026',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.onGradient,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '8 Oct 2026 · Event',
              style: TextStyle(fontSize: 12, color: AppColors.onGradientSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsTile(BuildContext context, _NewsItem item) {
    return GestureDetector(
      onTap: () => showAppSnackBar(context, 'Opening: ${item.title}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.bgGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.article_outlined,
                color: AppColors.onGradient,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.date} · ${item.category}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
