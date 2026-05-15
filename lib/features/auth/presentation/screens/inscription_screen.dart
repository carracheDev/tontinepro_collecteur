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

/// Inscription collecteur : AGENT ou INDEPENDANT (SUPERVISEUR = Admin uniquement).
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
    final role = ref.read(inscriptionRoleProvider);

    if (role == RoleCollecteur.superviseur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le rôle Superviseur est attribué uniquement par l\'administrateur.',
          ),
        ),
      );
      return;
    }

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
    final role = ref.watch(inscriptionRoleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Inscription collecteur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.attention, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Votre dossier KYC sera validé par l\'admin avant activation complète du compte terrain.',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Créer un compte', style: AppTextStyles.titre2),
            const SizedBox(height: 8),
            Text(
              'Agent salarié ou collecteur indépendant au Bénin.',
              style: AppTextStyles.corpsSecond,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Nom complet',
              controller: _nomCtrl,
              hint: 'Ex : Moussa Agbo',
              onChanged: (v) => setState(() => _nomValide = v.trim().length >= 3),
            ),
            const SizedBox(height: 16),
            AppPhoneField(
              controller: _telCtrl,
              onChanged: (v) =>
                  setState(() => _telValide = Validators.telephoneBenin(v)),
            ),
            const SizedBox(height: 20),
            Text(
              'TYPE DE COMPTE',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _RoleChoix(
              role: RoleCollecteur.agent,
              selected: role == RoleCollecteur.agent,
              onTap: () => ref.read(inscriptionRoleProvider.notifier).state =
                  RoleCollecteur.agent,
            ),
            _RoleChoix(
              role: RoleCollecteur.independant,
              selected: role == RoleCollecteur.independant,
              onTap: () => ref.read(inscriptionRoleProvider.notifier).state =
                  RoleCollecteur.independant,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fond,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bordure),
              ),
              child: Text(
                'Superviseur de zone : contactez l\'admin TontinePro — ce rôle n\'est pas auto-inscriptible.',
                style: AppTextStyles.caption,
              ),
            ),
            const SizedBox(height: 20),
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
                        style: AppTextStyles.caption.copyWith(height: 1.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'RECEVOIR LE CODE OTP',
              loading: state.loading,
              onPressed: _formValide ? _soumettre : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.auth),
                child: const Text('Déjà inscrit ? Se connecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChoix extends StatelessWidget {
  final RoleCollecteur role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChoix({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.bordure,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  role.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
