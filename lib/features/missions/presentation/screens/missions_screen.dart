import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/home_header.dart';
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(clientsDuJourProvider);
            await ref.read(clientsDuJourProvider.future);
          },
          child: async.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => ListView(
              children: [
                const HomeHeader(sousTitre: 'Missions du jour'),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(extraireMessageErreur(e)),
                ),
              ],
            ),
            data: (result) {
              final progression = result.stats.total == 0
                  ? 0.0
                  : result.stats.visites / result.stats.total;
              final primeEstimee = result.stats.visites * 500;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      sousTitre:
                          '${result.stats.restantes} visite(s) restante(s) aujourd\'hui',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.bordure),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Progression du jour', style: AppTextStyles.titre3),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progression,
                                minHeight: 10,
                                backgroundColor: AppColors.primaryLight,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${result.stats.visites}/${result.stats.total} visites — Prime estimée ${primeEstimee} FCFA',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
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
