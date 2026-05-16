import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';

class CollecteSuccessScreen extends StatefulWidget {
  const CollecteSuccessScreen({super.key});

  @override
  State<CollecteSuccessScreen> createState() => _CollecteSuccessScreenState();
}

class _CollecteSuccessScreenState extends State<CollecteSuccessScreen>
    with TickerProviderStateMixin {
  static const _dureeTimer = 20;
  int _countdown = _dureeTimer;
  Timer? _timer;

  late final AnimationController _scaleCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HapticService.succes();
      _scaleCtrl.forward();
      _confettiCtrl.repeat();
      _startTimer();
    });
  }

  void _startTimer() {
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
    _scaleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final montant = (extra?['montant'] as num?)?.toInt() ?? 0;
    final nom = extra?['clientNom']?.toString() ?? '';
    final progression = _countdown / _dureeTimer;

    return Scaffold(
      body: Stack(
        children: [
          // Fond sombre gradient
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientSucces),
          ),

          // Confetti
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (context2, child2) => CustomPaint(
              painter: _ConfettiPainter(_confettiCtrl.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: const Text(
                      'Collecte validée !',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  if (nom.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Text(
                        nom,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Text(
                      Formatters.montant(montant),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text(
                          'Retour automatique dans $_countdown s',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progression,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            color: AppColors.primaryVif,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.go(Routes.homeCollecte),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Terminer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti CustomPainter ────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _particules = List.generate(40, (_) => _Particule(_rng));

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particules) {
      final t = (progress + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = t * (size.height + 40) - 20;
      final opacity =
          t < 0.1 ? t / 0.1 : t > 0.85 ? (1.0 - t) / 0.15 : 1.0;

      final paint = Paint()
        ..color = p.couleur.withValues(alpha: opacity * 0.85)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.rotation);

      switch (p.forme) {
        case 0:
          canvas.drawCircle(Offset.zero, p.taille, paint);
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.taille * 2,
              height: p.taille,
            ),
            paint,
          );
        default:
          canvas.drawPath(
            Path()
              ..moveTo(0, -p.taille)
              ..lineTo(p.taille * 0.87, p.taille * 0.5)
              ..lineTo(-p.taille * 0.87, p.taille * 0.5)
              ..close(),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particule {
  static const _couleurs = [
    Color(0xFF10B981), Color(0xFFFFD700), Color(0xFF60A5FA),
    Color(0xFFF472B6), Color(0xFFFFFFFF), Color(0xFF34D399),
    Color(0xFFFBBF24),
  ];

  final double x, offset, taille, rotation;
  final int forme;
  final Color couleur;

  _Particule(Random r)
      : x = r.nextDouble(),
        offset = r.nextDouble(),
        taille = r.nextDouble() * 5 + 3,
        rotation = r.nextDouble() * pi * 4,
        forme = r.nextInt(3),
        couleur = _couleurs[r.nextInt(_couleurs.length)];
}
