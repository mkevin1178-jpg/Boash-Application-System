import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../core/load_state.dart';
import '../../../../core/submit_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/status_badge.dart';
import '../data/models/kehadiran_model.dart';
import '../data/repositories/kehadiran_repository.dart';
import '../data/datasources/kehadiran_remote_ds.dart';

/// Riwayat kehadiran dari `GET /kehadiran` dan pengiriman data via POST.
class KehadiranScreen extends StatefulWidget {
  const KehadiranScreen({super.key, required this.npm, this.repository});

  final String npm;
  final KehadiranRepository? repository;

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  late final KehadiranRepository _repository;
  late final AsyncController<List<Kehadiran>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        KehadiranRepositoryImpl(KehadiranRemoteDataSourceImpl());
    _controller = AsyncController<List<Kehadiran>>(
      () => _repository.fetchByNpm(widget.npm),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForm() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _KehadiranForm(
        npm: widget.npm,
        repository: _repository,
        onCreated: () => _controller.load(force: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kehadiran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Kehadiran>>(
        controller: _controller,
        isEmpty: (items) => items.isEmpty,
        loadingMessage: 'Memuat kehadiran...',
        emptyTitle: 'Belum ada data kehadiran',
        emptyMessage: 'Riwayat kehadiran untuk NPM ini belum tersedia.',
        emptyIcon: Icons.fact_check_outlined,
        builder: (context, items) {
          final sorted = items.toList()
            ..sort((a, b) => (b.tanggalRaw).compareTo(a.tanggalRaw));
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
                AppButton(
                  label: 'CATAT KEHADIRAN',
                  icon: Icons.add_task,
                  onPressed: _openForm,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Riwayat kehadiran (${sorted.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final item in sorted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _KehadiranCard(item: item),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KehadiranCard extends StatelessWidget {
  const _KehadiranCard({required this.item});

  final Kehadiran item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.kdMatkul} · Kelas ${item.kdKelas}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge.neutral('Keterangan: ${_orDash(item.keterangan)}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_dateLabel(item)} · ${_orDash(item.jamLogin)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sesi ${_orDash(item.session)} · ${_orDash(item.thnAkademik)}'
            ' · Semester ${_orDash(item.semester)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Form POST — hanya mengirim field yang sudah terverifikasi dari API.
class _KehadiranForm extends StatefulWidget {
  const _KehadiranForm({
    required this.npm,
    required this.repository,
    required this.onCreated,
  });

  final String npm;
  final KehadiranRepository repository;
  final VoidCallback onCreated;

  @override
  State<_KehadiranForm> createState() => _KehadiranFormState();
}

class _KehadiranFormState extends State<_KehadiranForm> {
  final _formKey = GlobalKey<FormState>();
  final _kdMatkul = TextEditingController();
  final _kdKelas = TextEditingController();
  final _tanggal = TextEditingController();
  final _jam = TextEditingController();
  final _session = TextEditingController();
  final _keterangan = TextEditingController(text: '1');
  final SubmitController _submit = SubmitController();

  @override
  void dispose() {
    _kdMatkul.dispose();
    _kdKelas.dispose();
    _tanggal.dispose();
    _jam.dispose();
    _session.dispose();
    _keterangan.dispose();
    _submit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final request = KehadiranRequest(
      npm: widget.npm,
      kdMatkul: _kdMatkul.text,
      kdKelas: _kdKelas.text,
      tanggal: _tanggal.text,
      jamLogin: _jam.text,
      session: _session.text,
      keterangan: _keterangan.text,
    );

    final ok = await _submit.run(() async {
      await widget.repository.create(request);
    });
    if (!mounted) return;

    final state = _submit.state;
    if (ok) {
      showAppSnackBar(
        context,
        'Kehadiran berhasil dikirim ke server.',
        variant: AppSnackBarVariant.success,
      );
      widget.onCreated();
      Navigator.of(context).pop();
    } else if (state is SubmitFailure) {
      showAppSnackBar(
        context,
        state.message,
        variant: AppSnackBarVariant.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Catat Kehadiran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  controller: _kdMatkul,
                  label: 'Kode mata kuliah',
                  hint: 'Contoh: GC327',
                ),
                _field(
                  controller: _kdKelas,
                  label: 'Kode kelas',
                  hint: 'Contoh: A',
                ),
                _field(
                  controller: _tanggal,
                  label: 'Tanggal (YYYY-MM-DD)',
                  hint: '2026-11-20',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  ],
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Tanggal wajib diisi';
                    if (DateTime.tryParse(text) == null ||
                        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
                      return 'Gunakan format YYYY-MM-DD';
                    }
                    return null;
                  },
                ),
                _field(
                  controller: _jam,
                  label: 'Jam login (HH:MM:SS)',
                  hint: '08:00:00',
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(text)) {
                      return 'Gunakan format HH:MM:SS';
                    }
                    return null;
                  },
                ),
                _field(
                  controller: _session,
                  label: 'Sesi',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _field(controller: _keterangan, label: 'Keterangan', hint: '1'),
                const SizedBox(height: AppSpacing.md),
                ListenableBuilder(
                  listenable: _submit,
                  builder: (context, _) => AppButton(
                    label: 'KIRIM KE SERVER',
                    icon: Icons.send,
                    isLoading: _submit.isSubmitting,
                    onPressed: _submit.isSubmitting ? null : _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator:
            validator ??
            (value) =>
                (value?.trim().isEmpty ?? true) ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

String _orDash(String value) => value.isEmpty ? '-' : value;

String _dateLabel(Kehadiran item) => item.tanggal == null
    ? _orDash(item.tanggalRaw)
    : DateFormat.shortDate(item.tanggal!);
