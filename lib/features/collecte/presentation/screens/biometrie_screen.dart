import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../router/app_router.dart';

class BiometrieScreen extends StatefulWidget {
  const BiometrieScreen({super.key});

  @override
  State<BiometrieScreen> createState() => _BiometrieScreenState();
}

class _BiometrieScreenState extends State<BiometrieScreen> {
  bool ok = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification biometrique')),
      body: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(120),
          onTap: () => setState(() => ok = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: ok ? 190 : 160,
            height: ok ? 190 : 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primary, width: ok ? 8 : 3),
            ),
            child: Icon(
              ok ? Icons.check_circle : Icons.fingerprint,
              size: 82,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: ok ? () => context.pushReplacement(Routes.collecte) : null,
          child: const Text('Continuer vers collecte'),
        ),
      ),
    );
  }
}
