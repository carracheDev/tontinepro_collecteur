import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/supervision_repository.dart';

final zoneKpisProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(supervisionRepositoryProvider).kpis();
});

final zoneScoresProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(supervisionRepositoryProvider).scoresParZone();
});

class ZoneScreen extends ConsumerWidget {
  const ZoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(zoneKpisProvider);
    final zonesAsync = ref.watch(zoneScoresProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Ma Zone'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(zoneKpisProvider);
          ref.invalidate(zoneScoresProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: kpisAsync.when(
                  data: (k) {
                    final cartes = <Widget>[
                      if (k['clientsActifs'] != null)
                        _KpiCard(
                          label: 'Clients actifs',
                          valeur: '${k['clientsActifs']}',
                        ),
                      if (k['collecteursActifs'] != null)
                        _KpiCard(
                          label: 'Collecteurs',
                          valeur: '${k['collecteursActifs']}',
                        ),
                      if (k['volumeMoisFcfa'] != null)
                        _KpiCard(
                          label: 'Volume mois',
                          valeur: Formatters.montant(
                            (k['volumeMoisFcfa'] as num).toInt(),
                          ),
                        ),
                    ];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: cartes,
                        ),
                        const SizedBox(height: 16),
                        zonesAsync.when(
                          data: (zones) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Scores par zone', style: AppTextStyles.titre3),
                              const SizedBox(height: 8),
                              ...zones.map(
                                (z) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AppCard(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          z['nom']?.toString() ??
                                              z['zone']?.toString() ??
                                              'Zone',
                                          style: AppTextStyles.corps,
                                        ),
                                        Text(
                                          'Score ${z['scoreMoyen'] ?? z['score'] ?? '—'}',
                                          style: AppTextStyles.montantPetit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Text(e.toString()),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String valeur;
  const _KpiCard({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 2,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(valeur, style: AppTextStyles.montantPetit),
          ],
        ),
      ),
    );
  }
}
