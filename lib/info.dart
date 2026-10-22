import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';

class _InfoItem {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem(this.icon, this.title, this.description);
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const List<_InfoItem> _items = [
    _InfoItem(
      Icons.school_outlined,
      'Academic Info',
      'Academic calendar, curriculum, and graduation requirements.',
    ),
    _InfoItem(
      Icons.schedule_outlined,
      'Class Schedule',
      'Weekly class timetable for the current semester.',
    ),
    _InfoItem(
      Icons.assignment_turned_in_outlined,
      'Exam Schedule',
      'Mid-term and final exam dates and locations.',
    ),
    _InfoItem(
      Icons.phone_outlined,
      'Campus Contact',
      'Phone, email, and address of campus departments.',
    ),
    _InfoItem(
      Icons.access_time_outlined,
      'Service Hours',
      'Opening hours for academic and administrative services.',
    ),
    _InfoItem(
      Icons.help_outline,
      'FAQ',
      'Frequently asked questions from students.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            children: [
              for (final item in _items) _buildCard(context, item),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () => showAppSnackBar(context, 'Contacting campus...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CONTACT CAMPUS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
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
            'Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onGradient,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Everything you need to know about campus',
            style: TextStyle(fontSize: 13, color: AppColors.onGradientSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _InfoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 22, color: AppColors.iconNavy),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            children: [
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
