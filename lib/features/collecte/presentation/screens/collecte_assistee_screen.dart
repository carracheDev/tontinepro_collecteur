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

class CollecteAssisteeScreen extends ConsumerStatefulWidget {
  final FicheTerrain fiche;
  const CollecteAssisteeScreen({super.key, required this.fiche});

  @override
  ConsumerState<CollecteAssisteeScreen> createState() =>
      _CollecteAssisteeScreenState();
}

class _CollecteAssisteeScreenState
    extends ConsumerState<CollecteAssisteeScreen> {
  final _montantCtrl = TextEditingController();

  Map<String, dynamic>? _tontineSelectionnee;
  String? _tontineId;
  String _operateur = 'MTN_MONEY';
  int _montant = 0;
  bool _montantTouche = false;

  bool get _peutSoumettre => _montant > 0 && _tontineId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fiche.tontines.isEmpty) return;
      final t0 = widget.fiche.tontines.first;
      setState(() {
        _tontineSelectionnee = t0;
        _tontineId = t0['id']?.toString();
        _montant = (t0['montantJournalierFcfa'] as num?)?.toInt() ?? 0;
        _montantCtrl.text = _montant.toString();
      });
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
    final noms = tontines.map((t) => t['nom']?.toString() ?? '').toList();

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Cotisation assistée'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge + bandeau
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Client contrôle',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  'Le collecteur initie. Le client confirme lui-même sur Mobile Money.',
                  style: AppTextStyles.corpsSecond.copyWith(
                    color: const Color(0xFF166534),
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

              // Dropdown Tontine
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tontine',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tontineId,
                    isExpanded: true,
                    items: List.generate(
                      tontines.length,
                      (i) => DropdownMenuItem<String>(
                        value: tontines[i]['id']?.toString(),
                        child: Text(noms[i], style: AppTextStyles.corps),
                      ),
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      final tSel = tontines.firstWhere(
                        (t) => t['id']?.toString() == v,
                        orElse: () => tontines.first,
                      );
                      // ignore: parameter_assignments
                      _tontineSelectionnee = tSel;
                      setState(() {
                        _tontineId = v;
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
                        color: isSel ? Colors.white : AppColors.primary,
                      ),
                    ),
                    selectedColor: AppColors.primary,
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
                    items: [
                      DropdownMenuItem<String>(
                        value: 'MTN_MONEY',
                        child: Text('MTN Money', style: AppTextStyles.corps),
                      ),
                      DropdownMenuItem<String>(
                        value: 'MOOV_MONEY',
                        child: Text('Moov Money', style: AppTextStyles.corps),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CELTIIS_CASH',
                        child: Text('Celtiis Cash', style: AppTextStyles.corps),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _operateur = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton GPS
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
                icon: const Icon(Icons.location_on_outlined, size: 18),
                label: const Text(
                  'GPS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: const BorderSide(color: AppColors.info),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Bouton principal
              AppButton(
                label: 'DÉCLENCHER DEMANDE MOMO',
                onPressed: _peutSoumettre ? () async {
                  if (_tontineSelectionnee == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ce client n\'a pas encore de tontine. Créez-en une d\'abord.',
                        ),
                      ),
                    );
                    return;
                  }
                  final montant = _montant;
                  if (montant <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Montant invalide')),
                    );
                    return;
                  }

                  final dio = DioClient.instance;
                  final router = GoRouter.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final resp = await dio.post(
                      ApiEndpoints.initierCotisation,
                      data: {
                        'clientId': fiche.id,
                        'tontineId': _tontineSelectionnee!['id'],
                        'montant': montant,
                        'operateur': _operateur,
                      },
                    );

                    final operationId =
                        resp.donnees['operationId']?.toString() ??
                        resp.donnees['transactionId']?.toString() ??
                        resp.donnees['transaction']?['id']?.toString();
                    if (!mounted) return;
                    if (operationId == null) {
                      await HapticService.leger();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Paiement initié — attente confirmation'),
                        ),
                      );
                      return;
                    }
                    await HapticService.succes();
                    router.push(
                      Routes.collecteOtpWait,
                      extra: {
                        'operationId': operationId,
                        'clientNom': fiche.nom,
                        'type': 'cotisation',
                      },
                    );
                  } catch (e) {
                    await HapticService.erreur();
                    if (!mounted) return;
                    messenger.showSnackBar(
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
