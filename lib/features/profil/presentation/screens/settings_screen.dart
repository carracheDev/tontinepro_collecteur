import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/biometrie_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/profil_repository.dart';

final _biometrieActiveeProvider = FutureProvider.autoDispose((ref) {
  return BiometrieService.estActivee();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Parametres'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const _SectionTitle('COMPTE'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.person_outline,
                  title: 'Profil collecteur',
                  onTap: () => context.push(Routes.profil),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.fingerprint,
                  title: 'Biometrie',
                  trailing: ref.watch(_biometrieActiveeProvider).when(
                        data: (active) => Switch(
                          value: active,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) async {
                            if (v) {
                              final ok = await BiometrieService.authentifier();
                              if (!ok) return;
                            }
                            await BiometrieService.activer(v);
                            ref.invalidate(_biometrieActiveeProvider);
                          },
                        ),
                        loading: () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, _) => Switch(
                          value: false,
                          onChanged: (v) async {
                            await BiometrieService.activer(v);
                            ref.invalidate(_biometrieActiveeProvider);
                          },
                        ),
                      ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.qr_code_outlined,
                  title: 'Mon QR collecteur',
                  onTap: () => context.push(Routes.profil),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('APPLICATION'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  trailing: Switch(
                    value: true,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) {},
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.language_outlined,
                  title: 'Langue',
                  trailing: Text('Francais', style: AppTextStyles.caption),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  trailing: Text('1.0.0', style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('SECURITE'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.lock_outline,
                  title: 'Changer le PIN',
                  onTap: () => context.push(
                    Routes.creerPin,
                    extra: {'telephone': ''},
                  ),
                ),
                const Divider(height: 1),
                const _SettingTile(
                  icon: Icons.shield_outlined,
                  title: 'Anti-fraude actif',
                  trailing: _ActiveBadge(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(profilRepositoryProvider).deconnexion();
                await SecureStorage.effacerSession();
                if (context.mounted) context.go(Routes.auth);
              },
              icon: const Icon(Icons.logout, color: AppColors.annuler),
              label: const Text(
                'Deconnexion',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: AppColors.annuler,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.annuler),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.muted,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.texte,
        ),
      ),
      trailing: trailing ??
          (onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                )),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Active',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
