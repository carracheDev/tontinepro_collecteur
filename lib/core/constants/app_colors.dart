import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand principal ──────────────────────────────
  static const Color primary = Color(0xFF0A7C4A);
  static const Color primaryVif = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF064E2B);
  static const Color primaryLight = Color(0xFFECFDF5);
  static const Color primaryText = Color(0xFF065F35);

  // ─── Surfaces ─────────────────────────────────────
  static const Color fond = Color(0xFFF8FAFC);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color fondCarte = Color(0xFFFFFFFF);
  static const Color surfaceHero = Color(0xFF0A1F12);

  // ─── Texte ────────────────────────────────────────
  static const Color texte = Color(0xFF0D1B12);
  static const Color texteSecond = Color(0xFF4B6358);
  static const Color muted = Color(0xFF9EB3A7);

  // ─── Bordures ─────────────────────────────────────
  static const Color bordure = Color(0xFFD1FAE5);
  static const Color bordureNeutre = Color(0xFFE2E8F0);

  // ─── Actions ──────────────────────────────────────
  static const Color confirmer = Color(0xFF0A7C4A);
  static const Color annuler = Color(0xFFDC2626);
  static const Color attention = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);
  static const Color desactive = Color(0xFF9CA3AF);

  // ─── États ────────────────────────────────────────
  static const Color succes = Color(0xFF0A7C4A);
  static const Color succesLight = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color avertissement = Color(0xFFD97706);
  static const Color avertissLight = Color(0xFFFFFBEB);
  static const Color infoLight = Color(0xFFE0F2FE);

  // ─── Élévation (ombres) ───────────────────────────
  static List<BoxShadow> get shadowNiveau1 => [
    BoxShadow(
      color: const Color(0xFF0D1B12).withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowNiveau2 => [
    BoxShadow(
      color: const Color(0xFF0D1B12).withValues(alpha: 0.10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowNiveau3 => [
    BoxShadow(
      color: const Color(0xFF0D1B12).withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Gradients ────────────────────────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A7C4A), Color(0xFF064E2B)],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1F12), Color(0xFF064E2B)],
  );

  static const LinearGradient gradientSucces = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1F12), Color(0xFF0A7C4A)],
  );
}
