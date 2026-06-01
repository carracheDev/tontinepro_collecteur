import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../router/app_router.dart';
import '../../data/models/client_models.dart';

class ScorePadmeScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;

  const ScorePadmeScreen({super.key, required this.fiche});

  @override
  ConsumerState<ScorePadmeScreen> createState() => _ScorePadmeScreenState();
}

class _ScorePadmeScreenState extends ConsumerState<ScorePadmeScreen> {
  bool _loadingPadme = false;

  Color _couleurScore(int score) {
    if (score >= 70) return const Color(0xFF2563EB);
    if (score >= 60) return AppColors.primary;
    return AppColors.annuler;
  }

  Color _badgeMetalColor(int score) {
    if (score >= 90) return const Color(0xFF7C3AED);
    if (score >= 80) return const Color(0xFFB45309);
    if (score >= 70) return const Color(0xFF64748B);
    return const Color(0xFF92400E);
  }

  String _badgeMetalLabel(int score) {
    if (score >= 90) return 'Diamant';
    if (score >= 80) return 'Or';
    if (score >= 70) return 'Argent';
    return 'Bronze';
  }

  Future<void> _initierPadme() async {
    setState(() => _loadingPadme = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final score = widget.fiche.score;
      final int montant = score >= 90
          ? 100000
          : score >= 80
              ? 50000
              : 25000;
      await DioClient.instance.post(
        ApiEndpoints.padmeDemanderAssiste(widget.fiche.id),
        data: {
          'objetCredit': 'Activité génératrice de revenus',
          'descriptionActivite': 'Commerce ou activité génératrice de revenus',
          'montantSouhaite': montant,
        },
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Dossier PADME soumis. En attente de validation admin.'),
        backgroundColor: AppColors.secondary,
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(extraireMessageErreur(e))));
    } finally {
      if (mounted) setState(() => _loadingPadme = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fiche = widget.fiche;
    final score = fiche.score;

    final regularite = (score * 0.4).round();
    final anciennete = min((score * 0.2).round(), 20);
    final remboursement = (score * 0.3).round();
    final objectifAtteint = (score * 0.1).round();

    final int? plafond = score >= 90
        ? 100000
        : score >= 80
            ? 50000
            : score >= 70
                ? 25000
                : score >= 60
                    ? 10000
                    : null;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Score & PADME'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        elevation: 0.5,
        shadowColor: const Color(0x14000000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Anneau score ──────────────────────────────
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: _couleurScore(score),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('/100', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Badges éligibilité ────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (score >= 60)
                  _Badge(
                    text: 'Micro-crédit ✓',
                    bg: AppColors.secondaryLight,
                    fg: AppColors.secondary,
                  ),
                if (score >= 70)
                  const _Badge(
                    text: 'PADME ✓',
                    bg: Color(0xFFF5F3FF),
                    fg: Color(0xFF7C3AED),
                  ),
                _Badge(
                  text: _badgeMetalLabel(score),
                  bg: const Color(0xFFF1F5F9),
                  fg: _badgeMetalColor(score),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Barres détail ─────────────────────────────
            _BarDetail(
              label: 'Régularité cotisation',
              pts: regularite,
              valueMax: 40,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Ancienneté',
              pts: anciennete,
              valueMax: 20,
              color: const Color(0xFF1D4ED8),
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Remboursement crédit',
              pts: remboursement,
              valueMax: 30,
              color: AppColors.attention,
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Objectif atteint',
              pts: objectifAtteint,
              valueMax: 10,
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 20),

            // ── Micro-crédit ──────────────────────────────
            if (plafond != null) ...[
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined,
                              color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text('Micro-crédit', style: AppTextStyles.titre3),
                          const Spacer(),
                          Text(
                            Formatters.montant(plafond),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push(Routes.microCredit, extra: fiche),
                          icon: const Icon(Icons.send_outlined, size: 18),
                          label: const Text('Initier micro-crédit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── PADME ─────────────────────────────────────
            if (score >= 70)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.apartment_outlined,
                              color: Color(0xFF7C3AED), size: 20),
                          const SizedBox(width: 8),
                          Text('Dossier PADME', style: AppTextStyles.titre3),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ce client est éligible au crédit PADME. Soumettez un dossier en son nom pour validation.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _loadingPadme ? null : _initierPadme,
                          icon: _loadingPadme
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.upload_file_outlined, size: 18),
                          label: Text(_loadingPadme
                              ? 'Soumission...'
                              : 'Soumettre dossier PADME'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF7C3AED).withValues(alpha: 0.5),
                            elevation: 0,
                            textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (score < 60) ...[
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline,
                          color: AppColors.muted, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Score insuffisant',
                        style: AppTextStyles.sousTitre
                            .copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Minimum 60/100 pour micro-crédit, 70/100 pour PADME.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _BarDetail extends StatelessWidget {
  final String label;
  final int pts;
  final int valueMax;
  final Color color;

  const _BarDetail({
    required this.label,
    required this.pts,
    required this.valueMax,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.texte,
              ),
            ),
            Text(
              '$pts pts',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: valueMax > 0 ? (pts / valueMax).clamp(0.0, 1.0) : 0,
          color: color,
          backgroundColor: const Color(0xFFE5E7EB),
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}
