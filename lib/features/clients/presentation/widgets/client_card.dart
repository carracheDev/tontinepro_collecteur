import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';
import '../../data/models/client_models.dart';

class ClientCard extends StatelessWidget {
  final ClientResume client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  Color get _couleurAvatar {
    const palette = [
      AppColors.info,
      AppColors.attention,
      AppColors.primary,
      Color(0xFF7C3AED),
      Color(0xFF0891B2),
    ];
    return palette[client.nom.hashCode.abs() % palette.length];
  }

  Color get _couleurScore {
    if (client.score >= 70) return AppColors.info;
    if (client.score >= 60) return AppColors.primary;
    return AppColors.annuler;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure.withValues(alpha: 0.7)),
        boxShadow: AppColors.shadowNiveau1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: avatar + infos + tag statut
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _couleurAvatar.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          Formatters.initiales(client.nom),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _couleurAvatar,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.nom,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.texte,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.telephone(client.telephone),
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 4),
                          // Smartphone/SMS badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: client.kycVerifie
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  client.kycVerifie
                                      ? Icons.smartphone
                                      : Icons.phone,
                                  size: 10,
                                  color: client.kycVerifie
                                      ? AppColors.info
                                      : AppColors.muted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  client.kycVerifie ? 'Smartphone' : 'SMS',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: client.kycVerifie
                                        ? AppColors.info
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: client.dejaVisite
                            ? AppColors.primaryLight
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        client.dejaVisite ? 'VISITÉ' : 'À VISITER',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: client.dejaVisite
                              ? AppColors.primary
                              : AppColors.annuler,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Stats: Solde / Journalier / Score
                Row(
                  children: [
                    Expanded(
                      child: _StatCell(
                        valeur: _formatMontantCourt(client.solde),
                        label: 'Solde F',
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        valeur: '${client.montantJournalierFcfa}',
                        label: 'Journalier',
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        valeur: '${client.score}',
                        label: 'Score',
                        couleur: _couleurScore,
                      ),
                    ),
                  ],
                ),

                // Barre score colorée
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: client.score / 100,
                          minHeight: 4,
                          backgroundColor: AppColors.bordureNeutre,
                          color: _couleurScore,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tag priorité si non visité + score éligible
                    if (!client.dejaVisite && client.score >= 60)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.attention.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '⚡ PRIORITÉ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.attention,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Collecter',
                        bgColor: AppColors.primaryLight,
                        txtColor: AppColors.primaryDark,
                        onTap: () => context.push(
                          Routes.collecte,
                          extra: {
                            'clientId': client.id,
                            'clientNom': client.nom,
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Fiche',
                        bgColor: Colors.white,
                        txtColor: AppColors.texte,
                        bordered: true,
                        onTap: onTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'WhatsApp',
                        bgColor: Colors.white,
                        txtColor: AppColors.texte,
                        bordered: true,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMontantCourt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return '$v';
  }
}

class _StatCell extends StatelessWidget {
  final String valeur;
  final String label;
  final Color? couleur;
  const _StatCell({required this.valeur, required this.label, this.couleur});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valeur,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: couleur ?? AppColors.texte,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color txtColor;
  final bool bordered;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.bgColor,
    required this.txtColor,
    this.bordered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: bordered ? Border.all(color: AppColors.bordure) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: txtColor,
          ),
        ),
      ),
    );
  }
}
