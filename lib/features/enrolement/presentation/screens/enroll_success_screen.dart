import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../router/app_router.dart';

class EnrollSuccessScreen extends StatelessWidget {
  const EnrollSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 90, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Client enrole avec succes'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.pushReplacement(Routes.ussd),
                child: const Text('Voir codes USSD'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
