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

class MicroCreditScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;

  const MicroCreditScreen({super.key, required this.fiche});

  @override
  ConsumerState<MicroCreditScreen> createState() => _MicroCreditScreenState();
}

class _MicroCreditScreenState extends ConsumerState<MicroCreditScreen> {
  // ignore: unused_field

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
      final max = _plafondMicroCredit(score);
      if (max > 0) {
        _montantCtrl.text = max.toString();
      }
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  int _plafondMicroCredit(int score) {
    if (score >= 90) return 100000;
    if (score >= 80) return 50000;
    if (score >= 70) return 25000;
    if (score >= 60) return 10000;
    return 0;
  }

  bool get eligible => score >= 60;

  @override
  Widget build(BuildContext context) {
    final max = _plafondMicroCredit(score);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: Text('Micro-crédit · ${widget.fiche.nom}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: eligible
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          'Le collecteur propose. Le client consent par SMS. Vous ne voyez jamais le contenu du SMS.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '$score',
                            style: AppTextStyles.montantGrand.copyWith(
                              fontSize: 44,
                              color: AppColors.texte,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Score /100', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          'Plafond micro-crédit : ${Formatters.montant(max)}',
                          style: AppTextStyles.titre3.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Montant (max = ${Formatters.montant(max)})',
                      style: AppTextStyles.titre3,
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _montantCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTextStyles.montantMoyen,
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        if (val > max) {
                          _montantCtrl.text = max.toString();
                          _montantCtrl.selection = TextSelection.collapsed(
                            offset: _montantCtrl.text.length,
                          );
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 14),
                    Text('Tontine (garantie)', style: AppTextStyles.titre3),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTontineId,

                      items: widget.fiche.tontines
                          .map(
                            (t) => DropdownMenuItem(
                              value: t['id']?.toString(),
                              child: Text(t['nom']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedTontineId = v;
                          selectedTontineNom = widget.fiche.tontines
                              .firstWhere(
                                (t) => t['id']?.toString() == v,
                              )['nom']
                              ?.toString();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final montant = int.tryParse(_montantCtrl.text) ?? 0;
                          if (montant <= 0 || selectedTontineId == null) return;
                          await _demanderCredit(
                            montant: montant,
                            tontineId: selectedTontineId!,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'PROPOSER LE CRÉDIT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  'Score insuffisant pour le micro-crédit (minimum 60/100)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.annuler,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }

  Future<void> _demanderCredit({
    required int montant,
    required String tontineId,
  }) async {
    final dio = DioClient.instance;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await dio.post(
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
            'SMS de consentement envoyé au client. En attente de sa réponse.',
          ),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(extraireMessageErreur(e))),
      );
    }
  }
}
