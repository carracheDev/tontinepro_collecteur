import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../router/app_router.dart';

class EnrollSuccessScreen extends StatelessWidget {
  const EnrollSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final nom = extra?['nom']?.toString() ?? 'Client';
    final id = extra?['identifiantTerrain']?.toString() ?? '';
    final codeQr = extra?['codeQr']?.toString() ?? extra?['codeQR']?.toString();

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.check_circle, size: 88, color: AppColors.primary),
              const SizedBox(height: 20),
              Text('Client enrôlé !', style: AppTextStyles.titre1),
              const SizedBox(height: 8),
              Text(nom, style: AppTextStyles.titre3),
              if (id.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('ID terrain : $id', style: AppTextStyles.caption),
              ],
              const Spacer(),
              AppButton(
                label: 'Voir codes USSD',
                onPressed: () => context.push(Routes.ussdGuide),
              ),
              if (codeQr != null && codeQr.isNotEmpty) ...[
                const SizedBox(height: 10),
                AppButton(
                  label: 'QR papier',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.push(
                    Routes.qrPapier,
                    extra: {
                      'nom': nom,
                      'codeQr': codeQr,
                      'identifiantTerrain': id,
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              AppButton(
                label: 'Retour clients',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(Routes.homeClients),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
