import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/biometrie_service.dart';
import '../../../../router/app_router.dart';

class BiometrieScreen extends StatefulWidget {
  const BiometrieScreen({super.key});

  @override
  State<BiometrieScreen> createState() => _BiometrieScreenState();
}

class _BiometrieScreenState extends State<BiometrieScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _authentifier() async {
    if (_enCours) return;
    setState(() => _enCours = true);
    final ok = await BiometrieService.authentifier(
      raison: 'Confirmez votre identité avant la collecte',
    );
    setState(() => _enCours = false);
    if (!mounted) return;
    if (ok) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      context.pushReplacement(Routes.collecteOtpWait, extra: extra);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biométrie refusée ou indisponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final nom = extra?['clientNom']?.toString() ?? 'Client';

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Collecte pour $nom',
              style: AppTextStyles.titre2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Empreinte ou reconnaissance faciale obligatoire',
              style: AppTextStyles.corpsSecond,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _enCours ? null : _authentifier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _enCours
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Scanner empreinte',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
