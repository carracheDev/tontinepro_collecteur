import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/client_models.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';

class ScorePadmeScreen extends StatelessWidget {
  final FicheTerrain fiche;

  const ScorePadmeScreen({super.key, required this.fiche});

  Color _couleurScore(int score) {
    if (score >= 70) return const Color(0xFF2563EB); // bleu
    if (score >= 60) return AppColors.primary; // vert
    return AppColors.annuler; // rouge
  }

  Color _badgeMaticMetalColor(int score) {
    if (score >= 90) return const Color(0xFF7C3AED); // diamant -> violet
    if (score >= 80) return const Color(0xFFB45309); // Or
    if (score >= 70) return const Color(0xFF64748B); // Argent (gris)
    return const Color(0xFF92400E); // Bronze (orange brun)
  }

  String _badgeMaticMetalLabel(int score) {
    if (score >= 90) return 'Diamant';
    if (score >= 80) return 'Or';
    if (score >= 70) return 'Argent';
    return 'Bronze';
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Score PADME'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A) Anneau score
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
                            style: AppTextStyles.corps.copyWith(
                              fontFamily: 'Nunito',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: _couleurScore(score),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('/100', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // B) Badges éligibilité
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (score >= 60)
                  _Badge(
                    text: 'micro-crédit ✓',
                    bg: AppColors.primaryLight,
                    fg: AppColors.primary,
                  ),
                if (score >= 70)
                  _Badge(
                    text: 'PADME ✓',
                    bg: const Color(0xFFF5F3FF),
                    fg: const Color(0xFF7C3AED),
                  ),
                _Badge(
                  text: _badgeMaticMetalLabel(score),
                  bg: const Color(0xFFF1F5F9),
                  fg: _badgeMaticMetalColor(score),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // C) Barres détail
            _BarDetail(
              label: 'Régularité cotisation',
              pts: regularite,
              valueMax: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Ancienneté',
              pts: anciennete,
              valueMax: 40,
              color: const Color(0xFF1D4ED8),
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Remboursement crédit',
              pts: remboursement,
              valueMax: 40,
              color: AppColors.attention,
            ),
            const SizedBox(height: 12),
            _BarDetail(
              label: 'Objectif atteint',
              pts: objectifAtteint,
              valueMax: 40,
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 18),

            // D) Plafond micro-crédit
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plafond micro-crédit : ${plafond != null ? Formatters.montant(plafond) : '—'}',
                      style: AppTextStyles.titre3.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(child: const SizedBox.shrink()),
                    const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () =>
                          context.push(Routes.microCredit, extra: fiche),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Initier micro-crédit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          value: pts / valueMax,
          color: color,
          backgroundColor: const Color(0xFFE5E7EB),
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}
