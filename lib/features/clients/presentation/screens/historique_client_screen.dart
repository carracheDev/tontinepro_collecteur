import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../../data/models/client_models.dart';

class HistoriqueClientScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;

  const HistoriqueClientScreen({super.key, required this.fiche});

  @override
  ConsumerState<HistoriqueClientScreen> createState() =>
      _HistoriqueClientScreenState();
}

class _HistoriqueClientScreenState
    extends ConsumerState<HistoriqueClientScreen> {
  String filtre = 'today';

  @override
  Widget build(BuildContext context) {
    final transactions = widget.fiche.transactions;

    final filtered = transactions.where((t) {
      final date =
          DateTime.tryParse(t['creeLe']?.toString() ?? '') ?? DateTime.now();
      final now = DateTime.now();
      switch (filtre) {
        case 'today':
          return date.day == now.day && date.month == now.month;
        case 'week':
          return now.difference(date).inDays <= 7;
        case 'month':
          return date.month == now.month && date.year == now.year;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: Text('Historique · ${widget.fiche.nom}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: 'Aujourd\'hui',
                  selected: filtre == 'today',
                  onTap: () => setState(() => filtre = 'today'),
                ),
                _Chip(
                  label: '7 jours',
                  selected: filtre == 'week',
                  onTap: () => setState(() => filtre = 'week'),
                ),
                _Chip(
                  label: 'Ce mois',
                  selected: filtre == 'month',
                  onTap: () => setState(() => filtre = 'month'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icone: Icons.receipt_long_outlined,
                      titre: 'Aucune transaction',
                      sousTitre: 'Aucune transaction sur cette période.',
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final t = filtered[i];
                        final type = t['type']?.toString() ?? 'Transaction';
                        final montant = (t['montant'] as num?)?.toInt() ?? 0;
                        final creeLe = t['creeLe']?.toString() ?? '';
                        final date =
                            DateTime.tryParse(creeLe) ?? DateTime.now();

                        final isRetrait =
                            type.toUpperCase().contains('RETRAIT') ||
                            montant < 0;
                        final isCredit =
                            type.toUpperCase().contains('CREDIT') ||
                            type.toUpperCase().contains('MICRO');

                        final color = isCredit
                            ? AppColors.info
                            : isRetrait
                            ? AppColors.annuler
                            : AppColors.primary;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isCredit
                                            ? Icons.account_balance_wallet
                                            : isRetrait
                                            ? Icons
                                                  .account_balance_wallet_outlined
                                            : Icons.add_circle_outline,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$type · ${date.toLocal().toString().split(' ')[0]}',
                                          style: AppTextStyles.corps.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${montant >= 0 ? '+' : ''}${Formatters.montant(montant.abs())}',
                                    style: AppTextStyles.corps.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: montant >= 0
                                          ? AppColors.primary
                                          : AppColors.annuler,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primaryLight : const Color(0xFFF3F4F6);
    final fg = selected ? AppColors.primary : AppColors.texteSecond;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}
