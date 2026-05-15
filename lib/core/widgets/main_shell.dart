import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/session_provider.dart';
import '../../router/app_router.dart';
import '../constants/app_colors.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: const _CollecteurBottomNav(),
    );
  }
}

class _CollecteurBottomNav extends ConsumerWidget {
  const _CollecteurBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionProvider).role;
    final tabs = _tabsFor(role);
    final location = GoRouterState.of(context).matchedLocation;
    final index = tabs.indexWhere((tab) => location.startsWith(tab.route));
    return NavigationBar(
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (value) => context.go(tabs[value].route),
      indicatorColor: AppColors.primaryLight,
      destinations: tabs
          .map(
            (tab) => NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
          )
          .toList(),
    );
  }

  List<_ShellTab> _tabsFor(AppRole role) {
    if (role == AppRole.superviseur) {
      return const [
        _ShellTab(Routes.home, 'Zone', Icons.map_outlined, Icons.map),
        _ShellTab(Routes.supervision, 'Agents', Icons.groups_outlined, Icons.groups),
        _ShellTab(Routes.alertes, 'Alertes', Icons.warning_outlined, Icons.warning),
        _ShellTab(Routes.profil, 'Profil', Icons.person_outline, Icons.person),
      ];
    }
    return [
      const _ShellTab(Routes.home, 'Accueil', Icons.home_outlined, Icons.home),
      const _ShellTab(Routes.clients, 'Clients', Icons.people_outline, Icons.people),
      const _ShellTab(Routes.collecte, 'Collecte', Icons.payments_outlined, Icons.payments),
      _ShellTab(
        role == AppRole.agent ? Routes.missions : Routes.finances,
        role == AppRole.agent ? 'Missions' : 'Finances',
        role == AppRole.agent ? Icons.route_outlined : Icons.bar_chart_outlined,
        role == AppRole.agent ? Icons.route : Icons.bar_chart,
      ),
      const _ShellTab(Routes.profil, 'Profil', Icons.person_outline, Icons.person),
    ];
  }
}

class _ShellTab {
  const _ShellTab(this.route, this.label, this.icon, this.selectedIcon);
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
