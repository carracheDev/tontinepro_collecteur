import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/services/biometrie_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _bioScanning = false;
  String? _bioStatus;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _tenterBiometrieAuto();
  }

  Future<void> _tenterBiometrieAuto() async {
    if (!await BiometrieService.estActivee()) return;
    if (!await BiometrieService.estDisponible()) return;
    await _biometrie();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _biometrie() async {
    setState(() {
      _bioScanning = true;
      _bioStatus = 'Posez votre doigt sur le capteur';
    });
    final ok = await BiometrieService.authentifier();
    if (!mounted) return;
    setState(() {
      _bioScanning = false;
      _bioStatus = ok ? 'Empreinte reconnue ✓' : 'Échec biométrie';
    });
    if (ok) {
      await BiometrieService.activer(true);
      final roleApi = await SecureStorage.lireUserRole();
      if (!mounted) return;
      final role = RoleCollecteur.depuisApi(roleApi);
      context.go(routeAccueilPourRole(role));
    }
  }

  Future<void> _connecter(String pin) async {
    final tel = ref.read(authTelephoneProvider);
    if (tel.isEmpty) {
      if (mounted) context.pop();
      return;
    }

    final ok = await ref.read(connexionProvider.notifier).connecter(
          telephone: tel,
          pin: pin,
        );

    if (!mounted) return;

    if (ok) {
      rafraichirSession(ref.invalidate);
      final roleApi = await SecureStorage.lireUserRole();
      final role = RoleCollecteur.depuisApi(roleApi) ??
          ref.read(authRoleDemoProvider);
      if (!mounted) return;
      context.go(routeAccueilPourRole(role));
    } else {
      _ctrl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
      final err = ref.read(connexionProvider).erreur ?? 'PIN incorrect';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connexionProvider);

    final defaultPin = PinTheme(
      width: 58,
      height: 62,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Code PIN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 16),
            Text('Entrez votre PIN', style: AppTextStyles.titre3),
            const SizedBox(height: 6),
            Text('Jamais communiqué à quiconque',
                style: AppTextStyles.corpsSecond),
            const SizedBox(height: 32),

            // Cases à points + clavier numérique du téléphone
            Pinput(
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
              enabled: !state.loading,
              onCompleted: _connecter,
            ),

            const SizedBox(height: 24),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.bordure)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OU',
                      style: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.w800)),
                ),
                Expanded(child: Divider(color: AppColors.bordure)),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _bioScanning ? null : _biometrie,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _bioScanning ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(
                      color:
                          _bioScanning ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.fingerprint,
                      size: 36, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Empreinte digitale',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            if (_bioStatus != null) ...[
              const SizedBox(height: 6),
              Text(_bioStatus!, style: AppTextStyles.caption),
            ],
            const SizedBox(height: 24),
            const Text(
              'PIN oublié ? Contacter l\'admin TontineBénin',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
