import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/supervision_repository.dart';

final agentsPerformanceProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(supervisionRepositoryProvider).performanceCollecteurs();
});

class AgentsScreen extends ConsumerWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(agentsPerformanceProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Agents'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(agentsPerformanceProvider.future),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: async.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Text(e.toString()),
                  data: (agents) {
                    if (agents.isEmpty) {
                      return Text(
                        'Aucun agent dans votre zone',
                        style: AppTextStyles.corpsSecond,
                      );
                    }
                    return Column(
                      children: agents.map((a) {
                        final nom = a['nom']?.toString() ?? 'Agent';
                        final taux = a['tauxCollecte'] ?? a['performance'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    nom.isNotEmpty ? nom[0] : 'A',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nom, style: AppTextStyles.titre3),
                                      Text(
                                        a['role']?.toString() ?? 'AGENT',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  taux != null ? '$taux%' : '—',
                                  style: AppTextStyles.montantPetit,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
