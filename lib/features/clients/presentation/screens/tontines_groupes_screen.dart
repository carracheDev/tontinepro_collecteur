import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../router/app_router.dart';
import '../../data/models/client_models.dart';
import '../../data/repositories/tontines_repository.dart';

final tontinesProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(tontinesRepositoryProvider).mesTontines();
});

class TontinesGroupesScreen extends ConsumerWidget {
  const TontinesGroupesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tontinesProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Tontines groupes'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _ouvrirCreation(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(tontinesProvider);
          await ref.read(tontinesProvider.future);
        },
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Erreur : $e', style: AppTextStyles.corpsSecond),
            ],
          ),
          data: (tontines) {
            if (tontines.isEmpty) {
              return ListView(
                children: [
                  EmptyStateWidget(
                    icone: Icons.groups,
                    titre: 'Aucun groupe',
                    sousTitre: 'Creez votre premier groupe de tontine.',
                    labelBouton: 'Creer un groupe',
                    onAction: () => _ouvrirCreation(context, ref),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: tontines.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _TontineGroupeCard(
                tontine: tontines[i],
                onCotiser: () => context.push(
                  Routes.collecteAssistee,
                  extra: _ficheDepuisTontine(tontines[i]),
                ),
                onQr: () => _ouvrirQrGroupe(context, tontines[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  FicheTerrain _ficheDepuisTontine(Map<String, dynamic> t) {
    final tontine = Map<String, dynamic>.from(t);
    tontine['montantJournalierFcfa'] ??= tontine['montantParMembre'];
    return FicheTerrain(
      id: t['id']?.toString() ?? '',
      nom: t['nom']?.toString() ?? 'Tontine groupe',
      telephone: '',
      soldeTotal: (t['soldeActuelFcfa'] as num?)?.toInt() ?? 0,
      score: 0,
      codeQr: t['codeInvitation']?.toString(),
      transactions: const [],
      tontines: [tontine],
    );
  }

  void _ouvrirCreation(BuildContext context, WidgetRef ref) {
    final nomCtrl = TextEditingController();
    final montantCtrl = TextEditingController();
    var membres = 4;
    var frequence = 'MENSUEL';
    var chargement = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.bordure,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Nouveau groupe', style: AppTextStyles.titre3),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nomCtrl,
                    style: AppTextStyles.corps,
                    decoration: const InputDecoration(
                      labelText: 'Nom du groupe',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: membres,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de membres',
                      border: OutlineInputBorder(),
                    ),
                    items: [4, 6, 8, 10, 12]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v membres'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => membres = v ?? membres),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: frequence,
                    decoration: const InputDecoration(
                      labelText: 'Frequence',
                      border: OutlineInputBorder(),
                    ),
                    items: ['MENSUEL', 'HEBDOMADAIRE', 'QUOTIDIEN']
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text(v)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => frequence = v ?? frequence),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: montantCtrl,
                    style: AppTextStyles.montantPetit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Montant par membre (FCFA)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: chargement
                          ? null
                          : () async {
                              final nom = nomCtrl.text.trim();
                              final montant =
                                  int.tryParse(montantCtrl.text.trim()) ?? 0;
                              if (nom.isEmpty || montant <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Renseignez le nom et le montant',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => chargement = true);
                              try {
                                await ref
                                    .read(tontinesRepositoryProvider)
                                    .creerGroupe({
                                  'nom': nom,
                                  'nombreMembres': membres,
                                  'frequence': frequence,
                                  'montantParMembre': montant,
                                });
                                if (!context.mounted) return;
                                Navigator.pop(sheetContext);
                                ref.invalidate(tontinesProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Groupe cree avec succes'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                setState(() => chargement = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur : $e')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: chargement
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'CREER LE GROUPE',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nomCtrl.dispose();
      montantCtrl.dispose();
    });
  }

  void _ouvrirQrGroupe(BuildContext context, Map<String, dynamic> t) {
    final code = t['codeInvitation']?.toString() ?? t['id']?.toString() ?? '';
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: code, size: 190, backgroundColor: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Code invitation : $code',
                style: AppTextStyles.titre3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Partagez ce QR pour inviter des membres',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TontineGroupeCard extends StatelessWidget {
  final Map<String, dynamic> tontine;
  final VoidCallback onCotiser;
  final VoidCallback onQr;

  const _TontineGroupeCard({
    required this.tontine,
    required this.onCotiser,
    required this.onQr,
  });

  @override
  Widget build(BuildContext context) {
    final statut = tontine['statut']?.toString().toUpperCase() ?? 'ACTIVE';
    final active = statut == 'ACTIVE';
    final tourActuel = (tontine['tourActuel'] as num?)?.toDouble() ?? 1;
    final nombreTours = (tontine['nombreTours'] as num?)?.toDouble() ?? 12;
    final progression = nombreTours <= 0 ? 0.0 : tourActuel / nombreTours;

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tontine['nom']?.toString() ?? 'Tontine groupe',
                      style: AppTextStyles.titre3,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(tontine['membres'] as List?)?.length ?? 0} membres · Tour ${(tontine['tourActuel'] as num?)?.toInt() ?? 1}/${(tontine['nombreTours'] as num?)?.toInt() ?? 12} · ${tontine['frequence'] ?? 'Mensuel'}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Badge(
                label: active ? 'ACTIVE' : 'SUSPENDUE',
                color: active ? AppColors.primary : AppColors.attention,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progression.clamp(0, 1),
            color: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _StatMini(
                  val:
                      '${((tontine['soldeActuelFcfa'] as num? ?? 0) ~/ 1000)}k F',
                  label: 'Caisse',
                ),
              ),
              Expanded(
                child: _StatMini(
                  val:
                      '${tontine['montantParMembre'] ?? tontine['montantJournalierFcfa'] ?? '—'} F',
                  label: 'Par membre',
                ),
              ),
              Expanded(
                child: _StatMini(
                  val: tontine['prochainBeneficiaire']?.toString() ?? '—',
                  label: 'Prochain tour',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCotiser,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Cotiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onQr,
                  icon: const Icon(Icons.qr_code_outlined, size: 18),
                  label: const Text('QR groupe'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String val;
  final String label;

  const _StatMini({required this.val, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          val,
          style: AppTextStyles.montantPetit.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
