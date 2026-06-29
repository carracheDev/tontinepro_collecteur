import 'package:flutter/material.dart';

/// Palette TontineBénin Collecteur — alignée sur l'écosystème BLEU (app client).
/// Bleu = marque (boutons, accents, hero). Vert = uniquement succès/payé/vérifié.
/// Les noms de tokens restent identiques pour compatibilité avec les widgets.
abstract class AppColors {

  // ══════════════════════════════════════════════════════
  // COULEUR 1 : Bleu marque (ex-vert forêt)
  // ══════════════════════════════════════════════════════
  static const Color primary      = Color(0xFF2563EB); // bleu royal
  static const Color primaryDark  = Color(0xFF1E3A8A); // gradients hero / nuit
  static const Color primaryLight = Color(0xFFE8EEFD); // badges et fonds légers
  static const Color primaryText  = Color(0xFF1E3A8A);

  // ══════════════════════════════════════════════════════
  // COULEUR 2 : Accent clair (ex-lime) — visible sur fonds sombres
  // ══════════════════════════════════════════════════════
  static const Color lime         = Color(0xFF60A5FA); // bleu clair accent
  static const Color limeDark     = Color(0xFF3B82F6);
  static const Color limeLight    = Color(0xFFEFF4FF);

  // ══════════════════════════════════════════════════════
  // Aliases (compatibilité widgets existants)
  // ══════════════════════════════════════════════════════
  static const Color secondary      = Color(0xFF2563EB);
  static const Color secondaryDark  = Color(0xFF1E3A8A);
  static const Color secondaryLight = Color(0xFFE8EEFD);
  static const Color primaryVif     = Color(0xFF2563EB);
  static const Color heroFond       = Color(0xFF1E3A8A);
  static const Color confirmer      = Color(0xFF2563EB);

  // ══════════════════════════════════════════════════════
  // FONDS — lavande très clair dominant
  // ══════════════════════════════════════════════════════
  static const Color fond      = Color(0xFFEEF2FB);
  static const Color surface   = Color(0xFFFFFFFF);
  static const Color blanc     = Color(0xFFFFFFFF);
  static const Color fondCarte = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════════════════
  // TEXTES
  // ══════════════════════════════════════════════════════
  static const Color texte       = Color(0xFF111827);
  static const Color texteSecond = Color(0xFF6B7280);
  static const Color muted       = Color(0xFF9CA3AF);

  // ══════════════════════════════════════════════════════
  // BORDURES — neutres
  // ══════════════════════════════════════════════════════
  static const Color bordure       = Color(0xFFE9EDF6);
  static const Color bordureNeutre = Color(0xFFE5E7EB);

  // ══════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════
  static const Color annuler   = Color(0xFFDC2626);
  static const Color attention = Color(0xFFD97706);
  static const Color info      = Color(0xFF1A56DB);
  static const Color desactive = Color(0xFF9CA3AF);

  // ══════════════════════════════════════════════════════
  // ÉTATS — vert UNIQUEMENT pour succès
  // ══════════════════════════════════════════════════════
  static const Color succes        = Color(0xFF16A34A);
  static const Color succesLight   = Color(0xFFF0FDF4);
  static const Color danger        = Color(0xFFDC2626);
  static const Color dangerLight   = Color(0xFFFEF2F2);
  static const Color dangerDark    = Color(0xFF991B1B);
  static const Color avertissement = Color(0xFFD97706);
  static const Color avertissLight = Color(0xFFFFFBEB);
  static const Color infoLight     = Color(0xFFEFF6FF);

  // ══════════════════════════════════════════════════════
  // OMBRES — neutres (slate)
  // ══════════════════════════════════════════════════════
  static List<BoxShadow> get shadowNiveau1 => [
    BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.06),
        blurRadius: 4, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> get shadowNiveau2 => [
    BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.10),
        blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get shadowNiveau3 => [
    BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.15),
        blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // ══════════════════════════════════════════════════════
  // GRADIENTS — bleu
  // ══════════════════════════════════════════════════════
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );
  static const LinearGradient gradientOr = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFCD34D), Color(0xFFD97706)],
  );
  static const LinearGradient gradientSucces = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF15803D), Color(0xFF16A34A)],
  );

  // ══════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES
  // ══════════════════════════════════════════════════════
  static const Color violet      = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color orange      = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFF0E6);
  static const Color bronze      = Color(0xFFCD7F32);
  static const Color bronzeLight = Color(0xFFFEF3C7);
  static const Color bleuGroupe      = Color(0xFF1A56DB);
  static const Color bleuGroupeLight = Color(0xFFEFF6FF);
  static const Color jauneNotif      = Color(0xFFFACC15);
  static const Color jauneNotifTexte = Color(0xFF78350F);
  static const Color grisClair  = Color(0xFFF3F4F6);
  static const Color grisNeutre = Color(0xFFEEEEEE);
  static const Color grisLeger  = Color(0xFFEFF1F5);

  // ══════════════════════════════════════════════════════
  // STATUTS TONTINE
  // ══════════════════════════════════════════════════════
  static const Color tontineActive      = Color(0xFF16A34A);
  static const Color tontineActiveBg    = Color(0xFFF0FDF4);
  static const Color tontineCreation    = Color(0xFF2563EB);
  static const Color tontineCreationBg  = Color(0xFFE8EEFD);
  static const Color tontineSuspendue   = Color(0xFFD97706);
  static const Color tontineSuspendueBg = Color(0xFFFFFBEB);
  static const Color tontineTerminee    = Color(0xFF9CA3AF);
  static const Color tontineTermineeBg  = Color(0xFFF3F4F6);
}
