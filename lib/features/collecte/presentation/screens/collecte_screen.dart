import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../features/auth/presentation/screens/auth_screen.dart';
import '../../../../router/app_router.dart';
import 'no_supervisor_collecte.dart';

class CollecteScreen extends ConsumerStatefulWidget {
  const CollecteScreen({super.key});

  @override
  ConsumerState<CollecteScreen> createState() => _CollecteScreenState();
}

class _CollecteScreenState extends ConsumerState<CollecteScreen> {
  final amount = TextEditingController(text: '1000');
  String operator = 'MTN';
  bool checkingGps = false;

  Future<void> _submit() async {
    setState(() => checkingGps = true);
    try {
      await Geolocator.getCurrentPosition();
    } catch (_) {
      // Le backend validera le vrai check-in quand l'API terrain sera branchee.
    }
    if (!mounted) return;
    setState(() => checkingGps = false);
    context.push(Routes.otpWait);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionProvider).role;
    if (role == AppRole.superviseur) return const NoSupervisorCollecte();
    return Scaffold(
      appBar: AppBar(title: const Text('Collecte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SecurityNoticeCard(),
          const SizedBox(height: 14),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant exact tontine',
              suffixText: 'FCFA',
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'MTN', label: Text('MTN')),
              ButtonSegment(value: 'MOOV', label: Text('Moov')),
            ],
            selected: {operator},
            onSelectionChanged: (v) => setState(() => operator = v.first),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: checkingGps ? null : _submit,
            icon: Icon(checkingGps ? Icons.location_searching : Icons.pin_drop),
            label: Text(checkingGps ? 'Check-in GPS...' : 'Initier OTP client'),
          ),
        ],
      ),
    );
  }
}
