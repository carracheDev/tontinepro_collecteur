import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../auth/presentation/providers/session_provider.dart';

/// Dashboard accueil — placeholder Phase 2 (KPIs + quick actions).
class HomeScreen extends ConsumerWidget {
  final String titre;
  final IconData icone;

  const HomeScreen({
    super.key,
    required this.titre,
    this.icone = Icons.dashboard_outlined,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nomAsync = ref.watch(sessionNomProvider);
    final roleAsync = ref.watch(sessionRoleProvider);
    final nom = nomAsync.value ?? 'Collecteur';
    final role = roleAsync.value;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2E14532D),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFFD1FAE5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nom,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (role != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                role.label,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(icone, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(titre, style: AppTextStyles.titre2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sousTitre(role),
                      style: AppTextStyles.corpsSecond,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.bordure),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.construction_outlined,
                            size: 48,
                            color: AppColors.muted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Phase 2 — écran en cours',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'KPIs, listes clients et collecte seront branchés sur l\'API backend.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sousTitre(RoleCollecteur? role) {
    if (role == RoleCollecteur.superviseur) {
      return 'Supervision de zone — pas d\'accès collecte ni scanner.';
    }
    if (role == RoleCollecteur.independant) {
      return 'Clients, collecte Mobile Money et finances.';
    }
    return 'Missions du jour, clients et collecte terrain.';
  }
}
