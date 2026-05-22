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
import '../features/clients/presentation/screens/carte_terrain_screen.dart';
import '../features/clients/presentation/screens/client_detail_screen.dart';
import '../features/clients/presentation/screens/historique_client_screen.dart';
import '../features/clients/presentation/screens/qr_papier_screen.dart';
import '../features/clients/presentation/screens/score_padme_screen.dart';
import '../features/clients/presentation/screens/micro_credit_screen.dart';
import '../features/clients/presentation/screens/terrain_wallet_screen.dart';
import '../features/clients/presentation/screens/tontines_groupes_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/clients/presentation/screens/clients_screen.dart';
import '../features/collecte/presentation/screens/biometrie_screen.dart';
import '../features/collecte/presentation/screens/collecte_screen.dart';
import '../features/collecte/presentation/screens/collecte_success_screen.dart';
import '../features/collecte/presentation/screens/otp_wait_screen.dart';
import '../features/collecte/presentation/screens/collecte_assistee_screen.dart';
import '../features/collecte/presentation/screens/retrait_assistee_screen.dart';

import '../features/clients/data/models/client_models.dart';
import '../features/commissions/presentation/screens/commissions_screen.dart';
import '../features/enrolement/presentation/screens/enroll_screen.dart';
import '../features/enrolement/presentation/screens/enroll_success_screen.dart';
import '../features/enrolement/presentation/screens/ussd_guide_screen.dart';
import '../features/missions/presentation/screens/missions_screen.dart';
import '../features/notifications/presentation/screens/alerts_screen.dart';
import '../features/profil/presentation/screens/profile_screen.dart';
import '../features/profil/presentation/screens/settings_screen.dart';
import '../features/scanner/presentation/screens/qr_scan_screen.dart';
import '../features/supervision/presentation/screens/agents_screen.dart';
import '../features/supervision/presentation/screens/litiges_screen.dart';
import '../features/supervision/presentation/screens/zone_screen.dart';

/// Transition fade douce 220ms — pages internes
Page<void> fadePage(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, page) =>
          FadeTransition(opacity: animation, child: page),
    );

abstract class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const inscription = '/inscription';
  static const continuerInscription = '/continuer-inscription';
  static const otp = '/otp';
  static const creerPin = '/creer-pin';
  static const pin = '/pin';

  static const home = '/home';
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
  static const parametres = '/parametres';
  static const enrolement = '/enrolement';
  static const enrolementSucces = '/enrolement/succes';
  static const ussdGuide = '/ussd-guide';

  static const collecte = '/collecte';
  static const collecteBiometrie = '/collecte/biometrie';
  static const collecteSucces = '/collecte/succes';
  static const collecteOtpWait = '/collecte/otp-wait';

  static const collecteAssistee = '/collecte-assistee';
  static const retraitAssistee = '/retrait-assistee';
  static const historiqueClient = '/client-historique';
  static const scorePadme = '/score-padme';
  static const microCredit = '/micro-credit';
  static const terrainWallet = '/terrain-wallet';
  static const tontinesGroupes = '/tontines-groupes';
  static const carteTerrain = '/carte-terrain';
  static const qrPapier = '/qr-papier';

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

String routeAccueilPourRole(RoleCollecteur? role) => Routes.home;

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
        final role = RoleCollecteur.depuisApi(
          await SecureStorage.lireUserRole(),
        );
        if (role == RoleCollecteur.admin) {
          return Routes.home;
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
          return CreerPinScreen(telephone: e?['telephone']?.toString() ?? '');
        },
      ),
      GoRoute(path: Routes.pin, builder: (_, _) => const PinScreen()),

      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
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
          GoRoute(path: Routes.homeZone, builder: (_, _) => const ZoneScreen()),
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
        pageBuilder: (_, _) =>
            const MaterialPage(fullscreenDialog: true, child: QrScanScreen()),
      ),
      GoRoute(
        path: '/client/:id',
        pageBuilder: (_, state) => fadePage(
          ClientDetailScreen(clientId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: Routes.tontinesGroupes,
        builder: (_, _) => const TontinesGroupesScreen(),
      ),
      GoRoute(
        path: Routes.carteTerrain,
        builder: (_, state) {
          final clients = state.extra as List<dynamic>? ?? [];
          return CarteTerrainScreen(clients: clients);
        },
      ),
      GoRoute(
        path: Routes.qrPapier,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QrPapierScreen(
            nom: extra['nom'] as String,
            codeQr: extra['codeQr'] as String,
            identifiantTerrain:
                extra['identifiantTerrain'] as String? ?? '',
          );
        },
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
        path: Routes.collecteAssistee,
        pageBuilder: (_, state) =>
            fadePage(CollecteAssisteeScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.retraitAssistee,
        pageBuilder: (_, state) =>
            fadePage(RetraitAssisteeScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.historiqueClient,
        pageBuilder: (_, state) =>
            fadePage(HistoriqueClientScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.scorePadme,
        pageBuilder: (_, state) =>
            fadePage(ScorePadmeScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.microCredit,
        pageBuilder: (_, state) =>
            fadePage(MicroCreditScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.terrainWallet,
        pageBuilder: (_, state) =>
            fadePage(TerrainWalletScreen(fiche: state.extra as FicheTerrain), state),
      ),
      GoRoute(
        path: Routes.collecteSucces,
        pageBuilder: (_, state) => fadePage(const CollecteSuccessScreen(), state),
      ),
      GoRoute(path: Routes.enrolement, builder: (_, _) => const EnrollScreen()),
      GoRoute(
        path: Routes.enrolementSucces,
        builder: (_, _) => const EnrollSuccessScreen(),
      ),
      GoRoute(
        path: Routes.ussdGuide,
        builder: (_, _) => const UssdGuideScreen(),
      ),
      GoRoute(path: Routes.profil, builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: Routes.parametres,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Page introuvable\n${state.uri}'))),
  );
});
