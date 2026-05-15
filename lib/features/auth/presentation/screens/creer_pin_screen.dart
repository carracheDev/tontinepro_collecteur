import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final List<int> _pin1 = [];
  final List<int> _pin2 = [];
  bool _etape2 = false;
  String _erreur = '';
  late AnimationController _shakeCtrl;

  List<int> get _pinActuel => _etape2 ? _pin2 : _pin1;

  void _appuyer(int chiffre) {
    if (_pinActuel.length >= 4) return;
    setState(() {
      _pinActuel.add(chiffre);
      _erreur = '';
    });
    if (_pinActuel.length == 4) _apresQuatre();
  }

  void _effacer() {
    if (_pinActuel.isEmpty) return;
    setState(() => _pinActuel.removeLast());
  }

  Future<void> _apresQuatre() async {
    if (!_etape2) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _etape2 = true);
      return;
    }
    if (_pin1.join() != _pin2.join()) {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _erreur = 'Les codes ne correspondent pas';
        _pin2.clear();
      });
      return;
    }
    final ok = await ref.read(creerPinProvider.notifier).creer(pin: _pin1.join());
    if (!mounted) return;
    if (ok) {
      ref.invalidate(sessionRoleProvider);
      final role =
          RoleCollecteur.depuisApi(await SecureStorage.lireUserRole());
      if (!mounted) return;
      context.go(routeAccueilPourRole(role));
    } else {
      final err = ref.read(creerPinProvider).erreur;
      setState(() => _erreur = err ?? 'Impossible de créer le PIN');
    }
  }

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creerPinProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Créer votre PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                _etape2 ? 'Confirmez votre PIN' : 'Choisissez un PIN à 4 chiffres',
                style: AppTextStyles.titre3,
              ),
              const SizedBox(height: 8),
              Text(
                _etape2
                    ? 'Saisissez à nouveau le même code'
                    : 'Ne le communiquez à personne',
                style: AppTextStyles.corpsSecond,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final rempli = i < _pinActuel.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rempli ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: rempli ? AppColors.primary : AppColors.bordure,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              if (_erreur.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_erreur, style: const TextStyle(color: AppColors.annuler, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              if (state.loading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                _ClavierPin(onTouche: _appuyer, onEffacer: _effacer),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClavierPin extends StatelessWidget {
  final void Function(int) onTouche;
  final VoidCallback onEffacer;

  const _ClavierPin({required this.onTouche, required this.onEffacer});

  @override
  Widget build(BuildContext context) {
    Widget touche(String label, {VoidCallback? onTap}) {
      return SizedBox(
        height: 64,
        child: Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap ?? () => onTouche(int.parse(label)),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: label.isEmpty
                  ? const Icon(Icons.backspace_outlined)
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Row(children: [
            Expanded(child: touche('1')),
            const SizedBox(width: 12),
            Expanded(child: touche('2')),
            const SizedBox(width: 12),
            Expanded(child: touche('3')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: touche('4')),
            const SizedBox(width: 12),
            Expanded(child: touche('5')),
            const SizedBox(width: 12),
            Expanded(child: touche('6')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: touche('7')),
            const SizedBox(width: 12),
            Expanded(child: touche('8')),
            const SizedBox(width: 12),
            Expanded(child: touche('9')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: SizedBox()),
            const SizedBox(width: 12),
            Expanded(child: touche('0')),
            const SizedBox(width: 12),
            Expanded(child: touche('', onTap: onEffacer)),
          ]),
        ],
      ),
    );
  }
}
