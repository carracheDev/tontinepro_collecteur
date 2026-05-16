import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final String? labelBouton;
  final VoidCallback? onAction;
  final Color? couleurIcone;

  const EmptyStateWidget({
    super.key,
    required this.icone,
    required this.titre,
    required this.sousTitre,
    this.labelBouton,
    this.onAction,
    this.couleurIcone,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = couleurIcone ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône avec fond en dégradé doux
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.12),
                    iconColor.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(icone, size: 44, color: iconColor),
            ),
            const SizedBox(height: 22),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: AppTextStyles.titre3.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              sousTitre,
              textAlign: TextAlign.center,
              style: AppTextStyles.corpsSecond.copyWith(height: 1.6),
            ),
            if (labelBouton != null && onAction != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    labelBouton!,
                    style: AppTextStyles.bouton,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
