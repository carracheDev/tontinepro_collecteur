import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../router/app_router.dart';
import '../providers/session_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final phone = TextEditingController(text: '+22901');
  AppRole role = AppRole.agent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion collecteur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SecurityNoticeCard(),
          const SizedBox(height: 18),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telephone',
              hintText: '+2290141193597',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<AppRole>(
            segments: AppRole.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {role},
            onSelectionChanged: (value) => setState(() => role = value.first),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            icon: const Icon(Icons.lock),
            label: const Text('Continuer avec PIN'),
            onPressed: () {
              ref.read(sessionProvider.notifier).definirBrouillon(
                    telephone: phone.text.trim(),
                    role: role,
                  );
              context.go(Routes.pin);
            },
          ),
        ],
      ),
    );
  }
}

class SecurityNoticeCard extends StatelessWidget {
  const SecurityNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.shield),
        title: Text('Regles securite terrain'),
        subtitle: Text('OTP client masque, PIN jamais stocke en clair, biometrie obligatoire.'),
      ),
    );
  }
}
