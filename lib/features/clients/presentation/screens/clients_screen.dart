import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../../router/app_router.dart';
import '../providers/clients_provider.dart';
import '../widgets/client_card.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(clientsDuJourProvider);
    final clientsAsync = ref.watch(clientsFiltresProvider);
    final filtre = ref.watch(filtreClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(clientsDuJourProvider);
            await ref.read(clientsDuJourProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  sousTitre: statsAsync.maybeWhen(
                    data: (d) =>
                        '${d.stats.total} clients — ${d.stats.visites} visité(s)',
                    orElse: () => 'Votre portefeuille clients',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      _ChipFiltre(
                        label: 'Tous',
                        actif: filtre == FiltreClients.tous,
                        onTap: () => ref.read(filtreClientsProvider.notifier).state =
                            FiltreClients.tous,
                      ),
                      const SizedBox(width: 8),
                      _ChipFiltre(
                        label: 'À visiter',
                        actif: filtre == FiltreClients.aVisiter,
                        onTap: () => ref.read(filtreClientsProvider.notifier).state =
                            FiltreClients.aVisiter,
                      ),
                      const SizedBox(width: 8),
                      _ChipFiltre(
                        label: 'Visités',
                        actif: filtre == FiltreClients.visites,
                        onTap: () => ref.read(filtreClientsProvider.notifier).state =
                            FiltreClients.visites,
                      ),
                    ],
                  ),
                ),
              ),
              if (statsAsync.hasValue &&
                  statsAsync.value!.clients.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 108,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: statsAsync.value!.clients
                          .where((c) => !c.dejaVisite)
                          .take(8)
                          .length,
                      itemBuilder: (_, i) {
                        final c = statsAsync.value!.clients
                            .where((c) => !c.dejaVisite)
                            .elementAt(i);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => context.push(Routes.clientDetail(c.id)),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    c.nom.isNotEmpty ? c.nom[0] : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    c.nom.split(' ').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              clientsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: EmptyStateWidget(
                    icone: Icons.error_outline,
                    titre: 'Erreur de chargement',
                    sousTitre: e.toString(),
                    labelBouton: 'Réessayer',
                    onAction: () => ref.invalidate(clientsDuJourProvider),
                  ),
                ),
                data: (clients) {
                  if (clients.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        icone: Icons.people_outline,
                        titre: 'Aucun client',
                        sousTitre: 'Enrôlez un client ou modifiez le filtre.',
                        labelBouton: 'Enrôler',
                        onAction: () => context.push(Routes.enrolement),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: clients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => ClientCard(
                        client: clients[i],
                        onTap: () =>
                            context.push(Routes.clientDetail(clients[i].id)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.enrolement),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Enrôler',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ChipFiltre extends StatelessWidget {
  final String label;
  final bool actif;
  final VoidCallback onTap;

  const _ChipFiltre({
    required this.label,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: actif ? AppColors.primary : AppColors.bordure,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: actif ? Colors.white : AppColors.texteSecond,
          ),
        ),
      ),
    );
  }
}
