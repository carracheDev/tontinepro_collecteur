import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_router.dart';
import '../providers/auth_provider.dart';

/// Vérification OTP — même comportement sandbox que l'app client :
/// `otpTest` du backend → snackbar + préremplissage + validation auto.
class OtpScreen extends ConsumerStatefulWidget {
  final String telephone;
  final String nom;
  final String role;
  final String? otpTest;

  const OtpScreen({
    super.key,
    required this.telephone,
    required this.nom,
    required this.role,
    this.otpTest,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<String> _otp = List.filled(6, '');
  final List<FocusNode> _focuses = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());

  int _secondes = 600;
  Timer? _timer;
  bool _soumis = false;

  bool get _complet => _otp.every((v) => v.isNotEmpty);
  bool get _peutRenvoyer => _secondes <= 0;

  String get _timerStr {
    final m = _secondes ~/ 60;
    final s = _secondes % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _telMasque {
    final t = widget.telephone.replaceFirst('+229', '');
    if (t.length < 10) return widget.telephone;
    return '+229 01XX XX XX ${t.substring(t.length - 2)}';
  }

  String? get _codeSandbox {
    final fromWidget = widget.otpTest?.trim();
    if (fromWidget != null && fromWidget.isNotEmpty) return fromWidget;
    final fromProvider = ref.read(inscriptionProvider).otpTest?.trim();
    if (fromProvider != null && fromProvider.isNotEmpty) return fromProvider;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _demarrerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focuses[0].requestFocus();
      final code = _codeSandbox;
      if (code != null) _afficherOtpTest(code);
    });
  }

  void _demarrerTimer() {
    _timer?.cancel();
    setState(() => _secondes = 600);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondes <= 0) {
        t.cancel();
      } else {
        setState(() => _secondes--);
      }
    });
  }

  void _afficherOtpTest(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔐 Code test : $digits',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFD97706),
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    for (var i = 0; i < 6; i++) {
      _ctrls[i].text = digits[i];
      _otp[i] = digits[i];
    }
    setState(() {});

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _complet && !_soumis) _verifier();
    });
  }

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (var j = 0; j < 6 && j < digits.length; j++) {
        _ctrls[j].text = digits[j];
        _otp[j] = digits[j];
      }
      setState(() {});
      if (_complet && !_soumis) _verifier();
      return;
    }
    _otp[i] = v;
    setState(() {});
    if (v.isNotEmpty && i < 5) _focuses[i + 1].requestFocus();
    if (v.isEmpty && i > 0) _focuses[i - 1].requestFocus();
    if (_complet && !_soumis) _verifier();
  }

  Future<void> _verifier() async {
    if (!_complet || _soumis) return;
    setState(() => _soumis = true);
    final code = _otp.join();
    final ok = await ref.read(otpProvider.notifier).verifier(
          telephone: widget.telephone,
          code: code,
        );
    if (!mounted) return;
    if (ok) {
      context.go(Routes.creerPin, extra: {'telephone': widget.telephone});
    } else {
      setState(() => _soumis = false);
    }
  }

  Future<void> _renvoyer() async {
    if (!_peutRenvoyer) return;
    for (var i = 0; i < 6; i++) {
      _ctrls[i].clear();
      _otp[i] = '';
    }
    setState(() => _soumis = false);
    final ok = await ref.read(inscriptionProvider.notifier).inscrire(
          telephone: widget.telephone,
          nom: widget.nom,
          role: widget.role,
        );
    if (ok) {
      final newOtp = ref.read(inscriptionProvider).otpTest;
      if (newOtp != null && mounted) _afficherOtpTest(newOtp);
    }
    _demarrerTimer();
    _focuses[0].requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focuses) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpProvider);
    final timerRouge = _secondes < 30;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sms_outlined,
                color: Color(0xFF16A34A),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vérification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Code envoyé au $_telMasque',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontFamily: 'Poppins',
              ),
            ),
            if (_codeSandbox != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  'Mode sandbox — code prérempli automatiquement',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) {
                final rempli = _otp[i].isNotEmpty;
                return Container(
                  width: 45,
                  height: 52,
                  decoration: BoxDecoration(
                    color: rempli ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: rempli
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _focuses[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (v) => _onChanged(i, v),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFamily: 'Nunito',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              _timerStr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: timerRouge
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _peutRenvoyer ? _renvoyer : null,
              child: Text(
                'Renvoyer le code',
                style: TextStyle(
                  color: _peutRenvoyer
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (state.erreur != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.erreur!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_complet && !state.loading && !_soumis)
                    ? _verifier
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _complet
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9CA3AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state.loading || _soumis
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'VÉRIFIER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
