import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextTheme textTheme() => GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.texte,
        displayColor: AppColors.texte,
      );

  static TextStyle amount({double size = 32, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? AppColors.primaryDark,
      );
}
