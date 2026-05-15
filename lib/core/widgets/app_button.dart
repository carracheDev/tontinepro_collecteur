import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum AppButtonVariant { confirmer, annuler, attention, info, outline, texte }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.confirmer,
    this.loading = false,
    this.icone,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    if (variant == AppButtonVariant.outline) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: Icon(icone ?? Icons.chevron_right),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _couleurFond(),
          foregroundColor: AppColors.blanc,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icone ?? Icons.check),
        label: Text(label),
      ),
    );
  }

  Color _couleurFond() => switch (variant) {
        AppButtonVariant.annuler => AppColors.annuler,
        AppButtonVariant.attention => AppColors.attention,
        AppButtonVariant.info => AppColors.info,
        _ => AppColors.primary,
      };
}
