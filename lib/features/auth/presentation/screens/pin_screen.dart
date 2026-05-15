import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final List<int> _pin = [];
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
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _appuyer(String touche) {
    final state = ref.read(connexionProvider);
    if (state.loading) return;

    if (touche == 'del') {
      if (_pin.isNotEmpty) setState(() => _pin.removeLast());
      return;
    }
    if (_pin.length >= 4) return;
    setState(() => _pin.add(int.parse(touche)));
    if (_pin.length == 4) _connecter();
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

  Future<void> _connecter() async {
    final tel = ref.read(authTelephoneProvider);
    if (tel.isEmpty) {
      if (mounted) context.pop();
      return;
    }

    final ok = await ref.read(connexionProvider.notifier).connecter(
          telephone: tel,
          pin: _pin.join(),
        );

    if (!mounted) return;

    if (ok) {
      if (!mounted) return;
      final roleApi = await SecureStorage.lireUserRole();
      final role = RoleCollecteur.depuisApi(roleApi) ??
          ref.read(authRoleDemoProvider);
      ref.invalidate(sessionRoleProvider);

      if (!mounted) return;
      context.go(routeAccueilPourRole(role));
    } else {
      setState(() => _pin.clear());
      final err = ref.read(connexionProvider).erreur ?? 'PIN incorrect';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connexionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Entrez votre PIN', style: AppTextStyles.titre3),
            const SizedBox(height: 4),
            const Text(
              'Jamais communiqué à quiconque',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final rempli = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
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
            const SizedBox(height: 28),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              _ClavierPin(onTouche: _appuyer, onBio: _biometrie),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.bordure)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OU', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
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
                      color: _bioScanning ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.fingerprint, size: 36, color: AppColors.primary),
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
              Text(
                _bioStatus!,
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'PIN oublié ? Contacter l\'admin TontinePro',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ClavierPin extends StatelessWidget {
  final void Function(String) onTouche;
  final VoidCallback onBio;

  const _ClavierPin({required this.onTouche, required this.onBio});

  @override
  Widget build(BuildContext context) {
    Widget touche(String label, {Widget? child, VoidCallback? onTap}) {
      return SizedBox(
        height: 72,
        child: Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap ?? () => onTouche(label),
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: child ??
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.texte,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Row(children: [
            Expanded(child: touche('1')),
            const SizedBox(width: 16),
            Expanded(child: touche('2')),
            const SizedBox(width: 16),
            Expanded(child: touche('3')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: touche('4')),
            const SizedBox(width: 16),
            Expanded(child: touche('5')),
            const SizedBox(width: 16),
            Expanded(child: touche('6')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: touche('7')),
            const SizedBox(width: 16),
            Expanded(child: touche('8')),
            const SizedBox(width: 16),
            Expanded(child: touche('9')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: touche(
                '',
                onTap: onBio,
                child: const Icon(Icons.fingerprint, color: AppColors.primary, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: touche('0')),
            const SizedBox(width: 16),
            Expanded(
              child: touche(
                '',
                onTap: () => onTouche('del'),
                child: const Icon(Icons.backspace_outlined, size: 24),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
