import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';

/// Inscription collecteur : AGENT uniquement.
class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  bool _nomValide = false;
  bool _telValide = false;
  bool _cguAcceptees = false;

  bool get _formValide => _nomValide && _telValide && _cguAcceptees;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formValide) return;
    final tel = '+229${_telCtrl.text.replaceAll(' ', '')}';
    final nom = _nomCtrl.text.trim();
    const role = RoleCollecteur.agent;

    final ok = await ref.read(inscriptionProvider.notifier).inscrire(
          telephone: tel,
          nom: nom,
          role: role.apiValue,
        );

    if (ok && mounted) {
      final otpTest = ref.read(inscriptionProvider).otpTest;
      context.go(Routes.otp, extra: {
        'telephone': tel,
        'nom': nom,
        'role': role.apiValue,
        'otpTest': otpTest,
      });
    } else if (mounted) {
      final err = ref.read(inscriptionProvider).erreur ?? '';
      if (err.contains('déjà actif') || err.contains('Connectez-vous')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            action: SnackBarAction(
              label: 'Connexion',
              onPressed: () => context.go(Routes.auth),
            ),
          ),
        );
      } else if (err.contains('déjà inscrit')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Inscription déjà commencée ? Utilisez « Continuer l\'inscription ».',
            ),
            action: SnackBarAction(
              label: 'Continuer',
              onPressed: () => context.push(Routes.continuerInscription),
            ),
          ),
        );
      } else if (err.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.texte),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Créer un compte agent',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.texte,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau info KYC
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Après inscription, soumettez votre KYC (CNI/passeport). L\'admin validera votre compte avant activation.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Nom complet', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AppTextField(
              label: '',
              controller: _nomCtrl,
              hint: 'Ex : Moussa Agbo',
              onChanged: (v) => setState(() => _nomValide = v.trim().length >= 3),
            ),
            const SizedBox(height: 20),
            Text('Numéro de téléphone', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AppPhoneField(
              controller: _telCtrl,
              onChanged: (v) => setState(() => _telValide = Validators.telephoneBenin(v)),
            ),
            const SizedBox(height: 24),
            // CGU
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _cguAcceptees,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _cguAcceptees = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _cguAcceptees = !_cguAcceptees),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'J\'accepte les conditions d\'utilisation et la politique de confidentialité TontineBénin.',
                        style: AppTextStyles.caption.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'RECEVOIR LE CODE OTP',
              loading: state.loading,
              onPressed: _formValide ? _soumettre : null,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.auth),
                child: const Text(
                  'Déjà inscrit ? Se connecter',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

