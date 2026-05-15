import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';

/// Reprend une inscription interrompue (compte EN_ATTENTE sans PIN).
class ContinuerInscriptionScreen extends ConsumerStatefulWidget {
  const ContinuerInscriptionScreen({super.key});

  @override
  ConsumerState<ContinuerInscriptionScreen> createState() =>
      _ContinuerInscriptionScreenState();
}

class _ContinuerInscriptionScreenState
    extends ConsumerState<ContinuerInscriptionScreen> {
  final _telCtrl = TextEditingController();
  bool _telValide = false;

  Future<void> _renvoyerOtp() async {
    if (!_telValide) return;
    final tel = '+229${_telCtrl.text.replaceAll(' ', '')}';
    final role = ref.read(inscriptionRoleProvider);

    final ok = await ref.read(inscriptionProvider.notifier).inscrire(
          telephone: tel,
          nom: 'Collecteur',
          role: role.apiValue,
        );

    if (!mounted) return;

    if (ok) {
      final otpTest = ref.read(inscriptionProvider).otpTest;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nouveau code OTP envoyé. Vérifiez puis créez votre PIN.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      context.go(Routes.otp, extra: {
        'telephone': tel,
        'nom': 'Collecteur',
        'role': role.apiValue,
        'otpTest': otpTest,
      });
    } else {
      final err = ref.read(inscriptionProvider).erreur ?? '';
      if (err.contains('déjà actif') || err.contains('Connectez-vous')) {
        _afficherDialogueDejaActif();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  void _afficherDialogueDejaActif() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compte déjà actif'),
        content: const Text(
          'Ce numéro a déjà un PIN. Utilisez « Se connecter » sur l\'écran précédent.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(Routes.auth);
            },
            child: const Text('Connexion'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Continuer l\'inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vous avez commencé l\'inscription sans terminer l\'OTP ou le PIN. '
                      'Entrez votre numéro : nous vous renvoyons un code pour finaliser.',
                      style: AppTextStyles.caption.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppPhoneField(
              controller: _telCtrl,
              onChanged: (v) =>
                  setState(() => _telValide = Validators.telephoneBenin(v)),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'RENVOYER LE CODE OTP',
              loading: state.loading,
              onPressed: _telValide ? _renvoyerOtp : null,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.auth),
                child: const Text('J\'ai déjà un PIN → Connexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
