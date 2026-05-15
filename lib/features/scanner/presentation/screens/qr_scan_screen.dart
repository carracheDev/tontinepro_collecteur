import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/scanner_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _traite = false;
  late AnimationController _cadreAnim;
  late Animation<double> _cadrePulse;

  @override
  void initState() {
    super.initState();
    _cadreAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _cadrePulse = Tween<double>(begin: 0.85, end: 1.0).animate(_cadreAnim);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _cadreAnim.dispose();
    super.dispose();
  }

  String? _extraireClientId(String raw) {
    final t = raw.trim();
    final uuid = RegExp(
      r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
      caseSensitive: false,
    );
    final m = uuid.firstMatch(t);
    if (m != null) return m.group(0);
    if (t.contains('/client/')) {
      return t.split('/client/').last.split('/').first;
    }
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_traite) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    setState(() => _traite = true);
    await _ctrl.stop();

    final clientId = _extraireClientId(raw);
    if (clientId != null && mounted) {
      context.pushReplacement(Routes.clientDetail(clientId));
      return;
    }

    try {
      await ref.read(scannerRepositoryProvider).scannerCode(raw);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR collecteur détecté — ouvrez la fiche client'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extraireMessageErreur(e))),
        );
        setState(() => _traite = false);
        await _ctrl.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
                const Spacer(),
                ScaleTransition(
                  scale: _cadrePulse,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cadrez le QR client',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
