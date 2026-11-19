import 'package:flutter/material.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../shared/api_detail_row.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';
import '../data/datasources/finance_remote_ds.dart';
import '../data/models/finance_model.dart';
import '../data/repositories/finance_repository.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key, required this.npm, this.repository});

  final String npm;
  final FinanceRepository? repository;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late final FinanceRepository _repository;
  late final AsyncController<List<FinancePayment>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        FinanceRepositoryImpl(FinanceRemoteDataSourceImpl());
    _controller = AsyncController<List<FinancePayment>>(
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
        title: const Text('Finance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<FinancePayment>>(
        controller: _controller,
        isEmpty: (items) => items.isEmpty,
        loadingMessage: 'Memuat data pembayaran...',
        emptyTitle: 'Belum ada data pembayaran',
        emptyMessage: 'Data keuangan untuk NPM ini belum tersedia.',
        emptyIcon: Icons.payments_outlined,
        builder: (context, items) {
          final total = items.fold<double>(0, (sum, item) => sum + item.amount);
          return RefreshIndicator(
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
                AppCard(
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total nominal tercatat',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onPrimarySoft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _amountLabel(total),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Berdasarkan ${items.length} record dari server',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onPrimarySoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => FinanceDetailScreen(item: item),
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.amountLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              StatusBadge.neutral(
                                'Jenis ${apiText(item.ntype)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            apiText(item.cketerangan),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${item.thnAkademik.isEmpty ? '-' : item.thnAkademik}'
                            ' · Semester ${apiText(item.semester)}'
                            ' · ${_dateLabel(item.dpayment, item.dpaymentRaw)}',
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
          );
        },
      ),
    );
  }
}

class FinanceDetailScreen extends StatelessWidget {
  const FinanceDetailScreen({super.key, required this.item});

  final FinancePayment item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pembayaran')),
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
                  item.amountLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ApiDetailRow(
                  label: 'Keterangan',
                  value: apiText(item.cketerangan),
                ),
                ApiDetailRow(label: 'NPM', value: apiText(item.npm)),
                ApiDetailRow(
                  label: 'Tahun akademik',
                  value: apiText(item.thnAkademik),
                ),
                ApiDetailRow(label: 'Semester', value: apiText(item.semester)),
                ApiDetailRow(
                  label: 'Tanggal bayar',
                  value: _dateLabel(item.dpayment, item.dpaymentRaw),
                ),
                ApiDetailRow(
                  label: 'Nominal API',
                  value: apiText(item.npaymentRaw),
                ),
                ApiDetailRow(
                  label: 'Jenis (ntype)',
                  value: apiText(item.ntype),
                ),
                ApiDetailRow(
                  label: 'Dihapus (bdeleted)',
                  value: apiText(item.bdeleted),
                ),
                ApiDetailRow(label: 'ID (nid)', value: apiText(item.nid)),
                ApiDetailRow(label: 'Registrasi', value: apiText(item.regId)),
                ApiDetailRow(
                  label: 'Dicatat oleh',
                  value: apiText(item.cuserEntry),
                ),
                ApiDetailRow(label: 'Waktu input', value: apiText(item.dentry)),
                ApiDetailRow(
                  label: 'Diubah oleh',
                  value: apiText(item.cuserUpdate),
                ),
                ApiDetailRow(label: 'Waktu ubah', value: apiText(item.dupdate)),
                ApiDetailRow(
                  label: 'Dihapus oleh',
                  value: apiText(item.cuserDelete),
                ),
                ApiDetailRow(
                  label: 'Waktu hapus',
                  value: apiText(item.ddelete),
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

String _amountLabel(double value) {
  final digits = value.toStringAsFixed(0).split('.').first;
  final sign = digits.startsWith('-') ? '-' : '';
  final unsigned = sign.isEmpty ? digits : digits.substring(1);
  final buffer = StringBuffer(sign);
  for (var i = 0; i < unsigned.length; i++) {
    if (i > 0 && (unsigned.length - i) % 3 == 0) buffer.write('.');
    buffer.write(unsigned[i]);
  }
  return 'Rp $buffer';
}
