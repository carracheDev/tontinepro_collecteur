import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF14532D);
  static const Color primaryLight = Color(0xFFF0FDF4);
  static const Color primaryText = Color(0xFF166534);

  static const Color confirmer = Color(0xFF16A34A);
  static const Color annuler = Color(0xFFDC2626);
  static const Color attention = Color(0xFFD97706);
  static const Color info = Color(0xFF1A56DB);
  static const Color desactive = Color(0xFF9CA3AF);

  static const Color succes = Color(0xFF16A34A);
  static const Color succesLight = Color(0xFFF0FDF4);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  static const Color texte = Color(0xFF1F2937);
  static const Color texteSecond = Color(0xFF6B7280);
  static const Color muted = Color(0xFF6B7280);
  static const Color fond = Color(0xFFF9FAFB);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color bordure = Color(0xFFE5E7EB);
  static const Color fondCarte = Color(0xFFFFFFFF);

  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), Color(0xFF14532D)],
  );
}
