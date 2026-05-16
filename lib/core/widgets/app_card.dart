import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AppCardNiveau { un, deux, trois }

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? couleur;
  final double borderRadius;
  final bool avecBordure;
  final AppCardNiveau niveau;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.couleur,
    this.borderRadius = 18,
    this.avecBordure = true,
    this.niveau = AppCardNiveau.un,
  });

  List<BoxShadow> get _ombre => switch (niveau) {
        AppCardNiveau.un => AppColors.shadowNiveau1,
        AppCardNiveau.deux => AppColors.shadowNiveau2,
        AppCardNiveau.trois => AppColors.shadowNiveau3,
      };

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleur ?? AppColors.blanc,
        borderRadius: BorderRadius.circular(borderRadius),
        border: avecBordure
            ? Border.all(color: AppColors.bordure.withValues(alpha: 0.7))
            : null,
        boxShadow: _ombre,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: card,
      ),
    );
  }
}

/// Carte hero sombre — solde, KPI principal
class AppCarteHero extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCarteHero({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientHero,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.shadowNiveau3,
      ),
      child: child,
    );
  }
}

/// Carte solde — gradient vert (cartes secondaires)
class AppCarteSolde extends StatelessWidget {
  final String titre;
  final String montant;
  final String? sousTitre;
  final List<Widget>? actions;

  const AppCarteSolde({
    super.key,
    required this.titre,
    required this.montant,
    this.sousTitre,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowNiveau2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            montant,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
              height: 1,
            ),
          ),
          if (sousTitre != null) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
          if (actions != null) ...[
            const SizedBox(height: 16),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }
}

/// Badge statut coloré
class AppBadgeStatut extends StatelessWidget {
  final String label;
  final Color couleur;
  final Color? couleurTexte;

  const AppBadgeStatut({
    super.key,
    required this.label,
    required this.couleur,
    this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: couleurTexte ?? couleur,
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
