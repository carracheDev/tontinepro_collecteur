import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/initial_avatar.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final qrData = '{"collecteurId":"demo","role":"${session.role.apiValue}"}';
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: InitialAvatar(name: session.role.label, radius: 42)),
          const SizedBox(height: 12),
          Center(child: Text(session.telephone.isEmpty ? '+22901...' : session.telephone)),
          const SizedBox(height: 8),
          const Chip(
            avatar: Icon(Icons.fingerprint, size: 18),
            label: Text('Biometrie active'),
          ),
          const SizedBox(height: 18),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 240,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(sessionProvider.notifier).deconnexion();
              if (context.mounted) context.go(Routes.auth);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Deconnexion'),
          ),
        ],
      ),
    );
  }
}
