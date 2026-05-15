import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../router/app_router.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int seconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) setState(() => seconds--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 96, color: AppColors.primary),
                const SizedBox(height: 18),
                Text('1 000 FCFA', style: AppTextStyles.amount(size: 52)),
                const Text('Transaction reussie'),
                const SizedBox(height: 20),
                Text('Annulation possible encore ${seconds}s'),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: seconds > 0 ? () => context.pop() : null,
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => context.go(Routes.home),
                  child: const Text('Retour accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
