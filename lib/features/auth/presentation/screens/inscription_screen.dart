import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/utils/validators.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';

class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});
  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen>
    with TickerProviderStateMixin {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  bool _nomValide = false;
  bool _telValide = false;
  bool _cguAcceptees = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  bool get _formValide => _nomValide && _telValide && _cguAcceptees;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _fadeCtrl.dispose();
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

    if (!mounted) return;
    if (ok) {
      final otpTest = ref.read(inscriptionProvider).otpTest;
      context.go(Routes.otp, extra: {
        'telephone': tel,
        'nom': nom,
        'role': role.apiValue,
        'otpTest': otpTest,
      });
    } else {
      final err = ref.read(inscriptionProvider).erreur ?? '';
      if (err.contains('déjà actif') || err.contains('Connectez-vous')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'Connexion',
            textColor: Colors.white,
            onPressed: () => context.go(Routes.auth),
          ),
        ));
      } else if (err.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primaryDark, AppColors.secondary],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Cercles décoratifs
          Positioned(top: -60, right: -60,
            child: _Cercle(size: 220, opacity: 0.08)),
          Positioned(bottom: 200, left: -40,
            child: _Cercle(size: 160, opacity: 0.06)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rejoignez TontineBénin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Formulaire
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info KYC
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.verified_user_outlined,
                                    color: AppColors.secondary, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Soumettez votre CNI après inscription. L\'admin validera votre compte.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: AppColors.primaryDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nom complet
                          _Label('Nom complet'),
                          const SizedBox(height: 8),
                          _ChampTexte(
                            controller: _nomCtrl,
                            hint: 'Ex : Moussa Agbo',
                            icone: Icons.person_outline_rounded,
                            valide: _nomValide,
                            onChanged: (v) => setState(
                                () => _nomValide = v.trim().length >= 3),
                          ),
                          const SizedBox(height: 20),

                          // Téléphone
                          _Label('Numéro de téléphone'),
                          const SizedBox(height: 8),
                          _ChampTelephone(
                            controller: _telCtrl,
                            valide: _telValide,
                            onChanged: (v) => setState(
                                () => _telValide = Validators.telephoneBenin(v)),
                          ),
                          const SizedBox(height: 24),

                          // CGU
                          GestureDetector(
                            onTap: () => setState(() => _cguAcceptees = !_cguAcceptees),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _cguAcceptees
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _cguAcceptees
                                          ? AppColors.secondary
                                          : const Color(0xFFD1D5DB),
                                      width: 2,
                                    ),
                                  ),
                                  child: _cguAcceptees
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'J\'accepte les conditions d\'utilisation TontineBénin',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Bouton
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _formValide && !state.loading ? _soumettre : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                disabledBackgroundColor:
                                    AppColors.secondary.withValues(alpha: 0.4),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: state.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Recevoir le code OTP',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: GestureDetector(
                              onTap: () => context.go(Routes.auth),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                  children: [
                                    const TextSpan(text: 'Déjà inscrit ? '),
                                    TextSpan(
                                      text: 'Se connecter',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ───────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
    ),
  );
}

class _ChampTexte extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool valide;
  final ValueChanged<String> onChanged;

  const _ChampTexte({
    required this.controller,
    required this.hint,
    required this.icone,
    required this.valide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: valide ? AppColors.secondary : const Color(0xFFE5E7EB),
          width: valide ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(icone,
              color: valide ? AppColors.secondary : Colors.grey[400], size: 20),
          suffixIcon: valide
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

class _ChampTelephone extends StatelessWidget {
  final TextEditingController controller;
  final bool valide;
  final ValueChanged<String> onChanged;

  const _ChampTelephone({
    required this.controller,
    required this.valide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: valide ? AppColors.secondary : const Color(0xFFE5E7EB),
          width: valide ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: valide ? AppColors.secondaryLight : const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Text('🇧🇯', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+229',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: valide ? AppColors.secondary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '01 XX XX XX XX',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                suffixIcon: valide
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.secondary)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cercle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Cercle({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: opacity),
        width: 1.5,
      ),
    ),
  );
}
