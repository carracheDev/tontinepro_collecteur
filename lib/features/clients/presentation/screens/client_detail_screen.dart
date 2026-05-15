import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/clients_repository.dart';
import '../providers/clients_provider.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(ficheClientProvider(clientId));

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Fiche client'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ficheAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(extraireMessageErreur(e))),
        data: (fiche) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        Formatters.initiales(fiche.nom),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(fiche.nom, style: AppTextStyles.titre2),
                    Text(
                      Formatters.telephone(fiche.telephone),
                      style: AppTextStyles.corpsSecond,
                    ),
                    if (fiche.quartier != null) ...[
                      const SizedBox(height: 4),
                      Text(fiche.quartier!, style: AppTextStyles.caption),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCol(
                          label: 'Solde',
                          valeur: Formatters.montant(fiche.soldeTotal),
                        ),
                        _StatCol(
                          label: 'Score',
                          valeur: '${fiche.score}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Collecter',
                onPressed: () => context.push(
                  Routes.collecte,
                  extra: {
                    'clientId': fiche.id,
                    'clientNom': fiche.nom,
                    'tontineId': fiche.tontines.isNotEmpty
                        ? fiche.tontines.first['id']
                        : null,
                  },
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final lien = await ref
                        .read(clientsRepositoryProvider)
                        .lienWhatsApp(fiche.id);
                    final uri = Uri.parse(lien);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(extraireMessageErreur(e))),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat, color: AppColors.primary),
                label: const Text('WhatsApp'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final pos = await LocationService.obtenirPosition();
                  if (pos == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('GPS indisponible'),
                        ),
                      );
                    }
                    return;
                  }
                  try {
                    await ref.read(clientsRepositoryProvider).checkIn(
                          clientId: fiche.id,
                          latitude: pos.latitude,
                          longitude: pos.longitude,
                        );
                    ref.invalidate(clientsDuJourProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check-in enregistré ✓'),
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
                },
                icon: const Icon(Icons.location_on, color: AppColors.info),
                label: const Text('Check-in GPS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String valeur;
  const _StatCol({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(valeur, style: AppTextStyles.montantPetit),
      ],
    );
  }
}
