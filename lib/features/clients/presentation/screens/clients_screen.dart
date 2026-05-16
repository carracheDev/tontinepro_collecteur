import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../router/app_router.dart';
import '../providers/clients_provider.dart';
import '../widgets/client_card.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(clientsDuJourProvider);
    final clientsAsync = ref.watch(clientsFiltresProvider);
    final filtre = ref.watch(filtreClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Enrôler',
            onPressed: () => context.push(Routes.enrolement),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(clientsDuJourProvider);
          await ref.read(clientsDuJourProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      ref.read(rechercheClientsProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Rechercher client, téléphone...',
                    hintStyle: AppTextStyles.caption,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.muted,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref
                                  .read(rechercheClientsProvider.notifier)
                                  .state = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.bordure),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.bordure),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _Chip(
                      label: 'Tous',
                      actif: filtre == FiltreClients.tous,
                      bgActif: AppColors.primaryLight,
                      txtActif: AppColors.primary,
                      onTap: () => ref
                          .read(filtreClientsProvider.notifier)
                          .state = FiltreClients.tous,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Éligibles crédit',
                      actif: filtre == FiltreClients.eligibleCredit,
                      bgActif: const Color(0xFFEFF6FF),
                      txtActif: AppColors.info,
                      onTap: () => ref
                          .read(filtreClientsProvider.notifier)
                          .state = FiltreClients.eligibleCredit,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'À relancer',
                      actif: filtre == FiltreClients.aRelancer,
                      bgActif: const Color(0xFFFFFBEB),
                      txtActif: AppColors.attention,
                      onTap: () => ref
                          .read(filtreClientsProvider.notifier)
                          .state = FiltreClients.aRelancer,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Non visités',
                      actif: filtre == FiltreClients.aVisiter,
                      bgActif: const Color(0xFFF1F5F9),
                      txtActif: AppColors.muted,
                      onTap: () => ref
                          .read(filtreClientsProvider.notifier)
                          .state = FiltreClients.aVisiter,
                    ),
                  ],
                ),
              ),
            ),

            // Enrôler button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(Routes.enrolement),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text(
                      'ENRÔLER CLIENT SANS SMARTPHONE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Récemment visités (horizontal)
            if (statsAsync.hasValue &&
                statsAsync.value!.clients.any((c) => c.dejaVisite)) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                  child: Text(
                    'RÉCEMMENT VISITÉS',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: statsAsync.value!.clients
                        .where((c) => c.dejaVisite)
                        .take(6)
                        .length,
                    itemBuilder: (_, i) {
                      final c = statsAsync.value!.clients
                          .where((c) => c.dejaVisite)
                          .elementAt(i);
                      final couleur = [
                        AppColors.info,
                        AppColors.attention,
                        AppColors.primary,
                        const Color(0xFF7C3AED),
                      ][c.nom.hashCode.abs() % 4];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () =>
                              context.push(Routes.clientDetail(c.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.bordure),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: couleur.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Formatters.initiales(c.nom),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: couleur,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.nom.split(' ').first,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.texte,
                                      ),
                                    ),
                                    Text(
                                      '${c.solde} F',
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // "Tous les clients" label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'TOUS LES CLIENTS',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // Client list
            clientsAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) => const SkeletonClientCard(),
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
                      titre: 'Aucun client trouvé',
                      sousTitre:
                          'Essayez un autre filtre ou enrôlez un nouveau client.',
                      labelBouton: 'Enrôler un client',
                      onAction: () => context.push(Routes.enrolement),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool actif;
  final Color bgActif;
  final Color txtActif;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.actif,
    required this.bgActif,
    required this.txtActif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? bgActif : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: actif ? bgActif : AppColors.bordure,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: actif ? txtActif : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
