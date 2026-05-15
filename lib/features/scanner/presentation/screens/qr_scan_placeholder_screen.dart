import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Placeholder Phase 2 — scanner QR réel (mobile_scanner).
class QrScanPlaceholderScreen extends StatelessWidget {
  const QrScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scanner QR'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scanner — Phase 2',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
