import 'package:flutter/material.dart';

import 'session.dart';
import 'theme/app_colors.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/section_title.dart';

/// Halaman Kartu Tanda Mahasiswa (KTM) — desain mengikuti tema
/// "E-Learning Blue": gradient biru, kartu putih bersudut bulat,
/// ikon biru dongker, font Poppins.
class KtmScreen extends StatelessWidget {
  const KtmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _buildCard(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SectionTitle(title: 'Data Mahasiswa', actionLabel: null),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                _infoRow(Icons.email_outlined, 'Email', AppSession.email),
                _divider(),
                _infoRow(
                  Icons.school_outlined,
                  'Program Studi',
                  AppSession.programStudi,
                ),
                _divider(),
                _infoRow(
                  Icons.account_balance_outlined,
                  'Fakultas',
                  AppSession.faculty,
                ),
                _divider(),
                _infoRow(Icons.phone_outlined, 'Phone', AppSession.phone),
                _divider(),
                _infoRow(
                  Icons.calendar_month_outlined,
                  'Tahun Akademik',
                  '${AppSession.academicYear} · Semester ${AppSession.semester}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () =>
                    showAppSnackBar(context, 'KTM disimpan ke galeri (demo)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text(
                  'SIMPAN KTM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showAppSnackBar(context, 'Membagikan KTM... (demo)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'BAGIKAN',
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(6, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.onGradient),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kartu Tanda Mahasiswa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Student Identity Card',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Kartu KTM
  // ------------------------------------------------------------------
  Widget _buildCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _cardBody(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _cardMeta(),
          ),
          _cardFooter(),
        ],
      ),
    );
  }

  Widget _cardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIVERSITAS NUSANTARA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.onGradient,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'KARTU TANDA MAHASISWA',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.onGradientSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _photo(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardRow('NIM', AppSession.nim),
              _cardRow('Nama', AppSession.fullName),
              _cardRow('Program Studi', AppSession.programStudi),
              _cardRow('Fakultas', AppSession.faculty),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardMeta() {
    return Row(
      children: [
        _metaBox('Semester', AppSession.semester),
        const SizedBox(width: 8),
        _metaBox('Tahun Akademik', AppSession.academicYear),
        const SizedBox(width: 8),
        _metaBox('Berlaku s/d', AppSession.validUntil),
      ],
    );
  }

  Widget _cardFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
      child: Row(
        children: [
          _barcode(),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'No. ${AppSession.nim}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onGradient,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kartu sah digunakan di kampus',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.onGradientSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photo() {
    const width = 78.0;
    const height = 100.0;
    final url = AppSession.photoUrl;

    const fallback = Icon(Icons.person, size: 44, color: AppColors.iconNavy);

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }

  Widget _cardRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barcode() {
    return Row(
      children: [
        for (var i = 0; i < 26; i++)
          Container(
            width: i % 4 == 0 ? 3 : 1.5,
            height: 26,
            margin: const EdgeInsets.only(right: 1.5),
            color: Colors.white.withValues(alpha: i % 3 == 0 ? 1 : 0.7),
          ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Bagian bawah: detail data + tombol aksi
  // ------------------------------------------------------------------
  Widget _divider() =>
      const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.divider);

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.iconNavy),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
