import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../enums/role_collecteur.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../router/app_router.dart';

// Déclenche la génération du QR collecteur dès le premier affichage du shell
// pour que le code soit toujours en base avant qu'un client le scanne.
final _qrPrechauffeProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    await DioClient.instance.get(ApiEndpoints.monCodeQr);
  } catch (_) {
    // Silencieux — le profil le régénère si nécessaire
  }
});

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    // Préchauffer le QR dès que le shell est monté (après login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_qrPrechauffeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(sessionRoleProvider);
    final role = roleAsync.value ?? RoleCollecteur.agent;
    final tabs = _tabsPourRole(role);
    final location = GoRouterState.of(context).matchedLocation;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.fond,
        body: widget.child,
        extendBody: true,
        bottomNavigationBar: roleAsync.isLoading
            ? null
            : _BottomNav(tabs: tabs, location: location, role: role),
      ),
    );
  }

  List<_TabInfo> _tabsPourRole(RoleCollecteur role) {
    switch (role) {
      case RoleCollecteur.agent:
        return const [
          _TabInfo(Routes.home, Icons.home_outlined, Icons.home, 'Accueil'),
          _TabInfo(Routes.homeClients, Icons.people_outline, Icons.people, 'Clients'),
          _TabInfo('__qr__', Icons.qr_code_scanner, Icons.qr_code_scanner, ''),
          _TabInfo(Routes.homeMissions, Icons.route_outlined, Icons.route, 'Missions'),
          _TabInfo(Routes.homeAlertes, Icons.notifications_outlined, Icons.notifications, 'Alertes'),
        ];
      case RoleCollecteur.admin:
        return const [
          _TabInfo(Routes.home, Icons.home_outlined, Icons.home, 'Accueil'),
          _TabInfo(Routes.homeAlertes, Icons.notifications_outlined, Icons.notifications, 'Alertes'),
        ];
    }
  }
}

class _BottomNav extends StatelessWidget {
  final List<_TabInfo> tabs;
  final String location;
  final RoleCollecteur role;

  const _BottomNav({
    required this.tabs,
    required this.location,
    required this.role,
  });

  int _indexActif() {
    // Try exact match first, then prefix match (for sub-routes)
    for (var i = 0; i < tabs.length; i++) {
      final r = tabs[i].route;
      if (r != '__qr__' && location == r) return i;
    }
    for (var i = 0; i < tabs.length; i++) {
      final r = tabs[i].route;
      if (r != '__qr__' && r != Routes.home && location.startsWith(r)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final actif = _indexActif();
    final avecQr = role.peutScanner;

    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < tabs.length; i++)
                  if (tabs[i].route == '__qr__')
                    const SizedBox(width: 58)
                  else
                    _Onglet(
                      tab: tabs[i],
                      actif: actif == i,
                      onTap: () => context.go(tabs[i].route),
                    ),
              ],
            ),
            if (avecQr)
              Positioned(
                top: -18,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.push(Routes.homeQr),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3316A34A),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  final _TabInfo tab;
  final bool actif;
  final VoidCallback onTap;

  const _Onglet({
    required this.tab,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              actif ? tab.iconeActif : tab.icone,
              color: actif ? AppColors.primary : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: actif ? FontWeight.w800 : FontWeight.w500,
                color: actif ? AppColors.primary : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabInfo {
  final String route;
  final IconData icone;
  final IconData iconeActif;
  final String label;
  const _TabInfo(this.route, this.icone, this.iconeActif, this.label);
}
