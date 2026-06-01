import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';
import '../../../clients/presentation/providers/clients_provider.dart';
import '../providers/collecte_provider.dart';

class CollecteScreen extends ConsumerStatefulWidget {
  const CollecteScreen({super.key});

  @override
  ConsumerState<CollecteScreen> createState() => _CollecteScreenState();
}

class _CollecteScreenState extends ConsumerState<CollecteScreen> {
  final _montantCtrl = TextEditingController();

  static const _montantsRapides = [100, 500, 1000, 2000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      ref.read(collecteFormProvider.notifier).initialiser(extra);
      final m = extra?['montant'];
      if (m != null) {
        _montantCtrl.text = m.toString();
        ref.read(collecteFormProvider.notifier).setMontant((m as num).toInt());
      }
    });
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  void _choisirMontant(int montant) {
    _montantCtrl.text = montant.toString();
    ref.read(collecteFormProvider.notifier).setMontant(montant);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(collecteFormProvider);
    final clientsAsync = ref.watch(clientsDuJourProvider);
    final montantActuel = form.montant;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar avec gradient ───────────────────────
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHero),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collecte terrain',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            Formatters.dateLongue(DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFFD1FAE5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Sélection client ────────────────────
                  _SectionCard(
                    titre: 'Client',
                    icone: Icons.person_outline,
                    child: form.clientNom != null
                        ? _ClientSelectionne(nom: form.clientNom!)
                        : clientsAsync.when(
                            data: (data) => _DropdownClient(
                              clients: data.clients,
                              onSelect: (id, nom) => ref
                                  .read(collecteFormProvider.notifier)
                                  .setClient(id, nom),
                            ),
                            loading: () => const _SkeletonDropdown(),
                            error: (_, _) => Text(
                              'Impossible de charger les clients',
                              style: AppTextStyles.caption,
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ─── Montant ────────────────────────────
                  _SectionCard(
                    titre: 'Montant de la collecte',
                    icone: Icons.account_balance_wallet_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Montants rapides
                        Text(
                          'Montants fréquents',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.texteSecond,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _montantsRapides.map((m) {
                            final actif = montantActuel == m;
                            return GestureDetector(
                              onTap: () => _choisirMontant(m),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: actif
                                      ? AppColors.primary
                                      : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: actif
                                        ? AppColors.primary
                                        : AppColors.bordure,
                                  ),
                                ),
                                child: Text(
                                  '${Formatters.montantCourt(m)} F',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: actif
                                        ? Colors.white
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        // Champ montant personnalisé
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.fond,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: montantActuel > 0
                                  ? AppColors.primary
                                  : AppColors.bordureNeutre,
                              width: montantActuel > 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _montantCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (v) {
                                    final val = int.tryParse(v) ?? 0;
                                    ref
                                        .read(collecteFormProvider.notifier)
                                        .setMontant(val);
                                    setState(() {});
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.texte,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Autre montant...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'FCFA',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Preview montant si > 0
                        if (montantActuel > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.montant(montantActuel),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Commission : ${Formatters.montant((montantActuel * 0.03).round())}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─── Opérateur ──────────────────────────
                  _SectionCard(
                    titre: 'Opérateur Mobile Money',
                    icone: Icons.phone_android_outlined,
                    child: Row(
                      children: [
                        _OperateurBtn(
                          label: 'MTN',
                          couleur: const Color(0xFFD97706),
                          actif: form.operateur == 'MTN',
                          onTap: () => ref
                              .read(collecteFormProvider.notifier)
                              .setOperateur('MTN'),
                        ),
                        const SizedBox(width: 10),
                        _OperateurBtn(
                          label: 'Moov',
                          couleur: AppColors.info,
                          actif: form.operateur == 'MOOV',
                          onTap: () => ref
                              .read(collecteFormProvider.notifier)
                              .setOperateur('MOOV'),
                        ),
                        const SizedBox(width: 10),
                        _OperateurBtn(
                          label: 'Celtiis',
                          couleur: const Color(0xFF7C3AED),
                          actif: form.operateur == 'CELTIIS',
                          onTap: () => ref
                              .read(collecteFormProvider.notifier)
                              .setOperateur('CELTIIS'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Bouton continuer ───────────────────
                  _BoutonContinuer(
                    actif: form.clientId != null && form.montant >= 100,
                    montant: form.montant,
                    onPressed: () => context.push(
                      Routes.collecteBiometrie,
                      extra: {
                        'clientId': form.clientId,
                        'clientNom': form.clientNom,
                        'tontineId': form.tontineId,
                        'montant': form.montant,
                        'operateur': form.operateur,
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte section ────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String titre;
  final IconData icone;
  final Widget child;

  const _SectionCard({
    required this.titre,
    required this.icone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
        boxShadow: AppColors.shadowNiveau1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icone, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                titre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.texte,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Client sélectionné (depuis extra) ───────────────────────
class _ClientSelectionne extends StatelessWidget {
  final String nom;
  const _ClientSelectionne({required this.nom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                Formatters.initiales(nom),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.texte,
                  ),
                ),
                Text('Client lié par QR', style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.link_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}

// ── Dropdown client ──────────────────────────────────────────
class _DropdownClient extends StatelessWidget {
  final List<dynamic> clients;
  final void Function(String id, String nom) onSelect;

  const _DropdownClient({required this.clients, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Choisir un client...',
        hintStyle: AppTextStyles.caption,
        prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
        filled: true,
        fillColor: AppColors.fond,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bordure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bordure),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: clients
          .map(
            (c) => DropdownMenuItem<String>(
              value: c.id as String,
              child: Text(
                c.nom as String,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texte,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (id) {
        if (id == null) return;
        final c = clients.firstWhere((x) => x.id == id);
        onSelect(id, c.nom as String);
      },
    );
  }
}

// ── Skeleton dropdown ────────────────────────────────────────
class _SkeletonDropdown extends StatelessWidget {
  const _SkeletonDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordure),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ── Bouton opérateur ─────────────────────────────────────────
class _OperateurBtn extends StatelessWidget {
  final String label;
  final Color couleur;
  final bool actif;
  final VoidCallback onTap;

  const _OperateurBtn({
    required this.label,
    required this.couleur,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: actif ? couleur : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: actif ? couleur : AppColors.bordureNeutre,
              width: actif ? 2 : 1,
            ),
            boxShadow: actif
                ? [
                    BoxShadow(
                      color: couleur.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                Icons.phone_android_rounded,
                color: actif ? Colors.white : couleur,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: actif ? Colors.white : couleur,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouton continuer ─────────────────────────────────────────
class _BoutonContinuer extends StatelessWidget {
  final bool actif;
  final int montant;
  final VoidCallback onPressed;

  const _BoutonContinuer({
    required this.actif,
    required this.montant,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: actif ? AppColors.gradientPrimary : null,
        color: actif ? null : AppColors.muted,
        borderRadius: BorderRadius.circular(16),
        boxShadow: actif
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: actif ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continuer — Vérification biométrique',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (actif && montant > 0)
                      Text(
                        Formatters.montant(montant),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD1FAE5),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
