import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  final slides = const [
    ('Collecte cashless', 'Cotisations terrain avec controle GPS et Mobile Money.', Icons.payments),
    ('OTP anti-fraude', 'Le code part au telephone du client. Le collecteur ne le voit jamais.', Icons.verified_user),
    ('Supervision', 'Suivi des agents, alertes et performances sans collecte.', Icons.map),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) => setState(() => index = value),
                  itemCount: slides.length,
                  itemBuilder: (context, i) {
                    final slide = slides[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.$3, size: 108, color: AppColors.primary),
                        const SizedBox(height: 26),
                        Text(
                          slide.$1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted, height: 1.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.all(4),
                    width: index == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == i ? AppColors.primary : AppColors.bordure,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => context.go(Routes.auth),
                child: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
