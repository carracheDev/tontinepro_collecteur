import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../clients/presentation/providers/clients_provider.dart';
import '../../../commissions/data/repositories/commissions_repository.dart';
import '../../../supervision/data/repositories/supervision_repository.dart';

final _homeCommissionProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(commissionsRepositoryProvider).monSolde();
});

final _homeZoneKpisProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(supervisionRepositoryProvider).kpis();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nom = ref.watch(sessionNomProvider).value ?? 'Collecteur';
    final role = ref.watch(sessionRoleProvider).value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.fond,
        drawer: _AppDrawer(nom: nom, role: role),
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(sessionNomProvider);
            ref.invalidate(sessionRoleProvider);
            ref.invalidate(clientsDuJourProvider);
            ref.invalidate(_homeCommissionProvider);
            ref.invalidate(_homeZoneKpisProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              _HeroCard(nom: nom, role: role),
              const SizedBox(height: 16),
              _QuickActionsGrid(role: role),
              const SizedBox(height: 16),
              _DashboardBody(role: role),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x14000000),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.texte),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'TontinePro',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.texte,
              ),
              onPressed: () => context.go(Routes.homeAlertes),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.annuler,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends ConsumerWidget {
  final String nom;
  final RoleCollecteur? role;
  const _HeroCard({required this.nom, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = _buildKpis(ref);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientHero,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.35),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD1FAE5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nom,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (role != null)
                          _HeroBadge(role!.label, Colors.white.withValues(alpha: 0.18)),
                        _HeroBadge('Compte ACTIF', const Color(0x2286EFAC)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < kpis.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _KpiBox(valeur: kpis[i].$1, label: kpis[i].$2)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 🌤';
    if (h < 18) return 'Bon après-midi ☀️';
    return 'Bonsoir 🌙';
  }

  List<(String, String)> _buildKpis(WidgetRef ref) {
    switch (role) {
      case RoleCollecteur.agent:
        final d = ref.watch(clientsDuJourProvider).value;
        final taux = d != null && d.stats.total > 0
            ? '${((d.stats.visites / d.stats.total) * 100).round()}%'
            : '—';
        return [
          (d?.stats.total.toString() ?? '—', 'Clients'),
          (d?.stats.visites.toString() ?? '—', 'Visités'),
          (taux, 'Taux'),
        ];
      case RoleCollecteur.independant:
        final d = ref.watch(_homeCommissionProvider).value;
        final nbClients = ref.watch(clientsDuJourProvider).value?.stats.total;
        return [
          (nbClients?.toString() ?? '—', 'Clients'),
          (d != null ? _montantCourt(d.soldeDisponible) : '—', 'Commissions'),
          ('1,5%', 'Taux'),
        ];
      case RoleCollecteur.superviseur:
        final d = ref.watch(_homeZoneKpisProvider).value;
        return [
          (d?['collecteurs']?.toString() ?? '—', 'Agents'),
          ('${d?['tauxCollecte'] ?? 0}%', 'Taux zone'),
          (d?['litigesOuverts']?.toString() ?? '—', 'Litiges'),
        ];
      default:
        return [('—', 'Clients'), ('—', 'Visités'), ('—', 'Taux')];
    }
  }

  String _montantCourt(num val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}k F';
    return '$val F';
  }
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  const _HeroBadge(this.label, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String valeur;
  final String label;
  const _KpiBox({required this.valeur, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            valeur,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD1FAE5),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends ConsumerWidget {
  final RoleCollecteur? role;
  const _QuickActionsGrid({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _actionsForRole(role);
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions
          .map((a) => _ActionCard(icon: a.$1, label: a.$2, route: a.$3))
          .toList(),
    );
  }

  List<(IconData, String, String)> _actionsForRole(RoleCollecteur? role) {
    switch (role) {
      case RoleCollecteur.agent:
        return [
          (Icons.people_outline, 'Clients', Routes.homeClients),
          (Icons.qr_code_scanner_rounded, 'Collecte', Routes.homeQr),
          (Icons.route_outlined, 'Missions', Routes.homeMissions),
          (Icons.person_add_outlined, 'Enrôler', Routes.enrolement),
        ];
      case RoleCollecteur.independant:
        return [
          (Icons.people_outline, 'Clients', Routes.homeClients),
          (Icons.qr_code_scanner_rounded, 'Collecte', Routes.homeQr),
          (Icons.groups_outlined, 'Tontines groupes', Routes.tontinesGroupes),
          (Icons.person_add_outlined, 'Enrôler', Routes.enrolement),
        ];
      case RoleCollecteur.superviseur:
        return [
          (Icons.map_outlined, 'Zone', Routes.homeZone),
          (Icons.people_outline, 'Clients', Routes.homeClients),
          (Icons.gavel_outlined, 'Litiges', Routes.homeLitiges),
          (Icons.notifications_outlined, 'Alertes', Routes.homeAlertes),
        ];
      default:
        return [];
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (route == Routes.homeQr) {
          context.push(route);
        } else if (route == Routes.enrolement ||
            route == Routes.tontinesGroupes) {
          context.push(route);
        } else {
          context.go(route);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.bordure),
          boxShadow: const [
            BoxShadow(
              color: Color(0x070F172A),
              blurRadius: 14,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.texte,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final RoleCollecteur? role;
  const _DashboardBody({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (role) {
      case RoleCollecteur.agent:
        return _AgentDashboard();
      case RoleCollecteur.independant:
        return _IndependantDashboard();
      case RoleCollecteur.superviseur:
        return _SuperviseurDashboard();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AgentDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientsDuJourProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Missions du jour', style: AppTextStyles.titre3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'GPS requis',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A56DB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              async.when(
                data: (d) {
                  final pct = d.stats.total == 0
                      ? 0.0
                      : d.stats.visites / d.stats.total;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 10,
                          backgroundColor: AppColors.primaryLight,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${d.stats.visites}/${d.stats.total} visites · ${d.stats.restantes} restante(s)',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(
                  color: AppColors.primary,
                ),
                error: (_, _) => Text(
                  'Données indisponibles',
                  style: AppTextStyles.caption,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.homeMissions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'VOIR TOURNÉE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message superviseur',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Priorité aux clients en retard de remboursement avant 13h.',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndependantDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soldeAsync = ref.watch(_homeCommissionProvider);
    return Column(
      children: [
        soldeAsync.when(
          data: (s) => Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.bordure),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Revenus du mois', style: AppTextStyles.titre3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Pack Pro',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.montant(s.totalMois),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.texte,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Disponible : ${Formatters.montant(s.soldeDisponible)}',
                  style: AppTextStyles.corpsSecond,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.go(Routes.homeFinances),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'VOIR COMMISSIONS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.bordure),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                label: 'Tontines groupes',
                sousTitre: 'Gérer mes groupes',
                icon: Icons.groups_outlined,
                onTap: () => context.go(Routes.homeClients),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniCard(
                label: 'Micro-crédits',
                sousTitre: 'Demandes clients',
                icon: Icons.account_balance_outlined,
                onTap: () => context.go(Routes.homeClients),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuperviseurDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(_homeZoneKpisProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Zone en temps réel', style: AppTextStyles.titre3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Admin désigné',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              kpisAsync.when(
                data: (d) => Row(
                  children: [
                    Expanded(
                      child: _StatMini(
                        valeur: d['collecteurs']?.toString() ?? '—',
                        label: 'Agents actifs',
                        bgColor: AppColors.primaryLight,
                        txtColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatMini(
                        valeur: '${d['tauxCollecte'] ?? 0}%',
                        label: 'Performance',
                        bgColor: const Color(0xFFEFF6FF),
                        txtColor: const Color(0xFF1A56DB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatMini(
                        valeur: d['litigesOuverts']?.toString() ?? '0',
                        label: 'Litiges',
                        bgColor: const Color(0xFFFEF2F2),
                        txtColor: AppColors.annuler,
                      ),
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(
                  color: AppColors.primary,
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.homeZone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'PILOTER LA ZONE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String valeur;
  final String label;
  final Color bgColor;
  final Color txtColor;
  const _StatMini({
    required this.valeur,
    required this.label,
    required this.bgColor,
    required this.txtColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valeur,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: txtColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: txtColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String sousTitre;
  final IconData icon;
  final VoidCallback onTap;
  const _MiniCard({
    required this.label,
    required this.sousTitre,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.texte,
              ),
            ),
            Text(sousTitre, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  final String nom;
  final RoleCollecteur? role;
  const _AppDrawer({required this.nom, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initiales = Formatters.initiales(nom);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        initiales,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nom,
                          style: AppTextStyles.titre3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role?.label ?? 'Collecteur',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.home);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Clients',
                    sousTitre: 'Portefeuille terrain',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.homeClients);
                    },
                  ),
                  if (role != RoleCollecteur.superviseur) ...[
                    _DrawerItem(
                      icon: Icons.person_add_outlined,
                      label: 'Enrôler un client',
                      sousTitre: 'Client sans smartphone',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(Routes.enrolement);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Collecte terrain',
                      sousTitre: 'Scanner QR client',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(Routes.homeQr);
                      },
                    ),
                  ],
                  if (role == RoleCollecteur.agent)
                    _DrawerItem(
                      icon: Icons.route_outlined,
                      label: 'Missions du jour',
                      sousTitre: 'Tournée GPS',
                      onTap: () {
                        Navigator.pop(context);
                        context.go(Routes.homeMissions);
                      },
                    ),
                  if (role == RoleCollecteur.independant)
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Commissions',
                      sousTitre: 'Indépendant uniquement',
                      onTap: () {
                        Navigator.pop(context);
                        context.go(Routes.homeFinances);
                      },
                    ),
                  if (role == RoleCollecteur.superviseur) ...[
                    _DrawerItem(
                      icon: Icons.map_outlined,
                      label: 'Supervision zone',
                      sousTitre: 'Superviseur zone',
                      onTap: () {
                        Navigator.pop(context);
                        context.go(Routes.homeZone);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.groups_outlined,
                      label: 'Agents',
                      sousTitre: 'Performance équipe',
                      onTap: () {
                        Navigator.pop(context);
                        context.go(Routes.homeAgents);
                      },
                    ),
                  ],
                  _DrawerItem(
                    icon: Icons.gavel_outlined,
                    label: 'Litiges',
                    sousTitre: role == RoleCollecteur.superviseur
                        ? 'Examine et clôture'
                        : 'Signaler un problème',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.homeLitiges);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Alertes',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.homeAlertes);
                    },
                  ),
                  const Divider(height: 24),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Mon profil',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.profil);
                    },
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sousTitre;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.sousTitre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.texte,
        ),
      ),
      subtitle: sousTitre != null
          ? Text(
              sousTitre!,
              style: AppTextStyles.caption,
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
