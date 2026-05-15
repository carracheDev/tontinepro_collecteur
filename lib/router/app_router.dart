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
import '../features/clients/presentation/screens/client_detail_screen.dart';
import '../features/clients/presentation/screens/clients_screen.dart';
import '../features/collecte/presentation/screens/biometrie_screen.dart';
import '../features/collecte/presentation/screens/collecte_screen.dart';
import '../features/collecte/presentation/screens/collecte_success_screen.dart';
import '../features/collecte/presentation/screens/otp_wait_screen.dart';
import '../features/commissions/presentation/screens/commissions_screen.dart';
import '../features/enrolement/presentation/screens/enroll_screen.dart';
import '../features/enrolement/presentation/screens/enroll_success_screen.dart';
import '../features/enrolement/presentation/screens/ussd_guide_screen.dart';
import '../features/missions/presentation/screens/missions_screen.dart';
import '../features/notifications/presentation/screens/alerts_screen.dart';
import '../features/profil/presentation/screens/profile_screen.dart';
import '../features/scanner/presentation/screens/qr_scan_screen.dart';
import '../features/supervision/presentation/screens/agents_screen.dart';
import '../features/supervision/presentation/screens/litiges_screen.dart';
import '../features/supervision/presentation/screens/zone_screen.dart';

abstract class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const inscription = '/inscription';
  static const continuerInscription = '/continuer-inscription';
  static const otp = '/otp';
  static const creerPin = '/creer-pin';
  static const pin = '/pin';

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
  static const enrolement = '/enrolement';
  static const enrolementSucces = '/enrolement/succes';
  static const ussdGuide = '/ussd-guide';

  static const collecte = '/collecte';
  static const collecteBiometrie = '/collecte/biometrie';
  static const collecteSucces = '/collecte/succes';
  static const collecteOtpWait = '/collecte/otp-wait';

  static String clientDetail(String id) => '/client/$id';

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

      if (loc == Routes.homeCollecte || loc == Routes.homeQr) {
        final role =
            RoleCollecteur.depuisApi(await SecureStorage.lireUserRole());
        if (role == RoleCollecteur.superviseur) {
          return Routes.homeZone;
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
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
            builder: (_, _) => const MissionsScreen(),
          ),
          GoRoute(
            path: Routes.homeClients,
            builder: (_, _) => const ClientsScreen(),
          ),
          GoRoute(
            path: Routes.homeCollecte,
            builder: (_, _) => const CollecteScreen(),
          ),
          GoRoute(
            path: Routes.homeFinances,
            builder: (_, _) => const CommissionsScreen(),
          ),
          GoRoute(
            path: Routes.homeZone,
            builder: (_, _) => const ZoneScreen(),
          ),
          GoRoute(
            path: Routes.homeAgents,
            builder: (_, _) => const AgentsScreen(),
          ),
          GoRoute(
            path: Routes.homeLitiges,
            builder: (_, _) => const LitigesScreen(),
          ),
          GoRoute(
            path: Routes.homeAlertes,
            builder: (_, _) => const AlertsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: Routes.homeQr,
        pageBuilder: (_, _) => const MaterialPage(
          fullscreenDialog: true,
          child: QrScanScreen(),
        ),
      ),
      GoRoute(
        path: '/client/:id',
        builder: (_, state) => ClientDetailScreen(
          clientId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.collecte,
        builder: (_, state) => const CollecteScreen(),
      ),
      GoRoute(
        path: Routes.collecteBiometrie,
        builder: (_, _) => const BiometrieScreen(),
      ),
      GoRoute(
        path: Routes.collecteOtpWait,
        builder: (_, _) => const OtpWaitScreen(),
      ),
      GoRoute(
        path: Routes.collecteSucces,
        builder: (_, _) => const CollecteSuccessScreen(),
      ),
      GoRoute(
        path: Routes.enrolement,
        builder: (_, _) => const EnrollScreen(),
      ),
      GoRoute(
        path: Routes.enrolementSucces,
        builder: (_, _) => const EnrollSuccessScreen(),
      ),
      GoRoute(
        path: Routes.ussdGuide,
        builder: (_, _) => const UssdGuideScreen(),
      ),
      GoRoute(
        path: Routes.profil,
        builder: (_, _) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable\n${state.uri}')),
    ),
  );
});
