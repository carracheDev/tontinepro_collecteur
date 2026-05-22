import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../router/app_router.dart';
import '../../../clients/presentation/providers/clients_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _traite = false;
  late AnimationController _cadreAnim;
  late Animation<double> _cadrePulse;

  @override
  void initState() {
    super.initState();
    _cadreAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _cadrePulse = Tween<double>(begin: 0.85, end: 1.0).animate(_cadreAnim);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _cadreAnim.dispose();
    super.dispose();
  }

  // ── Détecte si le QR est un QR CLIENT (TONTINEPRO-CLIENT-{uuid})
  String? _extraireClientId(String raw) {
    final t = raw.trim();
    // Format: TONTINEPRO-CLIENT-{uuid}
    final prefixMatch = RegExp(
      r'TONTINEPRO-CLIENT-([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',
      caseSensitive: false,
    ).firstMatch(t);
    if (prefixMatch != null) return prefixMatch.group(1)!.toLowerCase();

    // Fallback : URL avec /client/{uuid}
    if (t.contains('/client/')) {
      final parts = t.split('/client/');
      if (parts.length > 1) return parts.last.split('/').first.toLowerCase();
    }
    return null;
  }

  // ── Détecte si le QR est un QR COLLECTEUR (UUID seul)
  String? _extraireCollecteurCode(String raw) {
    final t = raw.trim();
    // UUID brut (généré par le backend collecteur)
    final uuidMatch = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).firstMatch(t);
    if (uuidMatch != null) return t.toLowerCase();
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_traite) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    setState(() => _traite = true);
    await _ctrl.stop();

    // ── QR Client : lier le client au collecteur
    final clientId = _extraireClientId(raw);
    if (clientId != null) {
      await _lierClient(clientId);
      return;
    }

    // ── QR Collecteur : cas où le collecteur scanne son propre QR
    final collecteurCode = _extraireCollecteurCode(raw);
    if (collecteurCode != null) {
      _afficherErreur('Ce QR est un code collecteur, pas un code client.');
      return;
    }

    // ── QR inconnu
    _afficherErreur('QR code non reconnu. Demandez au client d\'afficher son QR depuis son application.');
  }

  Future<void> _lierClient(String clientId) async {
    if (!mounted) return;

    // Indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final resp = await DioClient.instance.post(
        ApiEndpoints.lierClient(clientId),
      );
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      debugPrint('[QR] Réponse lierClient: ${resp.data}');

      final donnees = (resp.data['donnees'] as Map?)?.cast<String, dynamic>() ?? {};
      final nomClient = donnees['nom']?.toString() ?? 'Client';
      final nbClients = donnees['nbClientsTotal'] as int? ?? 0;

      // Invalider le cache pour forcer le rechargement de la liste clients
      ref.invalidate(clientsDuJourProvider);

      // ── Dialogue succès
      await showDialog<void>(
        context: context,
        builder: (ctx) => _DialogSuccesLien(
          nomClient: nomClient,
          nbClients: nbClients,
          onVoirFiche: () {
            Navigator.pop(ctx);
            context.pushReplacement(Routes.clientDetail(clientId));
          },
          onFermer: () {
            Navigator.pop(ctx);
            context.pop();
          },
        ),
      );
    } catch (e) {
      debugPrint('[QR] ERREUR lierClient: $e');
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader
      final msg = extraireMessageErreur(e);
      debugPrint('[QR] Message erreur: $msg');
      _afficherErreur(msg);
    }
  }

  void _afficherErreur(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error_outline_rounded, color: AppColors.annuler, size: 22),
            SizedBox(width: 8),
            Text(
              'QR non reconnu',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _traite = false);
              _ctrl.start();
            },
            child: const Text(
              'Réessayer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          SafeArea(
            child: Column(
              children: [
                // ── Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Scanner QR Client',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Cadre QR animé
                ScaleTransition(
                  scale: _cadrePulse,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryVif, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: const [
                        _Coin(top: true, left: true),
                        _Coin(top: true, left: false),
                        _Coin(top: false, left: true),
                        _Coin(top: false, left: false),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Instructions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Cadrez le QR code du client',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Le client affiche son QR depuis\nson tiroir (avatar → drawer)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFD1FAE5),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialog succès liaison ────────────────────────────────────
class _DialogSuccesLien extends StatelessWidget {
  final String nomClient;
  final int nbClients;
  final VoidCallback onVoirFiche;
  final VoidCallback onFermer;

  const _DialogSuccesLien({
    required this.nomClient,
    required this.nbClients,
    required this.onVoirFiche,
    required this.onFermer,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône succès
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.link_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$nomClient lié !',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.texte,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ce client est maintenant dans votre portefeuille.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.texteSecond,
            ),
          ),
          const SizedBox(height: 14),
          // Compteur clients
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordure),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Vous avez maintenant ',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.texteSecond,
                  ),
                ),
                Text(
                  '$nbClients client${nbClients > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onFermer,
          child: const Text(
            'Fermer',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.texteSecond,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onVoirFiche,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.person_outline_rounded, size: 16),
          label: const Text(
            'Voir la fiche',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Coins décoratifs du cadre ────────────────────────────────
class _Coin extends StatelessWidget {
  final bool top;
  final bool left;
  const _Coin({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: AppColors.primaryVif, width: 4) : BorderSide.none,
            bottom: top ? BorderSide.none : const BorderSide(color: AppColors.primaryVif, width: 4),
            left: left ? const BorderSide(color: AppColors.primaryVif, width: 4) : BorderSide.none,
            right: left ? BorderSide.none : const BorderSide(color: AppColors.primaryVif, width: 4),
          ),
        ),
      ),
    );
  }
}
