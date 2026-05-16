import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
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
      appBar: AppBar(
        title: const Text('Mes commissions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(soldeCommissionProvider);
          ref.invalidate(historiqueCommissionProvider);
          ref.invalidate(dashboardIndepProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // ── Hero solde ──────────────────────────────────────
            _HeroSolde(soldeAsync: soldeAsync),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Graphique 6 mois ───────────────────────────
                  dashAsync.when(
                    data: (d) {
                      final graph = (d['graphiqueRevenus'] as List?) ?? [];
                      if (graph.isEmpty) return const SizedBox.shrink();
                      return _GraphiqueMois(graph: graph);
                    },
                    loading: () => const LoadingSkeleton(height: 200, radius: 18),
                    error: (_, _) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),

                  // ── Historique ─────────────────────────────────
                  Text('Historique', style: AppTextStyles.titre3),
                  const SizedBox(height: 12),
                  histAsync.when(
                    data: (list) => list.isEmpty
                        ? EmptyStateWidget(
                            icone: Icons.receipt_long_outlined,
                            titre: 'Aucune commission',
                            sousTitre: 'Vos commissions apparaîtront ici.',
                          )
                        : Column(
                            children: list
                                .take(30)
                                .map((l) => _LigneHistorique(ligne: l))
                                .toList(),
                          ),
                    loading: () => Column(
                      children: List.generate(
                        5,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LoadingSkeleton(height: 64, radius: 14),
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      e.toString(),
                      style: AppTextStyles.corpsSecond,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero solde
// ─────────────────────────────────────────────────────────────

class _HeroSolde extends StatelessWidget {
  final AsyncValue<SoldeCommission> soldeAsync;

  const _HeroSolde({required this.soldeAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientHero,
      ),
      child: soldeAsync.when(
        data: (s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solde disponible',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white60,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.montant(s.soldeDisponible),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatPill(
                  label: 'Ce mois',
                  value: Formatters.montant(s.totalMois),
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(width: 12),
                _StatPill(
                  label: 'Opérations',
                  value: '${s.nbTransactions}',
                  icon: Icons.receipt_rounded,
                ),
              ],
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (e, _) => Text(
          e.toString(),
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryVif, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Graphique 6 mois
// ─────────────────────────────────────────────────────────────

class _GraphiqueMois extends StatelessWidget {
  final List<dynamic> graph;

  const _GraphiqueMois({required this.graph});

  @override
  Widget build(BuildContext context) {
    final maxVal = graph
        .map((e) => ((e as Map)['montantFcfa'] as num?)?.toDouble() ?? 0)
        .fold(0.0, (a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenus — 6 derniers mois', style: AppTextStyles.titre3),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.3,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (v) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= graph.length) {
                          return const SizedBox.shrink();
                        }
                        final mois =
                            (graph[i] as Map)['mois']?.toString() ?? '';
                        final label = _moisAbrev(mois);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < graph.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ((graph[i] as Map)['montantFcfa'] as num?)
                                  ?.toDouble() ??
                              0,
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.primary, AppColors.primaryVif],
                          ),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryDark,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      Formatters.montant(rod.toY.toInt()),
                      const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moisAbrev(String mois) {
    final parts = mois.split('-');
    if (parts.length < 2) return mois.isNotEmpty ? mois.substring(0, 3) : '';
    final m = int.tryParse(parts[1]) ?? 0;
    const abrevs = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return m > 0 && m <= 12 ? abrevs[m] : mois;
  }
}

// ─────────────────────────────────────────────────────────────
// Ligne historique
// ─────────────────────────────────────────────────────────────

class _LigneHistorique extends StatelessWidget {
  final LigneCommission ligne;

  const _LigneHistorique({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final color = _couleurType(ligne.type);
    final icon = _iconeType(ligne.type);
    final dateStr =
        '${ligne.date.day.toString().padLeft(2, '0')}/'
        '${ligne.date.month.toString().padLeft(2, '0')}/'
        '${ligne.date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _libelleType(ligne.type),
                    style: AppTextStyles.corps.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(dateStr, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(
              '+${Formatters.montant(ligne.montant)}',
              style: AppTextStyles.corps.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _couleurType(String type) {
    final t = type.toUpperCase();
    if (t.contains('COTIS')) return AppColors.primary;
    if (t.contains('RETRAIT')) return AppColors.attention;
    if (t.contains('CREDIT') || t.contains('MICRO')) return AppColors.info;
    return AppColors.primary;
  }

  IconData _iconeType(String type) {
    final t = type.toUpperCase();
    if (t.contains('COTIS')) return Icons.savings_outlined;
    if (t.contains('RETRAIT')) return Icons.account_balance_wallet_outlined;
    if (t.contains('CREDIT') || t.contains('MICRO')) return Icons.payments_outlined;
    return Icons.monetization_on_outlined;
  }

  String _libelleType(String type) {
    final t = type.toUpperCase();
    if (t.contains('COTIS')) return 'Commission cotisation';
    if (t.contains('RETRAIT')) return 'Commission retrait';
    if (t.contains('CREDIT') || t.contains('MICRO')) return 'Commission micro-crédit';
    return type;
  }
}
