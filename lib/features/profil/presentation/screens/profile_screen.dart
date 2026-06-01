import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/biometrie_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../data/repositories/profil_repository.dart';

final profilCompletProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(profilRepositoryProvider).profil();
});

final monQrProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(profilRepositoryProvider).monQrCode();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(profilCompletProvider);
    final nomSecure = ref.watch(sessionNomProvider).value ?? '';
    final nom = profilAsync.value?['nom']?.toString() ?? nomSecure;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.fond,
        body: CustomScrollView(
          slivers: [
            // ─── Hero header ───────────────────────────────
            SliverToBoxAdapter(
              child: _ProfilHero(nom: nom, profilAsync: profilAsync),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats du collecteur
                  profilAsync.when(
                    data: (p) => _StatsRow(profil: p),
                    loading: () => const _StatsSkeleton(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // QR Code
                  _QrCard(ref: ref),
                  const SizedBox(height: 14),

                  // Biométrie
                  _CarteParametre(
                    child: const _BiometrieToggle(),
                  ),
                  const SizedBox(height: 14),

                  // Paramètres
                  _CarteParametre(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Paramètres',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texte,
                        ),
                      ),
                      subtitle: Text(
                        'Préférences, sécurité',
                        style: AppTextStyles.caption,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                      onTap: () => context.push(Routes.parametres),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Déconnexion
                  _BoutonDeconnexion(ref: ref),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────
class _ProfilHero extends StatelessWidget {
  final String nom;
  final AsyncValue<Map<String, dynamic>> profilAsync;

  const _ProfilHero({required this.nom, required this.profilAsync});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.gradientHero,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 28),
      child: Column(
        children: [
          // Top row: back + settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              const Text(
                'Mon profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
            ),
            child: Center(
              child: Text(
                Formatters.initiales(nom),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nom
          Text(
            profilAsync.value?['nom']?.toString() ?? nom,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Téléphone
          profilAsync.when(
            data: (p) => Text(
              Formatters.telephone(p['telephone']?.toString() ?? ''),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFFD1FAE5),
              ),
            ),
            loading: () => const SizedBox(height: 18),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),

          // Badge rôle + KYC
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroPill(
                label: profilAsync.value?['role']?.toString() ?? 'COLLECTEUR',
                color: Colors.white.withValues(alpha: 0.18),
              ),
              const SizedBox(width: 8),
              _HeroPill(
                label: 'Compte ACTIF',
                color: const Color(0x2286EFAC),
                textColor: const Color(0xFF86EFAC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _HeroPill({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> profil;
  const _StatsRow({required this.profil});

  @override
  Widget build(BuildContext context) {
    final nbClients = profil['_count']?['clients'] ?? profil['nbClients'] ?? 0;
    final badge = profil['badges'] is List && (profil['badges'] as List).isNotEmpty
        ? (profil['badges'] as List).first['niveau']?.toString()
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
        boxShadow: AppColors.shadowNiveau1,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              valeur: nbClients.toString(),
              label: 'Clients',
              icon: Icons.people_outline,
              couleur: AppColors.primary,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              valeur: badge ?? 'Aucun',
              label: 'Badge',
              icon: Icons.workspace_premium_outlined,
              couleur: const Color(0xFFD97706),
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              valeur: profil['kycVerifie'] == true ? 'Vérifié' : 'En attente',
              label: 'KYC',
              icon: Icons.verified_outlined,
              couleur: profil['kycVerifie'] == true
                  ? AppColors.primary
                  : AppColors.attention,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.bordure,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valeur;
  final String label;
  final IconData icon;
  final Color couleur;

  const _StatItem({
    required this.valeur,
    required this.label,
    required this.icon,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: couleur, size: 20),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: couleur,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.texteSecond,
          ),
        ),
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── QR Code card ─────────────────────────────────────────────
class _QrCard extends ConsumerWidget {
  final WidgetRef ref;
  const _QrCard({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(monQrProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordure),
        boxShadow: AppColors.shadowNiveau1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mon QR collecteur',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.texte,
                      ),
                    ),
                    Text(
                      'Valide 24h — les clients scannent ce code',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          qrAsync.when(
            data: (qr) {
              final code = qr['codeQR']?.toString() ??
                  qr['code']?.toString() ??
                  qr['url']?.toString() ??
                  '';
              if (code.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('QR indisponible', style: AppTextStyles.caption),
                );
              }
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bordure),
                    ),
                    child: QrImageView(
                      data: code,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${code.substring(0, 8).toUpperCase()}...',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 210,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erreur de chargement du QR', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte paramètre générique ────────────────────────────────
class _CarteParametre extends StatelessWidget {
  final Widget child;
  const _CarteParametre({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
        boxShadow: AppColors.shadowNiveau1,
      ),
      child: child,
    );
  }
}

// ── Bouton déconnexion ───────────────────────────────────────
class _BoutonDeconnexion extends ConsumerWidget {
  final WidgetRef ref;
  const _BoutonDeconnexion({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
                ),
                content: const Text(
                  'Voulez-vous vraiment vous déconnecter ?',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Déconnexion'),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await ref.read(profilRepositoryProvider).deconnexion();
              await SecureStorage.effacerSession();
              if (context.mounted) context.go(Routes.auth);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Toggle biométrie ─────────────────────────────────────────
class _BiometrieToggle extends StatefulWidget {
  const _BiometrieToggle();

  @override
  State<_BiometrieToggle> createState() => _BiometrieToggleState();
}

class _BiometrieToggleState extends State<_BiometrieToggle> {
  bool _active = false;

  @override
  void initState() {
    super.initState();
    BiometrieService.estActivee().then((v) {
      if (mounted) setState(() => _active = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _active ? AppColors.primaryLight : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.fingerprint_rounded,
          color: _active ? AppColors.primary : AppColors.muted,
          size: 20,
        ),
      ),
      title: const Text(
        'Biométrie',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.texte,
        ),
      ),
      subtitle: Text(
        _active ? 'Activée — connexion rapide' : 'Désactivée',
        style: AppTextStyles.caption,
      ),
      trailing: Switch(
        value: _active,
        activeThumbColor: AppColors.primary,
        onChanged: (v) async {
          if (v) {
            final ok = await BiometrieService.authentifier();
            if (!ok) return;
            await BiometrieService.activer(true);
          } else {
            await BiometrieService.activer(false);
          }
          setState(() => _active = v);
        },
      ),
    );
  }
}
