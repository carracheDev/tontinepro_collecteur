import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF16A34A);
  static const primaryDark = Color(0xFF14532D);
  static const primaryLight = Color(0xFFF0FDF4);
  static const confirmer = primary;
  static const annuler = Color(0xFFDC2626);
  static const danger = annuler;
  static const attention = Color(0xFFD97706);
  static const info = Color(0xFF1A56DB);
  static const texte = Color(0xFF1F2937);
  static const texteSecond = Color(0xFF4B5563);
  static const fond = Color(0xFFF9FAFB);
  static const bordure = Color(0xFFE5E7EB);
  static const muted = Color(0xFF6B7280);
  static const desactive = Color(0xFF9CA3AF);
  static const blanc = Color(0xFFFFFFFF);

  static const gradientPrimary = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
