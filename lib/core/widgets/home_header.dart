import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../router/app_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HomeHeader extends ConsumerWidget {
  final String sousTitre;
  const HomeHeader({super.key, required this.sousTitre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nom = ref.watch(sessionNomProvider).value ?? 'Collecteur';
    final role = ref.watch(sessionRoleProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
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
                      Text(
                        nom,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
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
              ),
              IconButton(
                onPressed: () => context.push(Routes.profil),
                icon: const Icon(Icons.person_outline, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(sousTitre, style: AppTextStyles.corpsSecond),
        ],
      ),
    );
  }
}
