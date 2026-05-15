import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CommissionsScreen extends StatelessWidget {
  const CommissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Disponible', style: Theme.of(context).textTheme.titleMedium),
          Text('42 500 FCFA', style: AppTextStyles.amount(size: 42)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [54, 88, 64, 112, 78]
                .map(
                  (h) => Expanded(
                    child: Container(
                      height: h.toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
