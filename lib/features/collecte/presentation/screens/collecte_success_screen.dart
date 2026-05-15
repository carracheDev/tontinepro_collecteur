import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';

class CollecteSuccessScreen extends StatefulWidget {
  const CollecteSuccessScreen({super.key});

  @override
  State<CollecteSuccessScreen> createState() => _CollecteSuccessScreenState();
}

class _CollecteSuccessScreenState extends State<CollecteSuccessScreen> {
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown <= 0) {
        _timer?.cancel();
        if (mounted) context.go(Routes.homeCollecte);
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final montant = (extra?['montant'] as num?)?.toInt() ?? 0;
    final nom = extra?['clientNom']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle,
                size: 88,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text('Collecte réussie !', style: AppTextStyles.titre1),
              if (nom.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(nom, style: AppTextStyles.corpsSecond),
              ],
              const SizedBox(height: 16),
              Text(
                Formatters.montant(montant),
                style: AppTextStyles.montantGrand,
              ),
              const Spacer(),
              Text(
                'Retour automatique dans $_countdown s',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.homeCollecte),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Terminer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
