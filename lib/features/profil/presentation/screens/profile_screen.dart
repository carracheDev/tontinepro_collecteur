import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/biometrie_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
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
    final qrAsync = ref.watch(monQrProvider);
    final nom = ref.watch(sessionNomProvider).value ?? '';

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    Formatters.initiales(nom),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                profilAsync.when(
                  data: (p) => Column(
                    children: [
                      Text(
                        p['nom']?.toString() ?? nom,
                        style: AppTextStyles.titre2,
                      ),
                      Text(
                        Formatters.telephone(
                          p['telephone']?.toString() ?? '',
                        ),
                        style: AppTextStyles.corpsSecond,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          p['role']?.toString() ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => Text(nom, style: AppTextStyles.titre2),
                  error: (_, _) => Text(nom, style: AppTextStyles.titre2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _BiometrieToggle(),
          const SizedBox(height: 16),
          Text('Mon QR collecteur', style: AppTextStyles.titre3),
          const SizedBox(height: 8),
          qrAsync.when(
            data: (qr) {
              final code = qr['codeQR']?.toString() ??
                  qr['code']?.toString() ??
                  qr['url']?.toString() ??
                  '';
              if (code.isEmpty) {
                return Text('QR indisponible', style: AppTextStyles.caption);
              }
              return Center(
                child: QrImageView(
                  data: code,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Déconnexion',
            variant: AppButtonVariant.annuler,
            onPressed: () async {
              await ref.read(profilRepositoryProvider).deconnexion();
              await SecureStorage.effacerSession();
              if (context.mounted) context.go(Routes.auth);
            },
          ),
        ],
      ),
    );
  }
}

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
    return SwitchListTile(
      title: const Text('Biométrie'),
      subtitle: Text(
        _active ? 'Activée' : 'Désactivée',
        style: AppTextStyles.caption,
      ),
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
    );
  }
}
