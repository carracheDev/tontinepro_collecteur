import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/secure_storage.dart';
import '../core/widgets/main_shell.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/pin_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/clients/presentation/screens/client_detail_screen.dart';
import '../features/clients/presentation/screens/clients_screen.dart';
import '../features/collecte/presentation/screens/biometrie_screen.dart';
import '../features/collecte/presentation/screens/collecte_screen.dart';
import '../features/collecte/presentation/screens/otp_wait_screen.dart';
import '../features/collecte/presentation/screens/success_screen.dart';
import '../features/commissions/presentation/screens/commissions_screen.dart';
import '../features/enrolement/presentation/screens/enroll_screen.dart';
import '../features/enrolement/presentation/screens/enroll_success_screen.dart';
import '../features/enrolement/presentation/screens/ussd_guide_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/missions/presentation/screens/missions_screen.dart';
import '../features/notifications/presentation/screens/alerts_screen.dart';
import '../features/profil/presentation/screens/profile_screen.dart';
import '../features/scanner/presentation/screens/qr_scan_screen.dart';
import '../features/supervision/presentation/screens/supervision_screen.dart';

abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const pin = '/pin';

  static const home = '/home';
  static const clients = '/clients';
  static const clientDetailPattern = '/clients/:id';
  static String clientDetail(String id) => '/clients/$id';
  static const collecte = '/collecte';
  static const missions = '/missions';
  static const finances = '/finances';
  static const supervision = '/supervision';
  static const alertes = '/alertes';
  static const profil = '/profil';

  static const scanner = '/scanner';
  static const biometrie = '/biometrie';
  static const otpWait = '/otp';
  static const success = '/success';
  static const enroll = '/enroll';
  static const enrollSuccess = '/enroll-success';
  static const ussd = '/ussd';

  static const _publiques = {splash, onboarding, auth, pin};
  static bool estPublique(String location) => _publiques.contains(location);
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      if (Routes.estPublique(loc)) return null;
      final connected = await SecureStorage.estConnecte();
      if (!connected) return Routes.auth;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: Routes.auth, builder: (context, state) => const AuthScreen()),
      GoRoute(path: Routes.pin, builder: (context, state) => const PinScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
          GoRoute(path: Routes.clients, builder: (context, state) => const ClientsScreen()),
          GoRoute(
            path: Routes.clientDetailPattern,
            builder: (context, state) =>
                ClientDetailScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(path: Routes.collecte, builder: (context, state) => const CollecteScreen()),
          GoRoute(path: Routes.missions, builder: (context, state) => const MissionsScreen()),
          GoRoute(path: Routes.finances, builder: (context, state) => const CommissionsScreen()),
          GoRoute(path: Routes.supervision, builder: (context, state) => const SupervisionScreen()),
          GoRoute(path: Routes.alertes, builder: (context, state) => const AlertsScreen()),
          GoRoute(path: Routes.profil, builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: Routes.scanner,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: QrScanScreen()),
      ),
      GoRoute(
        path: Routes.biometrie,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: BiometrieScreen()),
      ),
      GoRoute(
        path: Routes.otpWait,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: OtpWaitScreen()),
      ),
      GoRoute(
        path: Routes.success,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: SuccessScreen()),
      ),
      GoRoute(
        path: Routes.enroll,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: EnrollScreen()),
      ),
      GoRoute(
        path: Routes.enrollSuccess,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: EnrollSuccessScreen()),
      ),
      GoRoute(
        path: Routes.ussd,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: UssdGuideScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable\n${state.uri}')),
    ),
  );
});
