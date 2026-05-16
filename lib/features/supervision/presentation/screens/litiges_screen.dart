import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/supervision_repository.dart';

final litigesSupervisionProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(supervisionRepositoryProvider).litigesEnCours();
});

class LitigesScreen extends ConsumerWidget {
  const LitigesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(litigesSupervisionProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Litiges'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(litigesSupervisionProvider.future),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: async.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Text(e.toString()),
                  data: (litiges) {
                    if (litiges.isEmpty) {
                      return const EmptyStateWidget(
                        icone: Icons.gavel_outlined,
                        titre: 'Aucun litige',
                        sousTitre: 'Tout est calme dans votre zone.',
                      );
                    }
                    return Column(
                      children: litiges.map((l) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l['motif']?.toString() ??
                                      l['type']?.toString() ??
                                      'Litige',
                                  style: AppTextStyles.titre3,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Statut : ${l['statut'] ?? 'EN_COURS'}',
                                  style: AppTextStyles.caption,
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
