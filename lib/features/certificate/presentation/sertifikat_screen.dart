import 'package:flutter/material.dart';

import '../../../../core/async_builder.dart';
import '../../../../core/async_controller.dart';
import '../../../../core/date_format.dart';
import '../../../../core/load_state.dart';
import '../../../../core/submit_controller.dart';
import '../../../../shared/api_detail_row.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/status_badge.dart';
import '../data/datasources/sertifikat_remote_ds.dart';
import '../data/models/sertifikat_model.dart';
import '../data/repositories/sertifikat_repository.dart';

/// Daftar sertifikat dari `GET /sertifikat` + pengajuan via POST.
class SertifikatScreen extends StatefulWidget {
  const SertifikatScreen({super.key, required this.npm, this.repository});

  final String npm;
  final SertifikatRepository? repository;

  @override
  State<SertifikatScreen> createState() => _SertifikatScreenState();
}

class _SertifikatScreenState extends State<SertifikatScreen> {
  late final SertifikatRepository _repository;
  late final AsyncController<List<Sertifikat>> _controller;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        SertifikatRepositoryImpl(SertifikatRemoteDataSourceImpl());
    _controller = AsyncController<List<Sertifikat>>(
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
      builder: (_) => _SertifikatForm(
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
        title: const Text('Sertifikat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AsyncBuilder<List<Sertifikat>>(
        controller: _controller,
        isEmpty: (items) => items.isEmpty,
        loadingMessage: 'Memuat sertifikat...',
        emptyTitle: 'Belum ada sertifikat',
        emptyMessage: 'Sertifikat untuk NPM ini belum tercatat di server.',
        emptyIcon: Icons.workspace_premium_outlined,
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
              AppButton(
                label: 'TAMBAH SERTIFIKAT',
                icon: Icons.add,
                onPressed: _openForm,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SertifikatCard(item: item),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SertifikatCard extends StatelessWidget {
  const _SertifikatCard({required this.item});

  final Sertifikat item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  apiText(item.namaSertifikat),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge.neutral(apiText(item.statusVerifikasi)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ApiDetailRow(label: 'Jenis', value: apiText(item.jenisSertifikat)),
          ApiDetailRow(
            label: 'Kategori',
            value: apiText(item.kategoriSertifikat),
          ),
          ApiDetailRow(label: 'Tingkat', value: apiText(item.tingkatKegiatan)),
          ApiDetailRow(
            label: 'Penyelenggara',
            value: apiText(item.penyelenggara),
          ),
          ApiDetailRow(
            label: 'Tanggal',
            value: item.tanggalSertifikat == null
                ? '-'
                : DateFormat.shortDate(item.tanggalSertifikat!),
          ),
          ApiDetailRow(label: 'Nomor', value: apiText(item.nomorSertifikat)),
          ApiDetailRow(
            label: 'Lampiran',
            value: item.fileSertifikat.isEmpty
                ? '-'
                : item.isLink
                ? 'Tautan tersedia'
                : 'File terlampir',
          ),
        ],
      ),
    );
  }
}

/// Form POST dengan validasi seluruh input wajib.
class _SertifikatForm extends StatefulWidget {
  const _SertifikatForm({
    required this.npm,
    required this.repository,
    required this.onCreated,
  });

  final String npm;
  final SertifikatRepository repository;
  final VoidCallback onCreated;

  @override
  State<_SertifikatForm> createState() => _SertifikatFormState();
}

class _SertifikatFormState extends State<_SertifikatForm> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _jenis = TextEditingController();
  final _kategori = TextEditingController();
  final _penyelenggara = TextEditingController();
  final _tingkat = TextEditingController();
  final _tanggal = TextEditingController();
  final _nomor = TextEditingController();
  final _file = TextEditingController();
  final SubmitController _submit = SubmitController();

  @override
  void dispose() {
    for (final controller in [
      _nama,
      _jenis,
      _kategori,
      _penyelenggara,
      _tingkat,
      _tanggal,
      _nomor,
      _file,
    ]) {
      controller.dispose();
    }
    _submit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tanggal = DateTime.tryParse(_tanggal.text.trim());
    if (tanggal == null) return;

    final request = SertifikatRequest(
      npm: widget.npm,
      namaSertifikat: _nama.text,
      jenisSertifikat: _jenis.text,
      kategoriSertifikat: _kategori.text,
      penyelenggara: _penyelenggara.text,
      tingkatKegiatan: _tingkat.text,
      tanggalSertifikat: tanggal.millisecondsSinceEpoch ~/ 1000,
      nomorSertifikat: _nomor.text,
      fileSertifikat: _file.text,
    );

    final ok = await _submit.run(() async {
      await widget.repository.create(request);
    });
    if (!mounted) return;

    final state = _submit.state;
    if (ok) {
      showAppSnackBar(
        context,
        'Sertifikat berhasil dikirim ke server.',
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
                  'Tambah Sertifikat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(_nama, 'Nama sertifikat', 'Contoh: Juara 1 Lomba'),
                _field(_jenis, 'Jenis sertifikat', 'Contoh: Kejuaraan'),
                _field(_kategori, 'Kategori', 'Contoh: Non-Akademik'),
                _field(_penyelenggara, 'Penyelenggara', 'Nama instansi'),
                _field(_tingkat, 'Tingkat kegiatan', 'Contoh: Nasional'),
                _field(
                  _tanggal,
                  'Tanggal sertifikat (YYYY-MM-DD)',
                  '2026-11-20',
                  (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Tanggal wajib diisi';
                    if (DateTime.tryParse(text) == null ||
                        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
                      return 'Gunakan format YYYY-MM-DD';
                    }
                    return null;
                  },
                ),
                _field(_nomor, 'Nomor sertifikat', 'Contoh: 123/000/321'),
                _field(
                  _file,
                  'File / tautan sertifikat',
                  'URL atau keterangan file',
                ),
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

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, [
    String? Function(String?)? validator,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
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
