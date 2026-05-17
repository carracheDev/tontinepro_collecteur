import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';

/// `true` = en ligne, `false` = hors ligne. Émet l'état initial immédiatement.
final connectiviteProvider = StreamProvider<bool>((ref) {
  final ctrl = StreamController<bool>();

  Future<void> emettre(List<ConnectivityResult> r) async {
    if (!ctrl.isClosed) ctrl.add(r.any((e) => e != ConnectivityResult.none));
  }

  Connectivity().checkConnectivity().then(emettre);
  final sub = Connectivity().onConnectivityChanged.listen(emettre);

  ref.onDispose(() {
    sub.cancel();
    ctrl.close();
  });

  return ctrl.stream;
});

/// Wraps [child] et affiche un bandeau rouge en haut si hors ligne.
class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLigne = ref.watch(connectiviteProvider).maybeWhen(
          data: (v) => v,
          orElse: () => true,
        );

    return Stack(
      children: [
        child,
        if (!enLigne)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Material(
              color: AppColors.annuler,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hors ligne — Opérations financières désactivées.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bloque une action sensible si pas de réseau. Retourne `true` = OK.
bool verifierConnexionOuBloquer(BuildContext context, WidgetRef ref) {
  final enLigne = ref
      .read(connectiviteProvider)
      .maybeWhen(data: (v) => v, orElse: () => true);
  if (!enLigne) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.annuler,
        content: Text(
          'Opération impossible : aucune connexion réseau.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  return enLigne;
}
