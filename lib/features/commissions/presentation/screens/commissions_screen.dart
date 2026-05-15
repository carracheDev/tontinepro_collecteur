import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/home_header.dart';
import '../../data/repositories/commissions_repository.dart';

final soldeCommissionProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(commissionsRepositoryProvider).monSolde();
});

final historiqueCommissionProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(commissionsRepositoryProvider).historique();
});

final dashboardIndepProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(commissionsRepositoryProvider).dashboardIndependant();
});

class CommissionsScreen extends ConsumerWidget {
  const CommissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soldeAsync = ref.watch(soldeCommissionProvider);
    final histAsync = ref.watch(historiqueCommissionProvider);
    final dashAsync = ref.watch(dashboardIndepProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(soldeCommissionProvider);
            ref.invalidate(historiqueCommissionProvider);
            ref.invalidate(dashboardIndepProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const HomeHeader(sousTitre: 'Commissions et revenus'),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    soldeAsync.when(
                      data: (s) => AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Solde disponible', style: AppTextStyles.caption),
                            Text(
                              Formatters.montant(s.soldeDisponible),
                              style: AppTextStyles.montantMoyen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ce mois : ${Formatters.montant(s.totalMois)}',
                              style: AppTextStyles.corpsSecond,
                            ),
                          ],
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (e, _) => Text(e.toString()),
                    ),
                    const SizedBox(height: 16),
                    dashAsync.when(
                      data: (d) {
                        final graph = (d['graphiqueRevenus'] as List?) ?? [];
                        if (graph.isEmpty) return const SizedBox.shrink();
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revenus 6 mois', style: AppTextStyles.titre3),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  BarChartData(
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    barGroups: [
                                      for (var i = 0; i < graph.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: ((graph[i]
                                                              as Map)['montantFcfa']
                                                          as num?)
                                                      ?.toDouble() ??
                                                  0,
                                              color: AppColors.primary,
                                              width: 14,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    Text('Historique', style: AppTextStyles.titre3),
                    const SizedBox(height: 8),
                    histAsync.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return Text(
                            'Aucune commission enregistrée',
                            style: AppTextStyles.corpsSecond,
                          );
                        }
                        return Column(
                          children: list
                              .take(20)
                              .map(
                                (l) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AppCard(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l.type, style: AppTextStyles.corps),
                                        Text(
                                          Formatters.montant(l.montant),
                                          style: AppTextStyles.montantPetit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text(e.toString()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
