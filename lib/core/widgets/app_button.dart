import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum AppButtonVariant { confirmer, annuler, attention, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final IconData? icone;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.confirmer,
    this.loading = false,
    this.fullWidth = true,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final desactive = onPressed == null || loading;

    if (variant == AppButtonVariant.outline) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: 56,
        child: OutlinedButton(
          onPressed: desactive ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _contenu(AppColors.primary),
        ),
      );
    }

    final bg = switch (variant) {
      AppButtonVariant.annuler => AppColors.annuler,
      AppButtonVariant.attention => AppColors.attention,
      _ => AppColors.primary,
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: desactive ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: desactive ? AppColors.desactive : bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _contenu(Colors.white),
      ),
    );
  }

  Widget _contenu(Color couleurTexte) {
    if (loading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(couleurTexte),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icone != null) ...[
          Icon(icone, size: 20, color: couleurTexte),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: couleurTexte,
          ),
        ),
      ],
    );
  }
}
