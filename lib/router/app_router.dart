import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/role_collecteur.dart';
import '../core/storage/secure_storage.dart';
import '../core/widgets/main_shell.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/creer_pin_screen.dart';
import '../features/auth/presentation/screens/continuer_inscription_screen.dart';
import '../features/auth/presentation/screens/inscription_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/pin_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/scanner/presentation/screens/qr_scan_placeholder_screen.dart';

abstract class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const inscription = '/inscription';
  static const continuerInscription = '/continuer-inscription';
  static const otp = '/otp';
  static const creerPin = '/creer-pin';
  static const pin = '/pin';

  static const homeDefaut = homeMissions;
  static const homeMissions = '/home/missions';
  static const homeClients = '/home/clients';
  static const homeCollecte = '/home/collecte';
  static const homeQr = '/home/qr';
  static const homeFinances = '/home/finances';
  static const homeZone = '/home/zone';
  static const homeAgents = '/home/agents';
  static const homeLitiges = '/home/litiges';
  static const homeAlertes = '/home/alertes';

  static const profil = '/profil';

  static const _publiques = {
    splash,
    onboarding,
    auth,
    inscription,
    continuerInscription,
    otp,
    creerPin,
    pin,
  };

  static bool estPublique(String loc) => _publiques.contains(loc);
}

String routeAccueilPourRole(RoleCollecteur? role) {
  switch (role) {
    case RoleCollecteur.superviseur:
      return Routes.homeZone;
    case RoleCollecteur.independant:
      return Routes.homeClients;
    case RoleCollecteur.agent:
    case null:
      return Routes.homeMissions;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      if (Routes.estPublique(loc) || loc == Routes.splash) return null;

      final connecte = await SecureStorage.estConnecte();
      if (!connecte) return Routes.auth;

      // Superviseur : interdit collecte et scanner
      if (loc == Routes.homeCollecte || loc == Routes.homeQr) {
        final role = RoleCollecteur.depuisApi(await SecureStorage.lireUserRole());
        if (role == RoleCollecteur.superviseur) {
          return Routes.homeZone;
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.auth, builder: (_, _) => const AuthScreen()),
      GoRoute(
        path: Routes.inscription,
        builder: (_, _) => const InscriptionScreen(),
      ),
      GoRoute(
        path: Routes.continuerInscription,
        builder: (_, _) => const ContinuerInscriptionScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (_, state) {
          final e = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            telephone: e?['telephone']?.toString() ?? '',
            nom: e?['nom']?.toString() ?? '',
            role: e?['role']?.toString() ?? 'AGENT',
            otpTest: e?['otpTest']?.toString(),
          );
        },
      ),
      GoRoute(
        path: Routes.creerPin,
        builder: (_, state) {
          final e = state.extra as Map<String, dynamic>?;
          return CreerPinScreen(
            telephone: e?['telephone']?.toString() ?? '',
          );
        },
      ),
      GoRoute(path: Routes.pin, builder: (_, _) => const PinScreen()),

      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.homeMissions,
            builder: (_, _) => const HomeScreen(
              titre: 'Missions',
              icone: Icons.route_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeClients,
            builder: (_, _) => const HomeScreen(
              titre: 'Clients',
              icone: Icons.people_outline,
            ),
          ),
          GoRoute(
            path: Routes.homeCollecte,
            builder: (_, _) => const HomeScreen(
              titre: 'Collecte',
              icone: Icons.payments_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeFinances,
            builder: (_, _) => const HomeScreen(
              titre: 'Finances',
              icone: Icons.account_balance_wallet_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeZone,
            builder: (_, _) => const HomeScreen(
              titre: 'Ma Zone',
              icone: Icons.map_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeAgents,
            builder: (_, _) => const HomeScreen(
              titre: 'Agents',
              icone: Icons.groups_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeLitiges,
            builder: (_, _) => const HomeScreen(
              titre: 'Litiges',
              icone: Icons.gavel_outlined,
            ),
          ),
          GoRoute(
            path: Routes.homeAlertes,
            builder: (_, _) => const HomeScreen(
              titre: 'Alertes',
              icone: Icons.notifications_outlined,
            ),
          ),
        ],
      ),

      GoRoute(
        path: Routes.homeQr,
        pageBuilder: (_, _) => const MaterialPage(
          fullscreenDialog: true,
          child: QrScanPlaceholderScreen(),
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page introuvable\n${state.uri}'),
      ),
    ),
  );
});
