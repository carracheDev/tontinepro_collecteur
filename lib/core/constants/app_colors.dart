import 'package:flutter/material.dart';

/// Palette TontineBénin Collecteur — Style WHX
/// Règle : vert forêt #1E4228 (légèrement éclairci) + lime #C5E81A
/// Les DEUX couleurs doivent être visibles sur chaque page
abstract class AppColors {

  // ══════════════════════════════════════════════════════
  // COULEUR 1 : Vert forêt (légèrement éclairci vs avant)
  // ══════════════════════════════════════════════════════
  static const Color primary      = Color(0xFF1E4228); // éclairci vs #1B3A22
  static const Color primaryDark  = Color(0xFF122916); // pour gradients hero
  static const Color primaryLight = Color(0xFFE2F0E6); // badges et fonds légers
  static const Color primaryText  = Color(0xFF1E4228);

  // ══════════════════════════════════════════════════════
  // COULEUR 2 : Lime citron WHX — doit apparaître sur TOUTES les pages
  // Sur fond blanc : lime en background pour badges actifs, filtres, indicators
  // Sur fond sombre : lime en texte/icône (hero card)
  // ══════════════════════════════════════════════════════
  static const Color lime         = Color(0xFFC5E81A); // accent WHX principal
  static const Color limeDark     = Color(0xFF8FA812); // lime plus foncé
  static const Color limeLight    = Color(0xFFF5FAD0); // lime très pâle pour fonds

  // ══════════════════════════════════════════════════════
  // Aliases (compatibilité avec les widgets existants)
  // ══════════════════════════════════════════════════════
  static const Color secondary      = Color(0xFF1E4228);
  static const Color secondaryDark  = Color(0xFF122916);
  static const Color secondaryLight = Color(0xFFE2F0E6);
  static const Color primaryVif     = Color(0xFF1E4228);
  static const Color heroFond       = Color(0xFF122916);
  static const Color confirmer      = Color(0xFF1E4228);

  // ══════════════════════════════════════════════════════
  // FONDS — blanc dominant
  // ══════════════════════════════════════════════════════
  static const Color fond      = Color(0xFFF9FAF9);
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
  // BORDURES
  // ══════════════════════════════════════════════════════
  static const Color bordure       = Color(0xFFCBE4D3);
  static const Color bordureNeutre = Color(0xFFE5E7EB);

  // ══════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════
  static const Color annuler   = Color(0xFFDC2626);
  static const Color attention = Color(0xFFD97706);
  static const Color info      = Color(0xFF1A56DB);
  static const Color desactive = Color(0xFF9CA3AF);

  // ══════════════════════════════════════════════════════
  // ÉTATS
  // ══════════════════════════════════════════════════════
  static const Color succes        = Color(0xFF1E4228);
  static const Color succesLight   = Color(0xFFE2F0E6);
  static const Color danger        = Color(0xFFDC2626);
  static const Color dangerLight   = Color(0xFFFEF2F2);
  static const Color dangerDark    = Color(0xFF991B1B);
  static const Color avertissement = Color(0xFFD97706);
  static const Color avertissLight = Color(0xFFFFFBEB);
  static const Color infoLight     = Color(0xFFEFF6FF);

  // ══════════════════════════════════════════════════════
  // OMBRES
  // ══════════════════════════════════════════════════════
  static List<BoxShadow> get shadowNiveau1 => [
    BoxShadow(color: const Color(0xFF1E4228).withValues(alpha: 0.06),
        blurRadius: 4, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> get shadowNiveau2 => [
    BoxShadow(color: const Color(0xFF1E4228).withValues(alpha: 0.10),
        blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get shadowNiveau3 => [
    BoxShadow(color: const Color(0xFF1E4228).withValues(alpha: 0.15),
        blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // ══════════════════════════════════════════════════════
  // GRADIENTS
  // ══════════════════════════════════════════════════════
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF122916), Color(0xFF1E4228)],
  );
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1E4228), Color(0xFF2D5E3A)],
  );
  static const LinearGradient gradientOr = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFCD34D), Color(0xFFD97706)],
  );
  static const LinearGradient gradientSucces = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF1E4228), Color(0xFF2D5E3A)],
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
  static const Color tontineActive      = Color(0xFF1E4228);
  static const Color tontineActiveBg    = Color(0xFFE2F0E6);
  static const Color tontineCreation    = Color(0xFF1A56DB);
  static const Color tontineCreationBg  = Color(0xFFEFF6FF);
  static const Color tontineSuspendue   = Color(0xFFD97706);
  static const Color tontineSuspendueBg = Color(0xFFFFFBEB);
  static const Color tontineTerminee    = Color(0xFF9CA3AF);
  static const Color tontineTermineeBg  = Color(0xFFF3F4F6);
}
