import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../router/app_router.dart';

class OtpWaitScreen extends StatelessWidget {
  const OtpWaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP client')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sms_outlined, size: 86, color: AppColors.info),
            const SizedBox(height: 18),
            Text(
              'OTP envoye au CLIENT',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Le collecteur ne voit jamais le code. Seul le statut d envoi est affiche.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pushReplacement(Routes.success),
              child: const Text('Client confirme'),
            ),
          ],
        ),
      ),
    );
  }
}
