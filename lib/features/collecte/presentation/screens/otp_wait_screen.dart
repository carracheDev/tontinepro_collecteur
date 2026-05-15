import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/collecte_repository.dart';
import '../providers/collecte_provider.dart';

class OtpWaitScreen extends ConsumerStatefulWidget {
  const OtpWaitScreen({super.key});

  @override
  ConsumerState<OtpWaitScreen> createState() => _OtpWaitScreenState();
}

class _OtpWaitScreenState extends ConsumerState<OtpWaitScreen> {
  Timer? _poll;
  String? _message;
  bool _initie = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _demarrer());
  }

  Future<void> _demarrer() async {
    if (_initie) return;
    _initie = true;
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return;

    setState(() => _message = 'Envoi de la demande au client…');

    try {
      final pos = await LocationService.obtenirPosition();
      final result = await ref.read(collecteRepositoryProvider).initierCotisation(
            clientId: extra['clientId'] as String,
            montant: extra['montant'] as int,
            operateur: extra['operateur'] as String? ?? 'MTN',
            tontineId: extra['tontineId'] as String?,
            latitude: pos?.latitude,
            longitude: pos?.longitude,
          );

      ref.read(operationEnCoursProvider.notifier).state = result.operationId;

      if (!mounted) return;
      setState(() => _message = null);
      _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
        await _verifierStatut(result.operationId, extra);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _message = extraireMessageErreur(e));
      }
    }
  }

  Future<void> _verifierStatut(
    String operationId,
    Map<String, dynamic> extra,
  ) async {
    try {
      final statut =
          await ref.read(collecteRepositoryProvider).statut(operationId);
      if (!mounted) return;
      if (statut.estSucces) {
        _poll?.cancel();
        context.pushReplacement(
          Routes.collecteSucces,
          extra: {
            'montant': statut.montant,
            'clientNom': extra['clientNom'],
          },
        );
      } else if (statut.estEchec) {
        _poll?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opération ${statut.statut}')),
        );
        context.pop();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final montant = extra?['montant'];

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('En attente client'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.succesLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sms_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OTP envoyé au CLIENT ✓',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.texte,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message ??
                  'Le client confirme sur son téléphone (Mobile Money).\n\n⚠️ Vous ne voyez jamais le code OTP.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpsSecond,
            ),
            if (montant != null) ...[
              const SizedBox(height: 24),
              Text(
                '$montant FCFA',
                style: AppTextStyles.montantMoyen,
              ),
            ],
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
