import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../router/app_router.dart';
import '../providers/session_provider.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final digits = <String>[];
  bool scanning = false;

  Future<void> _authenticateAndLogin() async {
    setState(() => scanning = true);
    final ok = await verifierEmpreinte();
    if (!mounted) return;
    setState(() => scanning = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometrie requise pour ouvrir la session.')),
      );
      return;
    }
    await ref.read(sessionProvider.notifier).connexionDemo();
    if (mounted) context.go(Routes.home);
  }

  Future<bool> verifierEmpreinte() async {
    final auth = LocalAuthentication();
    try {
      if (!await auth.canCheckBiometrics) return false;
      return auth.authenticate(
        localizedReason: 'Confirmez votre identite TontinePro',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }

  void _tap(String value) {
    if (digits.length == 4) return;
    setState(() => digits.add(value));
    if (digits.length == 4) _authenticateAndLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PIN securise')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.fingerprint, size: 82, color: AppColors.primary),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < digits.length ? AppColors.primary : AppColors.bordure,
                  ),
                ),
              ),
            ),
            if (scanning) const LinearProgressIndicator(color: AppColors.primary),
            const Spacer(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 1.35,
              children: List.generate(9, (i) {
                final value = '${i + 1}';
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: OutlinedButton(
                    onPressed: () => _tap(value),
                    child: Text(value, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }),
            ),
            IconButton.filled(
              tooltip: 'Authentification biometrique',
              onPressed: _authenticateAndLogin,
              icon: const Icon(Icons.fingerprint),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
