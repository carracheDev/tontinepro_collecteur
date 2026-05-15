import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/client_models.dart';

class ClientCard extends StatelessWidget {
  final ClientResume client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  Color get _couleurAvatar {
    final couleurs = [
      AppColors.info,
      AppColors.attention,
      AppColors.primary,
      const Color(0xFF7C3AED),
    ];
    return couleurs[client.nom.hashCode.abs() % couleurs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _couleurAvatar.withValues(alpha: 0.15),
                child: Text(
                  Formatters.initiales(client.nom),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: _couleurAvatar,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.nom, style: AppTextStyles.titre3),
                    Text(
                      Formatters.telephone(client.telephone),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.montant(client.solde),
                      style: AppTextStyles.montantPetit,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (client.dejaVisite)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.succesLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Visité',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'À visiter',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.annuler,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Score ${client.score}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
