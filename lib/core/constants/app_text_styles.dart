import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // ─── POPPINS — titres et textes UI ────────────────
  static TextStyle titre1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.texte,
    height: 1.2,
  );

  static TextStyle titre2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.texte,
    height: 1.3,
  );

  static TextStyle titre3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.texte,
  );

  static TextStyle sousTitre = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.texteSecond,
    height: 1.4,
  );

  static TextStyle corps = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.texte,
    height: 1.5,
  );

  static TextStyle corpsSecond = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.texteSecond,
    height: 1.5,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.texte,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.texteSecond,
    height: 1.4,
  );

  static TextStyle bouton = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.blanc,
    letterSpacing: 0.4,
  );

  // ─── NUNITO — montants et chiffres ────────────────
  static TextStyle montantGrand = GoogleFonts.nunito(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1,
  );

  static TextStyle montantMoyen = GoogleFonts.nunito(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.texte,
    height: 1.1,
  );

  static TextStyle montantPetit = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.texte,
  );

  static TextStyle chiffre = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.texte,
  );
}
