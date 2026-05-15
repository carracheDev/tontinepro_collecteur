import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/initial_avatar.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../router/app_router.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche client')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: InitialAvatar(name: 'Afi Akplogan', radius: 44)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Afi Akplogan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          const KpiCard(title: 'Solde tontine', value: '76 000 F', icon: Icons.savings),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.push(Routes.biometrie),
            icon: const Icon(Icons.fingerprint),
            label: const Text('Cotisation assistee'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.otpWait),
            icon: const Icon(Icons.sms),
            label: const Text('Retrait assiste avec OTP client'),
          ),
        ],
      ),
    );
  }
}
