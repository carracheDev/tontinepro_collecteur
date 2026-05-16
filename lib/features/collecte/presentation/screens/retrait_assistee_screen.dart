import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/app_router.dart';
import '../../../clients/data/models/client_models.dart';

class RetraitAssisteeScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;
  const RetraitAssisteeScreen({super.key, required this.fiche});

  @override
  ConsumerState<RetraitAssisteeScreen> createState() =>
      _RetraitAssisteeScreenState();
}

class _RetraitAssisteeScreenState extends ConsumerState<RetraitAssisteeScreen> {
  final _montantCtrl = TextEditingController();
  String? _tontineId;
  Map<String, dynamic>? _tontineSelectionnee;
  String _operateur = 'MTN_MONEY';
  int _montant = 0;
  bool _montantTouche = false;

  bool get _peutSoumettre => _montant > 0 && _tontineId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fiche.tontines.isNotEmpty) {
        final t0 = widget.fiche.tontines.first;
        setState(() {
          _tontineSelectionnee = t0;
          _tontineId = t0['id']?.toString();
          _montant = (t0['montantJournalierFcfa'] as num?)?.toInt() ?? 0;
          _montantCtrl.text = _montant.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fiche = widget.fiche;
    final tontines = fiche.tontines;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Retrait assisté'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bandeau orange
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  'OTP envoyé au téléphone du client. Il valide lui-même. Le collecteur ne reçoit jamais l\'OTP.',
                  style: AppTextStyles.corpsSecond.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nom client non éditable
              AbsorbPointer(
                child: Opacity(
                  opacity: 0.7,
                  child: AppTextField(
                    label: 'Client',
                    controller: TextEditingController(text: fiche.nom),
                    readOnly: true,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dropdown tontine
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tontine',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tontineId,
                    isExpanded: true,
                    items: tontines
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t['id']?.toString(),
                            child: Text(
                              t['nom']?.toString() ?? '',
                              style: AppTextStyles.corps,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final tSel = tontines.firstWhere(
                        (t) => t['id']?.toString() == v,
                        orElse: () => tontines.first,
                      );
                      setState(() {
                        _tontineId = v;
                        _tontineSelectionnee = tSel;
                        _montant =
                            (tSel['montantJournalierFcfa'] as num?)?.toInt() ??
                            0;
                        _montantCtrl.text = _montant.toString();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Chips montant rapide
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [500, 1000, 2500, 5000].map((m) {
                  final isSel = _montant == m;
                  return ChoiceChip(
                    label: Text(
                      Formatters.montant(m),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSel ? Colors.white : AppColors.attention,
                      ),
                    ),
                    selectedColor: AppColors.attention,
                    backgroundColor: Colors.white,
                    selected: isSel,
                    onSelected: (_) {
                      setState(() {
                        _montant = m;
                        _montantCtrl.text = m.toString();
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Champ montant FCFA
              AppTextField(
                label: 'Montant (FCFA)',
                controller: _montantCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  setState(() {
                    _montant = int.tryParse(v) ?? 0;
                    _montantTouche = true;
                  });
                },
              ),
              if (_montantTouche && _montant <= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Entrez un montant supérieur à 0',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.annuler,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Dropdown opérateur
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Opérateur',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _operateur,
                    isExpanded: true,
                    items:
                        const [
                              MapEntry('MTN_MONEY', 'MTN Money'),
                              MapEntry('MOOV_MONEY', 'Moov Money'),
                              MapEntry('CELTIIS_CASH', 'Celtiis Cash'),
                            ]
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(
                                  e.value,
                                  style: AppTextStyles.corps,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _operateur = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // GPS button
              OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final pos = await LocationService.obtenirPosition();
                  if (!mounted) return;
                  if (pos == null) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('GPS indisponible')),
                    );
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(content: Text('GPS enregistré ✓')),
                  );
                },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text(
                  'GPS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.attention,
                  side: const BorderSide(color: AppColors.attention),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Card orange en bas
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.attention.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.attention),
                ),
                child: Text(
                  "Anti-fraude — Toute tentative d'intercepter l'OTP du client est un délit.",
                  style: AppTextStyles.corpsSecond.copyWith(
                    color: AppColors.attention,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Main button
              AppButton(
                label: 'DÉCLENCHER DEMANDE RETRAIT',
                variant: AppButtonVariant.attention,
                onPressed: _peutSoumettre ? () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.attention),
                          SizedBox(width: 8),
                          Text('Confirmer le retrait',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              )),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client : ${fiche.nom}',
                              style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('Montant : ${Formatters.montant(_montant)}',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.attention,
                              )),
                          const SizedBox(height: 6),
                          Text('Opérateur : $_operateur',
                              style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 13)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.attention.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Un OTP sera envoyé au client. Il valide lui-même.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.attention,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Annuler',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.texteSecond)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.attention,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Confirmer',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true || !mounted) return;

                  final dio = DioClient.instance;

                  try {
                    final resp = await dio.post(
                      ApiEndpoints.initierRetrait,
                      data: {
                        'clientId': fiche.id,
                        'tontineId': _tontineSelectionnee!['id'],
                        'montant': _montant,
                        'operateur': _operateur,
                      },
                    );

                    final operationId =
                        resp.donnees['operationId']?.toString() ??
                        resp.donnees['operation']?['id']?.toString();
                    final router = GoRouter.of(context);
                    await HapticService.succes();
                    if (!mounted) return;

                    router.push(
                      Routes.collecteOtpWait,
                      extra: {
                        'operationId': operationId,
                        'clientNom': fiche.nom,
                        'type': 'retrait',
                        'clientId': fiche.id,
                        'montant': _montant,
                        'operateur': _operateur,
                        'tontineId': _tontineSelectionnee!['id'],
                      },
                    );
                  } catch (e) {
                    await HapticService.erreur();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(extraireMessageErreur(e))),
                    );
                  }
                } : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
