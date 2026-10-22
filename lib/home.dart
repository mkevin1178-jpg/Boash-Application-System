import 'package:flutter/material.dart';

import 'ktm.dart';
import 'session.dart';
import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/menu_icon_tile.dart';
import 'widgets/section_title.dart';

class _MenuData {
  final IconData icon;
  final String label;

  const _MenuData(this.icon, this.label);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedChip = 0;

  static const List<_MenuData> _menus = [
    _MenuData(Icons.badge_outlined, 'KTM'),
    _MenuData(Icons.person_outline, 'Profile'),
    _MenuData(Icons.event, 'Events'),
    _MenuData(Icons.groups_outlined, 'Staffs'),
    _MenuData(Icons.fact_check_outlined, 'Attendance'),
    _MenuData(Icons.chat_bubble_outline, 'Chatbox'),
    _MenuData(Icons.bar_chart, 'GradeSheet'),
    _MenuData(Icons.photo_library_outlined, 'Gallery'),
    _MenuData(Icons.attach_money, 'Fees Details'),
    _MenuData(Icons.description_outlined, 'Notices'),
    _MenuData(Icons.menu_book_outlined, 'Assignments'),
    _MenuData(Icons.assignment_outlined, 'Exams'),
    _MenuData(Icons.local_library_outlined, 'Library'),
  ];

  static const List<String> _chips = ['ALL COURSE', 'DESIGN', 'VIDEO'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MenuData> get _filteredMenus {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _menus;
    return _menus
        .where((m) => m.label.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final menus = _filteredMenus;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildSearchField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildBanner(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SectionTitle(
            title: 'Menu',
            onAction: () => showAppSnackBar(context, 'All menu'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: menus.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No menu matches that search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.95,
                  children: [
                    for (final menu in menus)
                      MenuIconTile(
                        icon: menu.icon,
                        label: menu.label,
                        onTap: () => _onMenuTap(context, menu),
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: const SectionTitle(
            title: 'Top search',
            actionLabel: null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              for (var i = 0; i < _chips.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_chips[i]),
                    selected: _selectedChip == i,
                    onSelected: (_) => setState(() => _selectedChip = i),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedChip == i
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceAlt,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SectionTitle(
            title: 'Featured',
            actionLabel: null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Row(
            children: const [
              Expanded(
                child: _FeaturedCard(
                  title: 'Math MasterClass',
                  category: 'Design',
                  duration: '4h 30m',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FeaturedCard(
                  title: 'Physics Lab',
                  category: 'Video',
                  duration: '2h 10m',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMenuTap(BuildContext context, _MenuData menu) {
    if (menu.label == 'KTM') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KtmScreen()),
      );
      return;
    }
    showAppSnackBar(context, '${menu.label} opened');
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${AppSession.firstName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onGradient,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You are enrolled in Multimedia',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onGradientSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () =>
                        showAppSnackBar(context, 'No new notifications'),
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppColors.onGradient,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.badge,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => showAppSnackBar(context, 'Search'),
                icon: const Icon(Icons.search, color: AppColors.onGradient),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Find here',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
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
              'NEW COURSE',
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
            'Math MasterClass',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onGradient,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Boost your skill with our latest program.',
            style: TextStyle(fontSize: 13, color: AppColors.onGradientSoft),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showAppSnackBar(context, 'Banner opened'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: const Text(
              'VIEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;

  const _FeaturedCard({
    required this.title,
    required this.category,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.bgGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onGradient,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$category · $duration',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
