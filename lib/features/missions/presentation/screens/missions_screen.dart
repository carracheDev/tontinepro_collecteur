import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../router/app_router.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../clients/presentation/providers/clients_provider.dart';
import '../../../clients/presentation/widgets/client_card.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientsDuJourProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Missions du jour'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        actions: [
          async.maybeWhen(
            data: (result) => IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () =>
                  context.push(Routes.carteTerrain, extra: result.clients),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(clientsDuJourProvider);
          await ref.read(clientsDuJourProvider.future);
        },
        child: async.when(
          loading: () => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SkeletonClientCard(),
                const SizedBox(height: 16),
                ...List.generate(4, (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: SkeletonClientCard(),
                )),
              ],
            ),
          ),
          error: (e, _) => EmptyStateWidget(
            icone: Icons.error_outline,
            titre: 'Impossible de charger',
            sousTitre: extraireMessageErreur(e),
            labelBouton: 'Réessayer',
            onAction: () => ref.invalidate(clientsDuJourProvider),
          ),
          data: (result) {
            final progression = result.stats.total == 0
                ? 0.0
                : result.stats.visites / result.stats.total;
            final primeEstimee = result.stats.visites * 500;
            final restants = result.stats.total - result.stats.visites;
            final pct = (progression * 100).round();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Missions du jour',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white60,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${result.stats.visites}',
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/${result.stats.total}',
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'visites effectuées',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '$pct%',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$restants restant${restants > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progression,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primaryVif,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Prime estimée : ${Formatters.montant(primeEstimee)}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: result.clients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = result.clients[i];
                        return Column(
                          children: [
                            ClientCard(
                              client: c,
                              onTap: () =>
                                  context.push(Routes.clientDetail(c.id)),
                            ),
                            if (!c.dejaVisite) ...[
                              const SizedBox(height: 6),
                              AppButton(
                                label: 'Check-in GPS',
                                variant: AppButtonVariant.outline,
                                onPressed: () => _checkIn(context, ref, c.id),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }

  Future<void> _checkIn(
    BuildContext context,
    WidgetRef ref,
    String clientId,
  ) async {
    final pos = await LocationService.obtenirPosition();
    if (pos == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activez le GPS pour le check-in')),
        );
      }
      return;
    }
    try {
      await ref.read(clientsRepositoryProvider).checkIn(
            clientId: clientId,
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
      ref.invalidate(clientsDuJourProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in validé ✓'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extraireMessageErreur(e))),
        );
      }
    }
  }
}
