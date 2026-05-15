import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../router/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final actions = session.role == AppRole.superviseur
        ? const [
            _Action('Zone', Icons.map, Routes.supervision),
            _Action('Agents', Icons.groups, Routes.supervision),
            _Action('Litiges', Icons.gavel, Routes.alertes),
            _Action('Alertes', Icons.warning, Routes.alertes),
          ]
        : [
            const _Action('Clients', Icons.people, Routes.clients),
            const _Action('Collecte', Icons.payments, Routes.collecte),
            const _Action('Scanner', Icons.qr_code_scanner, Routes.scanner),
            _Action(
              session.role == AppRole.agent ? 'Missions' : 'Finances',
              session.role == AppRole.agent ? Icons.route : Icons.bar_chart,
              session.role == AppRole.agent ? Routes.missions : Routes.finances,
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: Text('Accueil ${session.role.label}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              KpiCard(title: 'Collecte jour', value: '185 000 F', icon: Icons.payments),
              KpiCard(title: 'Clients visites', value: '24', icon: Icons.people),
              KpiCard(title: 'OTP envoyes', value: '18', icon: Icons.sms),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: actions
                .map(
                  (a) => AppCard(
                    onTap: () => context.push(a.route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(a.icon, color: AppColors.primary, size: 34),
                        const SizedBox(height: 10),
                        Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.enroll),
            icon: const Icon(Icons.person_add),
            label: const Text('Enroler un client'),
          ),
        ],
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.of(context).size.width - 32, 220),
      child: AppCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.muted)),
                  Text(value, style: AppTextStyles.amount(size: 22)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
