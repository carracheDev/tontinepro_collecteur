import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';

class CreerPinScreen extends ConsumerStatefulWidget {
  final String telephone;
  const CreerPinScreen({super.key, required this.telephone});

  @override
  ConsumerState<CreerPinScreen> createState() => _CreerPinScreenState();
}

class _CreerPinScreenState extends ConsumerState<CreerPinScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _pin1 = '';
  bool _etape2 = false;
  String _erreur = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onComplete(String value) async {
    if (!_etape2) {
      setState(() {
        _pin1 = value;
        _etape2 = true;
        _erreur = '';
      });
      _ctrl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
      return;
    }
    if (value != _pin1) {
      _shakeCtrl.forward(from: 0);
      setState(() => _erreur = 'Les codes ne correspondent pas');
      _ctrl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
      return;
    }
    final ok = await ref.read(creerPinProvider.notifier).creer(pin: _pin1);
    if (!mounted) return;
    if (ok) {
      rafraichirSession(ref.invalidate);
      final role = RoleCollecteur.depuisApi(await SecureStorage.lireUserRole());
      if (!mounted) return;
      context.go(routeAccueilPourRole(role));
    } else {
      final err = ref.read(creerPinProvider).erreur;
      _ctrl.clear();
      setState(() => _erreur = err ?? 'Impossible de créer le PIN');
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creerPinProvider);

    final defaultPin = PinTheme(
      width: 60,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.texte,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordure, width: 1.5),
      ),
    );
    final focusedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );
    final submittedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.lock_rounded,
                    color: AppColors.primary, size: 38),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(_etape2),
                  children: [
                    Text(
                      _etape2 ? 'Confirmez votre PIN' : 'Créez votre code PIN',
                      style: AppTextStyles.titre3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _etape2
                          ? 'Saisissez à nouveau votre code à 4 chiffres'
                          : 'Ce code sécurise votre compte collecteur',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.corpsSecond,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Cases à points + clavier numérique du téléphone
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                      _shakeCtrl.isAnimating
                          ? 8 * (0.5 - _shakeAnim.value).abs() * 2
                          : 0,
                      0),
                  child: child,
                ),
                child: Pinput(
                  controller: _ctrl,
                  focusNode: _focus,
                  length: 4,
                  autofocus: true,
                  obscureText: true,
                  obscuringCharacter: '●',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  defaultPinTheme: defaultPin,
                  focusedPinTheme: focusedPin,
                  submittedPinTheme: submittedPin,
                  separatorBuilder: (_) => const SizedBox(width: 14),
                  onChanged: (_) {
                    if (_erreur.isNotEmpty) setState(() => _erreur = '');
                  },
                  onCompleted: _onComplete,
                ),
              ),

              if (_erreur.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(_erreur,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger)),
              ],

              const SizedBox(height: 24),
              if (state.loading)
                const CircularProgressIndicator(color: AppColors.primary),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text('Ne partagez jamais votre code PIN.',
                    style: AppTextStyles.corpsSecond.copyWith(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
