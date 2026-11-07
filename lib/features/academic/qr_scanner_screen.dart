import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/demo_repository.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/error_state.dart';
import 'qr_scan_result_sheet.dart';

const bool kAllowManualQrEntry = true;

typedef QrScannerBuilder = Widget Function(
  BuildContext context,
  ValueChanged<BarcodeCapture> onDetect,
);

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    required this.controller,
    required this.repository,
    this.scannerBuilder,
  });

  final AppController controller;
  final DemoRepository repository;
  final QrScannerBuilder? scannerBuilder;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _scanner;
  bool _handled = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    await _process(raw);
  }

  Future<void> _process(String? raw) async {
    if (_handled) return;
    _handled = true;
    if (widget.scannerBuilder == null) {
      try {
        await _scanner.stop();
      } catch (_) {
        // Kamera bisa belum siap bila input manual digunakan lebih dulu.
      }
    }
    setState(() => _submitting = true);
    try {
      final npm = widget.controller.session?.npm ?? '';
      final result = await widget.repository.submitQrScan(raw, npm: npm);
      if (!mounted) return;
      setState(() => _submitting = false);
      await showQrScanResultSheet(context, result);
    } catch (error) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Scan QR gagal diproses. Silakan coba lagi.',
          variant: AppSnackBarVariant.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
        _handled = false;
        if (widget.scannerBuilder == null) {
          try {
            await _scanner.start();
          } catch (_) {
            // errorBuilder menampilkan kegagalan kamera pada preview.
          }
        }
      }
    }
  }

  Future<void> _enterCode() async {
    if (_handled) return;
    _handled = true;
    if (widget.scannerBuilder == null) {
      try {
        await _scanner.stop();
      } catch (_) {
        // Kamera mungkin belum siap saat masukan manual dipilih.
      }
    }
    if (!mounted) return;
    final text = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masukkan kode manual'),
        content: TextField(
          controller: text,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Kode QR presensi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, text.text),
            child: const Text('Periksa'),
          ),
        ],
      ),
    );
    text.dispose();
    if (!mounted) return;
    _handled = false;
    if (raw != null) {
      await _process(raw);
    } else if (widget.scannerBuilder == null) {
      try {
        await _scanner.start();
      } catch (_) {
        // errorBuilder menampilkan kegagalan kamera pada preview.
      }
    }
  }

  Widget _cameraError(BuildContext context, MobileScannerException error) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ErrorState(
      title: denied ? 'Izin kamera diperlukan' : 'Kamera tidak tersedia',
      message: denied
          ? 'Izin kamera ditolak. Aktifkan kamera di Pengaturan perangkat.'
          : 'Pemindai kamera tidak dapat dijalankan pada perangkat ini.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanner =
        widget.scannerBuilder?.call(context, _onDetect) ??
        MobileScanner(
          controller: _scanner,
          onDetect: _onDetect,
          errorBuilder: _cameraError,
        );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan QR Presensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: scanner,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_submitting)
            const Center(child: CircularProgressIndicator())
          else if (kAllowManualQrEntry)
            AppButton(
              label: 'Masukkan kode manual',
              icon: Icons.keyboard_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: _enterCode,
            ),
        ],
      ),
    );
  }
}
