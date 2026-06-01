import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/client_models.dart';

class TerrainWalletScreen extends StatefulWidget {
  final FicheTerrain fiche;
  const TerrainWalletScreen({super.key, required this.fiche});

  @override
  State<TerrainWalletScreen> createState() => _TerrainWalletScreenState();
}

class _TerrainWalletScreenState extends State<TerrainWalletScreen> {
  List<Map<String, dynamic>> _tontines = [];

  @override
  void initState() {
    super.initState();
    _tontines = List.from(widget.fiche.tontines);
  }

  String _statutLabel(String? s) => switch (s) {
        'ACTIVE' => 'Active',
        'CREATION' => 'En création',
        'SUSPENDUE' => 'Suspendue',
        'TERMINEE' => 'Terminée',
        _ => s ?? '—',
      };

  Color _statutColor(String? s) => switch (s) {
        'ACTIVE' => AppColors.primary,
        'CREATION' => AppColors.attention,
        'SUSPENDUE' => AppColors.annuler,
        _ => AppColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    final soldeTotal = _tontines.fold<int>(
      0,
      (s, t) => s + ((t['soldeActuelFcfa'] as num?)?.toInt() ?? 0),
    );

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: Text('Tontines · ${widget.fiche.nom}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Solde total
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Épargne totale',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                  Formatters.montant(soldeTotal),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_tontines.length} tontine(s)',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bouton créer
            AppButton(
              label: '+ NOUVELLE TONTINE',
              onPressed: () => _ouvrirCreation(context),
            ),

            const SizedBox(height: 16),

            if (_tontines.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 40,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune tontine.\nCréez la première pour ce client.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.corpsSecond,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_tontines.map((t) {
                final nom = t['nom']?.toString() ?? 'Tontine';
                final solde = (t['soldeActuelFcfa'] as num?)?.toInt() ?? 0;
                final montant =
                    (t['montantJournalierFcfa'] as num?)?.toInt() ?? 0;
                final statut = t['statut']?.toString();
                final type = t['type']?.toString() ?? 'PERSONNELLE';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nom,
                                  style: AppTextStyles.titre3.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _statutColor(
                                    statut,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  _statutLabel(statut),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _statutColor(statut),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _InfoChip(
                                label: _typeLabel(type),
                                icon: _typeIcon(type),
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                label: '$montant F/jour',
                                icon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Solde actuel',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                  Formatters.montant(solde),
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'GROUPE' => 'Groupe',
        'PROJET' => 'Projet',
        _ => 'Personnelle',
      };

  IconData _typeIcon(String type) => switch (type) {
        'GROUPE' => Icons.group_outlined,
        'PROJET' => Icons.flag_outlined,
        _ => Icons.person_outline,
      };

  void _ouvrirCreation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreerTontineSheet(
        clientId: widget.fiche.id,
        onCreee: (t) => setState(() => _tontines.add(t)),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fond,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordure),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet création tontine ──────────────────────────
class _CreerTontineSheet extends StatefulWidget {
  final String clientId;
  final void Function(Map<String, dynamic>) onCreee;
  const _CreerTontineSheet({
    required this.clientId,
    required this.onCreee,
  });

  @override
  State<_CreerTontineSheet> createState() => _CreerTontineSheetState();
}

class _CreerTontineSheetState extends State<_CreerTontineSheet> {
  final _nomCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  String _type = 'PERSONNELLE';
  String _politique = 'FLEXIBLE';
  bool _loading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _montantCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    final nom = _nomCtrl.text.trim();
    final montant = int.tryParse(_montantCtrl.text) ?? 0;
    if (nom.isEmpty || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom et montant obligatoires')),
      );
      return;
    }

    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final resp = await DioClient.instance.post(
        '/tontines',
        data: {
          'nom': nom,
          'type': _type,
          'montantJournalierFcfa': montant,
          'politiqueRetrait': _politique,
          'clientId': widget.clientId,
        },
      );
      final raw = resp.donnees;
      final tontine = (raw['tontine'] as Map<String, dynamic>?) ?? raw;
      widget.onCreee(tontine);
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tontine créée ✓'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      messenger.showSnackBar(
        SnackBar(content: Text(extraireMessageErreur(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.bordure,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nouvelle tontine',
                style: AppTextStyles.titre2.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              // Type de tontine
              Text('Type de tontine', style: AppTextStyles.titre3),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeChip(
                    label: 'Personnelle',
                    icon: Icons.person_outline,
                    selected: _type == 'PERSONNELLE',
                    onTap: () => setState(() => _type = 'PERSONNELLE'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Groupe',
                    icon: Icons.group_outlined,
                    selected: _type == 'GROUPE',
                    onTap: () => setState(() => _type = 'GROUPE'),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Projet',
                    icon: Icons.flag_outlined,
                    selected: _type == 'PROJET',
                    onTap: () => setState(() => _type = 'PROJET'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nom
              TextField(
                controller: _nomCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom de la tontine',
                  hintText: 'ex: Épargne maison',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Montant journalier
              TextField(
                controller: _montantCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Montant journalier (FCFA)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Montants rapides
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [500, 1000, 2500, 5000].map((m) {
                  final sel = _montantCtrl.text == m.toString();
                  return ChoiceChip(
                    label: Text(
                      '$m F',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: sel ? Colors.white : AppColors.primary,
                      ),
                    ),
                    selected: sel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.primaryLight,
                    onSelected: (_) => setState(
                      () => _montantCtrl.text = m.toString(),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Politique de retrait
              Text('Politique de retrait', style: AppTextStyles.titre3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _politique,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'FLEXIBLE',
                    child: Text('Flexible — retrait libre'),
                  ),
                  DropdownMenuItem(
                    value: 'PROGRAMME',
                    child: Text('Programmé — date de déblocage'),
                  ),
                  DropdownMenuItem(
                    value: 'BLOQUE',
                    child: Text('Bloqué — jusqu\'à objectif atteint'),
                  ),
                ],
                onChanged: (v) => setState(() => _politique = v!),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _creer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'CRÉER LA TONTINE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.bordure,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
