import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_skeleton.dart';
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
        title: const Text('Fiche terrain'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_outlined),
            onPressed: () {
              final fiche = ficheAsync.value;
              if (fiche == null) return;
              final code = fiche.codeQr ?? fiche.telephone;
              context.push(
                Routes.qrPapier,
                extra: {
                  'nom': fiche.nom,
                  'codeQr': code,
                  'identifiantTerrain': code,
                },
              );
            },
            tooltip: 'QR papier',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(ficheClientProvider(clientId)),
        child: ficheAsync.when(
          loading: () => const SingleChildScrollView(
            child: SkeletonFicheTerrain(),
          ),
          error: (e, _) => ListView(
            children: [Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(extraireMessageErreur(e)),
            ))],
          ),
        data: (fiche) {
          final couleur = [
            AppColors.info,
            AppColors.attention,
            AppColors.primary,
            const Color(0xFF7C3AED),
          ][fiche.nom.hashCode.abs() % 4];
          final regularite = fiche.score > 0
              ? '${(fiche.score * 1.1).clamp(0, 100).round()}%'
              : '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── En-tête client ──────────────────────────────────
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: couleur.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                Formatters.initiales(fiche.nom),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: couleur,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fiche.nom, style: AppTextStyles.titre2),
                                const SizedBox(height: 2),
                                Text(
                                  fiche.codeQr != null
                                      ? '${fiche.codeQr} · ${fiche.quartier ?? 'Terrain'}'
                                      : fiche.quartier ??
                                            Formatters.telephone(
                                              fiche.telephone,
                                            ),
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 6),
                                // Badge smartphone/SMS
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fiche.codeQr != null
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        fiche.codeQr != null
                                            ? Icons.smartphone
                                            : Icons.phone,
                                        size: 11,
                                        color: AppColors.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fiche.codeQr != null
                                            ? 'Sans smartphone'
                                            : 'Numéro GSM',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // KYC badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'KYC minimal',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.attention,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // 3 stats
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              valeur: fiche.soldeTotal > 0
                                  ? '${(fiche.soldeTotal / 1000).toStringAsFixed(0)}k'
                                  : '0',
                              label: 'Solde FCFA',
                              bgColor: AppColors.primaryLight,
                              txtColor: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: _StatBox(
                                valeur: '${fiche.score}',
                                label: 'Score /100',
                                bgColor: const Color(0xFFEFF6FF),
                                txtColor: AppColors.info,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatBox(
                              valeur: regularite,
                              label: 'Régularité',
                              bgColor: const Color(0xFFECFDF5),
                              txtColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      // Eligibilités
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (fiche.score >= 60)
                            _EligiBadge(
                              label: 'Micro-crédit ✓',
                              bg: AppColors.primaryLight,
                              txt: AppColors.primary,
                            ),
                          if (fiche.score >= 70)
                            _EligiBadge(
                              label: 'PADME ✓',
                              bg: const Color(0xFFF5F3FF),
                              txt: const Color(0xFF7C3AED),
                            ),
                          _EligiBadge(
                            label: _plafondCredit(fiche.score),
                            bg: const Color(0xFFF1F5F9),
                            txt: AppColors.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                // ── 6 boutons actions ────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionBtn(
                      label: 'Cotiser',
                      icon: Icons.add_circle_outline,
                      bgColor: AppColors.primary,
                      txtColor: Colors.white,
                      onTap: () =>
                          context.push(Routes.collecteAssistee, extra: fiche),
                    ),
                    _ActionBtn(
                      label: 'Retrait',
                      icon: Icons.account_balance_wallet_outlined,
                      bgColor: Colors.white,
                      txtColor: AppColors.texte,
                      bordered: true,
                      onTap: () =>
                          context.push(Routes.retraitAssistee, extra: fiche),
                    ),
                    _ActionBtn(
                      label: 'Tontines',
                      icon: Icons.savings_outlined,
                      bgColor: Colors.white,
                      txtColor: AppColors.texte,
                      bordered: true,
                      onTap: () =>
                          context.push(Routes.terrainWallet, extra: fiche),
                    ),
                    _ActionBtn(
                      label: 'Historique',
                      icon: Icons.receipt_long_outlined,
                      bgColor: Colors.white,
                      txtColor: AppColors.texte,
                      bordered: true,
                      onTap: () =>
                          context.push(Routes.historiqueClient, extra: fiche),
                    ),
                    _ActionBtn(
                      label: 'Score PADME',
                      icon: Icons.bar_chart,
                      bgColor: Colors.white,
                      txtColor: AppColors.texte,
                      bordered: true,
                      onTap: () =>
                          context.push(Routes.scorePadme, extra: fiche),
                    ),
                    _ActionBtn(
                      label: 'Micro-crédit',
                      icon: Icons.account_balance_outlined,
                      bgColor: Colors.white,
                      txtColor: AppColors.texte,
                      bordered: true,
                      onTap: () =>
                          context.push(Routes.microCredit, extra: fiche),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // ── Notifications client ─────────────────────────────
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notifications client',
                                style: AppTextStyles.titre3,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'Contenu masqué',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Demo notifications (type + heure seulement)
                      ...[
                        (
                          'Confirmation cotisation',
                          'Aujourd\'hui · 14:22',
                          Icons.check_circle_outline,
                          AppColors.primaryLight,
                          AppColors.primary,
                        ),
                        (
                          'Confirmation cotisation',
                          'Aujourd\'hui · 11:08',
                          Icons.check_circle_outline,
                          AppColors.primaryLight,
                          AppColors.primary,
                        ),
                        (
                          'Code de sécurité',
                          'Hier · 09:43',
                          Icons.lock_outline,
                          const Color(0xFFF1F5F9),
                          AppColors.muted,
                        ),
                      ].map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: n.$4,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(n.$3, size: 16, color: n.$5),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.$1,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.texte,
                                      ),
                                    ),
                                    Text(n.$2, style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Text(
                                  'Envoyé ✓',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Privacy notice
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Le collecteur voit uniquement le type et l\'heure d\'envoi. Le contenu des SMS (OTP, solde, PIN) reste privé entre TontineBénin et le client.',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                // ── Anti-fraude ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.attention,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Anti-fraude actif',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Retrait · Cotisation → OTP SMS obligatoire sur le téléphone du client. Le collecteur ne reçoit jamais l\'OTP.',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF78350F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                // ── Check-in GPS ─────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => _checkIn(context, ref, fiche.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.location_on_outlined, size: 18),
                  label: const Text(
                    'Check-in GPS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  String _plafondCredit(int score) {
    if (score >= 90) return 'Plafond 100 000 F';
    if (score >= 80) return 'Plafond 50 000 F';
    if (score >= 70) return 'Plafond 25 000 F';
    if (score >= 60) return 'Plafond 10 000 F';
    return 'Score insuffisant';
  }

  Future<void> _checkIn(
    BuildContext context,
    WidgetRef ref,
    String clientId,
  ) async {
    final pos = await LocationService.obtenirPosition();
    if (!context.mounted) return;
    if (pos == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GPS indisponible')));
      return;
    }
    try {
      await ref
          .read(clientsRepositoryProvider)
          .checkIn(
            clientId: clientId,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(extraireMessageErreur(e))));
      }
    }
  }
}

class _StatBox extends StatelessWidget {
  final String valeur;
  final String label;
  final Color bgColor;
  final Color txtColor;
  const _StatBox({
    required this.valeur,
    required this.label,
    required this.bgColor,
    required this.txtColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valeur,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: txtColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EligiBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color txt;
  const _EligiBadge({required this.label, required this.bg, required this.txt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: txt,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color txtColor;
  final bool bordered;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.txtColor,
    this.bordered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: bordered ? Border.all(color: AppColors.bordure) : null,
          boxShadow: bgColor == AppColors.primary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: txtColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
