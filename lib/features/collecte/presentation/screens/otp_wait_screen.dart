import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/collecte_repository.dart';

// ── États progressifs du flow OTP ────────────────────────
enum _EtatOtp { envoi, attente, validation, expire }

class OtpWaitScreen extends ConsumerStatefulWidget {
  const OtpWaitScreen({super.key});

  @override
  ConsumerState<OtpWaitScreen> createState() => _OtpWaitScreenState();
}

class _OtpWaitScreenState extends ConsumerState<OtpWaitScreen>
    with SingleTickerProviderStateMixin {
  static const _dureeMaxSec = 600; // 10 minutes
  int _secondesRestantes = _dureeMaxSec;
  _EtatOtp _etat = _EtatOtp.envoi;
  Timer? _poll;
  Timer? _countdown;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _demarrer());
  }

  Future<void> _demarrer() async {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return;

    final operationId = extra['operationId']?.toString();
    if (operationId == null) return;

    // Transition envoi → attente après 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _etat = _EtatOtp.attente);

    // Countdown 10 minutes
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _secondesRestantes--;
        if (_secondesRestantes <= 0) {
          t.cancel();
          _etat = _EtatOtp.expire;
        }
      });
    });

    // Poll statut toutes les 4 secondes
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _verifierStatut(operationId, extra);
    });
  }

  Future<void> _verifierStatut(
    String operationId,
    Map<String, dynamic> extra,
  ) async {
    try {
      setState(() => _etat = _EtatOtp.validation);
      final statut = await ref
          .read(collecteRepositoryProvider)
          .statut(operationId);
      if (!mounted) return;

      if (statut.estSucces) {
        _poll?.cancel();
        _countdown?.cancel();
        context.pushReplacement(
          Routes.collecteSucces,
          extra: {'montant': statut.montant, 'clientNom': extra['clientNom']},
        );
      } else if (statut.estEchec) {
        _poll?.cancel();
        _countdown?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opération ${statut.statut}')),
        );
        context.pop();
      } else {
        // toujours en attente
        setState(() => _etat = _EtatOtp.attente);
      }
    } catch (_) {
      if (mounted) setState(() => _etat = _EtatOtp.attente);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _countdown?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _minutesRestantes {
    final min = _secondesRestantes ~/ 60;
    final sec = _secondesRestantes % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final type = extra?['type']?.toString() ?? 'cotisation';
    final montant = extra?['montant'];
    final telephone = extra?['clientTelephone']?.toString();
    final progression = _secondesRestantes / _dureeMaxSec;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('En attente client'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _poll?.cancel();
            _countdown?.cancel();
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          children: [
            // ── Illustration téléphone animée ──────────────
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _etatCouleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_etatIcone, size: 50, color: _etatCouleur),
              ),
            ),

            const SizedBox(height: 28),

            // ── Label état progressif ──────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _etatLabel,
                key: ValueKey(_etat),
                style: AppTextStyles.titre3.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // ── Description ───────────────────────────────
            Text(
              _etatDescription(type),
              style: AppTextStyles.corpsSecond,
              textAlign: TextAlign.center,
            ),

            // ── Téléphone du client (si retrait) ──────────
            if (type == 'retrait' && telephone != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.attention.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.attention.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 16,
                      color: AppColors.attention,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      telephone,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.attention,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Montant ───────────────────────────────────
            if (montant != null) ...[
              const SizedBox(height: 20),
              Text(
                Formatters.montant(montant as num),
                style: AppTextStyles.montantMoyen.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 28,
                ),
              ),
            ],

            const Spacer(),

            // ── Timer ─────────────────────────────────────
            if (_etat != _EtatOtp.expire) ...[
              Text(
                _minutesRestantes,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _secondesRestantes < 60
                      ? AppColors.annuler
                      : AppColors.texteSecond,
                ),
              ),
              const SizedBox(height: 6),
              Text('temps restant', style: AppTextStyles.caption),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progression,
                  minHeight: 6,
                  backgroundColor: AppColors.bordureNeutre,
                  color: _secondesRestantes < 60
                      ? AppColors.annuler
                      : AppColors.primary,
                ),
              ),
            ] else ...[
              // Expiré
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.timer_off_outlined,
                      color: AppColors.annuler,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Délai expiré',
                      style: AppTextStyles.titre3.copyWith(
                        color: AppColors.annuler,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Le client n\'a pas validé dans les 10 minutes.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Bouton annuler ─────────────────────────────
            TextButton(
              onPressed: () {
                _poll?.cancel();
                _countdown?.cancel();
                context.pop();
              },
              child: Text(
                'Annuler l\'opération',
                style: AppTextStyles.corps.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _etatCouleur => switch (_etat) {
        _EtatOtp.envoi => AppColors.info,
        _EtatOtp.attente => AppColors.primary,
        _EtatOtp.validation => AppColors.attention,
        _EtatOtp.expire => AppColors.annuler,
      };

  IconData get _etatIcone => switch (_etat) {
        _EtatOtp.envoi => Icons.sms_outlined,
        _EtatOtp.attente => Icons.phone_android_outlined,
        _EtatOtp.validation => Icons.sync,
        _EtatOtp.expire => Icons.timer_off_outlined,
      };

  String get _etatLabel => switch (_etat) {
        _EtatOtp.envoi => 'SMS envoyé au client ✓',
        _EtatOtp.attente => 'En attente de validation',
        _EtatOtp.validation => 'Vérification en cours...',
        _EtatOtp.expire => 'Délai expiré',
      };

  String _etatDescription(String type) => switch (_etat) {
        _EtatOtp.expire =>
          'Le client n\'a pas répondu. Réessayez ou annulez.',
        _ => type == 'retrait'
            ? 'OTP envoyé au téléphone du client. Il valide lui-même.\nJAMAIS demander l\'OTP au client.'
            : 'Le client confirme Mobile Money sur son téléphone.\nVous ne voyez jamais le code OTP.',
      };
}
