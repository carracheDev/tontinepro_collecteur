import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/client_models.dart';

final _creditsClientProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, clientId) async {
  final dio = DioClient.instance;
  final resp = await dio.get(
    '${ApiEndpoints.mesCredits}?clientId=$clientId',
  );
  final donnees = resp.data['donnees'];
  if (donnees is List) return donnees.cast<Map<String, dynamic>>();
  return [];
});

class MicroCreditScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;

  const MicroCreditScreen({super.key, required this.fiche});

  @override
  ConsumerState<MicroCreditScreen> createState() => _MicroCreditScreenState();
}

class _MicroCreditScreenState extends ConsumerState<MicroCreditScreen> {
  late final int score;
  final _montantCtrl = TextEditingController();
  String? selectedTontineId;
  String? selectedTontineNom;

  @override
  void initState() {
    super.initState();
    score = widget.fiche.score;
    if (widget.fiche.tontines.isNotEmpty) {
      selectedTontineId = widget.fiche.tontines.first['id']?.toString();
      selectedTontineNom = widget.fiche.tontines.first['nom']?.toString();
      final max = _plafond(score);
      if (max > 0) _montantCtrl.text = max.toString();
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  int _plafond(int s) {
    if (s >= 90) return 100000;
    if (s >= 80) return 50000;
    if (s >= 70) return 25000;
    if (s >= 60) return 10000;
    return 0;
  }

  bool get eligible => score >= 60;

  @override
  Widget build(BuildContext context) {
    final max = _plafond(score);
    final creditsAsync = ref.watch(_creditsClientProvider(widget.fiche.id));

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: Text('Micro-crédit · ${widget.fiche.nom}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        elevation: 0.5,
        shadowColor: const Color(0x14000000),
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async => ref.invalidate(_creditsClientProvider(widget.fiche.id)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Crédits en cours ──────────────────────────
              creditsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
                data: (credits) {
                  final actifs = credits.where((c) {
                    final s = c['statut']?.toString() ?? '';
                    return s == 'ACTIF' || s == 'EN_DEFAUT';
                  }).toList();
                  if (actifs.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Crédit en cours', style: AppTextStyles.titre3),
                      const SizedBox(height: 10),
                      ...actifs.map((c) => _CarteCreditActif(
                            credit: c,
                            clientId: widget.fiche.id,
                            onPreleve: () => ref.invalidate(
                                _creditsClientProvider(widget.fiche.id)),
                          )),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // ── Bandeau sécurité ──────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_outlined,
                        color: AppColors.info, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Le collecteur propose. Le client consent par SMS. '
                        'Vous ne voyez jamais le contenu du SMS.',
                        style:
                            AppTextStyles.caption.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Score + plafond ───────────────────────────
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: eligible
                              ? AppColors.secondaryLight
                              : AppColors.dangerLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: _nunitoStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: eligible
                                  ? AppColors.secondary
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score de crédit',
                                style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text(
                              eligible
                                  ? 'Plafond : ${Formatters.montant(max)}'
                                  : 'Score insuffisant (min. 60/100)',
                              style: AppTextStyles.sousTitre.copyWith(
                                color:
                                    eligible ? AppColors.texte : AppColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!eligible) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Le client doit avoir un score d\'au moins 60/100 pour accéder au micro-crédit.',
                    style:
                        AppTextStyles.corps.copyWith(color: AppColors.dangerDark),
                  ),
                ),
              ],

              if (eligible) ...[
                const SizedBox(height: 20),

                // ── Formulaire demande ─────────────────────
                Text('Montant du crédit (max ${Formatters.montant(max)})',
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _montantCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.montantMoyen,
                  decoration: InputDecoration(
                    suffixText: 'FCFA',
                    suffixStyle: AppTextStyles.label,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.bordureNeutre),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.secondary, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    final val = int.tryParse(v) ?? 0;
                    if (val > max) {
                      _montantCtrl.text = max.toString();
                      _montantCtrl.selection = TextSelection.collapsed(
                          offset: _montantCtrl.text.length);
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),

                Text('Tontine de garantie', style: AppTextStyles.label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedTontineId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.bordureNeutre),
                    ),
                  ),
                  items: widget.fiche.tontines
                      .map((t) => DropdownMenuItem(
                            value: t['id']?.toString(),
                            child: Text(t['nom']?.toString() ?? ''),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedTontineId = v;
                      selectedTontineNom = widget.fiche.tontines
                          .firstWhere((t) => t['id']?.toString() == v)['nom']
                          ?.toString();
                    });
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final montant = int.tryParse(_montantCtrl.text) ?? 0;
                      if (montant <= 0 || selectedTontineId == null) return;
                      await _proposerCredit(montant: montant);
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('PROPOSER LE CRÉDIT PAR SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _proposerCredit({required int montant}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance.post(
        '${ApiEndpoints.demanderMicroCredit}?clientId=${widget.fiche.id}',
        data: {
          'montantPrincipalFcfa': montant,
          'methodeConsentement': 'SMS',
          'telephone': widget.fiche.telephone,
        },
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'SMS de consentement envoyé au client. En attente de sa réponse.'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(extraireMessageErreur(e))));
    }
  }
}

TextStyle _nunitoStyle({double? fontSize, FontWeight? fontWeight, Color? color}) =>
    TextStyle(fontFamily: 'Nunito', fontSize: fontSize, fontWeight: fontWeight, color: color);

// ── Carte crédit actif avec Prélever maintenant ───────────
class _CarteCreditActif extends ConsumerStatefulWidget {
  final Map<String, dynamic> credit;
  final String clientId;
  final VoidCallback onPreleve;

  const _CarteCreditActif({
    required this.credit,
    required this.clientId,
    required this.onPreleve,
  });

  @override
  ConsumerState<_CarteCreditActif> createState() => _CarteCreditActifState();
}

class _CarteCreditActifState extends ConsumerState<_CarteCreditActif> {
  bool _loading = false;

  bool get _enDefaut =>
      widget.credit['statut']?.toString() == 'EN_DEFAUT';

  @override
  Widget build(BuildContext context) {
    final c = widget.credit;
    final statut = c['statut']?.toString() ?? '';
    final montantRestant = (c['montantRestantFcfa'] as num?)?.toInt() ?? 0;
    final paiementJournalier =
        (c['paiementJournalierFcfa'] as num?)?.toInt() ?? 0;
    final creditId = c['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _enDefaut
            ? AppColors.dangerLight
            : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _enDefaut
              ? AppColors.danger.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _enDefaut
                    ? Icons.warning_amber_rounded
                    : Icons.account_balance_wallet_outlined,
                color: _enDefaut ? AppColors.danger : AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _enDefaut ? 'CRÉDIT EN DÉFAUT' : 'Crédit actif',
                  style: AppTextStyles.label.copyWith(
                    color:
                        _enDefaut ? AppColors.dangerDark : AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _enDefaut ? AppColors.danger : AppColors.secondary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  statut,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCredit(
                  label: 'Restant dû',
                  valeur: Formatters.montant(montantRestant),
                ),
              ),
              Expanded(
                child: _InfoCredit(
                  label: 'Paiement/jour',
                  valeur: Formatters.montant(paiementJournalier),
                ),
              ),
            ],
          ),
          if (_enDefaut) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : () => _preleverMaintenant(creditId),
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.payment_outlined, size: 18),
                label: Text(
                  _loading ? 'Envoi en cours...' : 'PRÉLEVER MAINTENANT',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.danger.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _preleverMaintenant(String creditId) async {
    if (creditId.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance
          .post(ApiEndpoints.preleverMaintenant(creditId));
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Demande Mobile Money envoyée au client. Il doit accepter sur son téléphone.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      widget.onPreleve();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(extraireMessageErreur(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _InfoCredit extends StatelessWidget {
  final String label;
  final String valeur;

  const _InfoCredit({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          valeur,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
