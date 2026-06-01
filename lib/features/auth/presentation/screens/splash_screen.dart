import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    _naviguer();
  }

  Future<void> _naviguer() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final connecte = await SecureStorage.estConnecte();
    if (!mounted) return;

    if (connecte) {
      final role =
          RoleCollecteur.depuisApi(await SecureStorage.lireUserRole());
      if (!mounted) return;
      context.go(routeAccueilPourRole(role));
      return;
    }

    final vu = await SecureStorage.onboardingVu();
    if (!mounted) return;
    context.go(vu ? Routes.auth : Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_tontinepro.png',
              width: 128,
              height: 128,
              errorBuilder: (_, _, _) => const Icon(
                Icons.savings_rounded,
                size: 80,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'TontinePro Collecteur',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Application terrain multi-rôles',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
