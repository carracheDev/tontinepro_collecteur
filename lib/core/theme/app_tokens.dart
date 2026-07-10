import 'package:flutter/animation.dart';

/// Design tokens TontineBénin Collecteur V2 — alignés sur l'app client.
/// Règle : plus de littéraux d'espacement/radius/durée dans les nouveaux écrans.
/// Couleurs → AppColors. Dimensions & motion → AppTokens.
abstract class AppTokens {
  // ─── Espacement (échelle unique) ────────────────────────────
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  // ─── Radius (trois niveaux, pas dix) ────────────────────────
  static const double rSm = 12; // chips, badges, tuiles d'icônes
  static const double rMd = 18; // cartes, inputs, boutons
  static const double rLg = 26; // héros, bottom sheets, modales

  // ─── Tailles de police (échelle unique) ─────────────────────
  static const double t10 = 10;
  static const double t12 = 12;
  static const double t13 = 13;
  static const double t15 = 15;
  static const double t17 = 17;
  static const double t20 = 20;
  static const double t22 = 22;
  static const double t32 = 32;

  // ─── Cibles tactiles ────────────────────────────────────────
  static const double tapMin = 48;
  static const double boutonHauteur = 52;

  // ─── Motion ─────────────────────────────────────────────────
  static const Duration dFast = Duration(milliseconds: 150);
  static const Duration dBase = Duration(milliseconds: 250);
  static const Duration dSlow = Duration(milliseconds: 400);
  static const Duration dCompteur = Duration(milliseconds: 600);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveFete = Curves.easeOutBack;
}
