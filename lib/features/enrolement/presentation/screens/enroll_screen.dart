import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../router/app_router.dart';
import '../providers/enrolement_provider.dart';

class EnrollScreen extends ConsumerStatefulWidget {
  const EnrollScreen({super.key});

  @override
  ConsumerState<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends ConsumerState<EnrollScreen> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _cipCtrl = TextEditingController();
  final _montantCtrl = TextEditingController(text: '500');

  // Photo & signature
  File? _photoFile;
  File? _photoCipFile;
  final SignatureController _signCtrl = SignatureController(
    penStrokeWidth: 2.5,
    penColor: AppColors.texte,
    exportBackgroundColor: Colors.white,
  );

  final List<String> _steps = ['Infos', 'KYC', 'Tontine', 'Consentement'];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _quartierCtrl.dispose();
    _cipCtrl.dispose();
    _montantCtrl.dispose();
    _signCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enrolementProvider);
    final notifier = ref.read(enrolementProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Client sans smartphone',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.texte,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '2 min',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de progression ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final done = i < state.etape;
                final actif = i == state.etape;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || actif
                                ? AppColors.primary
                                : AppColors.bordure,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _steps[i],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: actif
                                ? AppColors.primary
                                : done
                                    ? AppColors.primary
                                    : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Contenu de l'étape ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bandeau sécurité (étape 0 seulement)
                  if (state.etape == 0) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Contrôle client obligatoire — le collecteur enrôle et initie. Le client confirme les opérations sensibles par SMS.',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Étape courante
                  _buildStep(state, notifier),

                  // Erreur
                  if (state.erreur != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.erreur!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.annuler,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Boutons navigation ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                if (state.etape > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: notifier.precedent,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Retour',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: state.etape == 3 ? 'ENRÔLER LE CLIENT' : 'CONTINUER',
                    loading: state.loading,
                    onPressed: state.etape < 3
                        ? _validerEtape
                        : () => _soumettre(notifier),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(EnrolementState state, EnrolementNotifier notifier) {
    switch (state.etape) {
      case 0:
        return _StepInfos(
          nomCtrl: _nomCtrl,
          telCtrl: _telCtrl,
          quartierCtrl: _quartierCtrl,
        );
      case 1:
        return _StepKyc(
          cipCtrl: _cipCtrl,
          photoFile: _photoFile,
          photoCipFile: _photoCipFile,
          onPrendrePhoto: _prendrePhoto,
          onSupprimerPhoto: () => setState(() => _photoFile = null),
          onPrendreCip: () => _prendrePhotoGenerique((f) => _photoCipFile = f),
          onSupprimerCip: () => setState(() => _photoCipFile = null),
        );
      case 2:
        return _StepTontine(
          montantCtrl: _montantCtrl,
          state: state,
          notifier: notifier,
        );
      case 3:
        return _StepConsentement(
          state: state,
          notifier: notifier,
          signCtrl: _signCtrl,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _prendrePhotoGenerique(void Function(File) onResult) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.bordure, borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title: const Text('Appareil photo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: const Text('Galerie', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    if (source == null) return;
    final xfile = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (xfile != null && mounted) {
      setState(() => onResult(File(xfile.path)));
    }
  }

  Future<void> _prendrePhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.bordure,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title: const Text('Appareil photo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: const Text('Galerie', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    if (source == null) return;
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (xfile != null && mounted) {
      setState(() => _photoFile = File(xfile.path));
    }
  }

  void _validerEtape() {
    final notifier = ref.read(enrolementProvider.notifier);
    final state = ref.read(enrolementProvider);
    switch (state.etape) {
      case 0:
        notifier.setNom(_nomCtrl.text.trim());
        notifier.setTelephone(_telCtrl.text.trim());
        notifier.setQuartier(_quartierCtrl.text.trim());
        if (_nomCtrl.text.trim().isEmpty) {
          notifier.setErreur('Le nom est obligatoire');
          return;
        }
        if (_telCtrl.text.trim().isEmpty) {
          notifier.setErreur('Le téléphone est obligatoire');
          return;
        }
      case 1:
        notifier.setCip(_cipCtrl.text.trim());
        if (_photoFile != null) {
          final bytes = _photoFile!.readAsBytesSync();
          notifier.setPhotoBase64('data:image/jpeg;base64,${base64Encode(bytes)}');
        }
        if (_photoCipFile != null) {
          final bytes = _photoCipFile!.readAsBytesSync();
          notifier.setCipPhotoBase64('data:image/jpeg;base64,${base64Encode(bytes)}');
        }
      case 2:
        final m = int.tryParse(_montantCtrl.text);
        if (m == null || m < 100) {
          notifier.setErreur('Montant minimum : 100 FCFA');
          return;
        }
        notifier.setMontant(m);
    }
    notifier.suivant();
  }

  Future<void> _soumettre(EnrolementNotifier notifier) async {
    // Exporter la signature
    if (_signCtrl.isNotEmpty) {
      final image = await _signCtrl.toImage();
      final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final signBytes = byteData.buffer.asUint8List();
        notifier.setSignatureBase64('data:image/png;base64,${base64Encode(signBytes)}');
      }
    }

    if (!ref.read(enrolementProvider).consentement) {
      notifier.setErreur('Vous devez cocher le consentement du client');
      return;
    }
    if (_signCtrl.isEmpty) {
      notifier.setErreur('La signature du client est obligatoire');
      return;
    }

    final result = await notifier.soumettre();
    if (result != null && mounted) {
      context.pushReplacement(
        Routes.enrolementSucces,
        extra: {
          'nom': result.nom,
          'clientId': result.clientId,
          'codeQr': result.codeQr,
          'identifiantTerrain': result.identifiantTerrain,
          'telephone': ref.read(enrolementProvider).telephone,
        },
      );
    }
  }
}

// ─── Étape 1 : Infos ─────────────────────────────────────────────
class _StepInfos extends StatelessWidget {
  final TextEditingController nomCtrl;
  final TextEditingController telCtrl;
  final TextEditingController quartierCtrl;
  const _StepInfos({required this.nomCtrl, required this.telCtrl, required this.quartierCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Infos personnelles'),
        const SizedBox(height: 16),
        _Field(label: 'Nom complet *', controller: nomCtrl, hint: 'Ex: Fatou Bio'),
        const SizedBox(height: 12),
        _Field(
          label: 'Téléphone *',
          controller: telCtrl,
          hint: '01 XX XX XX XX',
          prefixText: '+229 ',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d ]'))],
        ),
        const SizedBox(height: 12),
        _Field(label: 'Quartier / Zone', controller: quartierCtrl, hint: 'Ex: Dantokpa, Parakou...'),
      ],
    );
  }
}

// ─── Étape 2 : KYC + Photo ───────────────────────────────────────
class _StepKyc extends StatelessWidget {
  final TextEditingController cipCtrl;
  final File? photoFile;
  final File? photoCipFile;
  final VoidCallback onPrendrePhoto;
  final VoidCallback onSupprimerPhoto;
  final VoidCallback onPrendreCip;
  final VoidCallback onSupprimerCip;
  const _StepKyc({
    required this.cipCtrl,
    this.photoFile,
    this.photoCipFile,
    required this.onPrendrePhoto,
    required this.onSupprimerPhoto,
    required this.onPrendreCip,
    required this.onSupprimerCip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('KYC terrain'),
        const SizedBox(height: 6),
        Text('KYC minimal : utilisable terrain, validation complète possible plus tard.', style: AppTextStyles.corpsSecond),
        const SizedBox(height: 16),

        // Photo du client
        _FieldLabel('Photo du client *'),
        const SizedBox(height: 8),
        if (photoFile != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  photoFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: onSupprimerPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 18, color: AppColors.annuler),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onPrendrePhoto,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reprendre la photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ] else ...[
          InkWell(
            onTap: onPrendrePhoto,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 36),
                  SizedBox(height: 10),
                  Text(
                    'Prendre la photo du client',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  SizedBox(height: 4),
                  Text('Appuyez pour ouvrir l\'appareil photo', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Pièce d'identité CIP
        _FieldLabel('Photo de la pièce d\'identité CIP (optionnel)'),
        const SizedBox(height: 8),
        if (photoCipFile != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(photoCipFile!, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: onSupprimerCip,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: AppColors.annuler),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onPrendreCip,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reprendre la photo CIP'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ] else
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPrendreCip,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bordure, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, color: AppColors.muted, size: 28),
                  SizedBox(height: 6),
                  Text('Photographier la pièce CIP / NPI', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                  Text('Recto de la carte d\'identité', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // CIP
        _Field(label: 'CIP / NPI (optionnel)', controller: cipCtrl, hint: 'Ex: CIP-229-384-77'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12)),
          child: Text('KYC minimal : la photo suffit pour l\'enrôlement terrain. Le CIP peut être ajouté plus tard.', style: AppTextStyles.caption.copyWith(color: const Color(0xFF92400E))),
        ),
      ],
    );
  }
}

// ─── Étape 3 : Tontine ───────────────────────────────────────────
class _StepTontine extends StatelessWidget {
  final TextEditingController montantCtrl;
  final EnrolementState state;
  final EnrolementNotifier notifier;
  const _StepTontine({required this.montantCtrl, required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Tontine initiale'),
        const SizedBox(height: 6),
        Text('Choisissez la première épargne du client.', style: AppTextStyles.corpsSecond),
        const SizedBox(height: 16),

        _FieldLabel('Type de tontine'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: state.typeTontine,
          decoration: _dropDeco(),
          items: const [
            DropdownMenuItem(value: 'PERSONNEL', child: Text('Individuelle')),
            DropdownMenuItem(value: 'GROUPE', child: Text('Groupe')),
            DropdownMenuItem(value: 'PROJET', child: Text('Projet')),
          ],
          onChanged: (v) { if (v != null) notifier.setTypeTontine(v); },
        ),
        const SizedBox(height: 12),

        _FieldLabel('Politique de retrait'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: state.politiqueRetrait,
          decoration: _dropDeco(),
          items: const [
            DropdownMenuItem(value: 'FLEXIBLE', child: Text('FLEXIBLE — retrait libre après OTP')),
            DropdownMenuItem(value: 'PROGRAMME', child: Text('PROGRAMME — date de déblocage')),
            DropdownMenuItem(value: 'BLOQUE', child: Text('BLOQUÉ — jusqu\'à objectif atteint')),
          ],
          onChanged: (v) { if (v != null) notifier.setPolitiqueRetrait(v); },
        ),
        const SizedBox(height: 12),

        _FieldLabel('Montant journalier (FCFA)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [500, 1000, 2000, 5000].map((v) => GestureDetector(
            onTap: () {
              montantCtrl.text = v.toString();
              notifier.setMontant(v);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: state.montantJournalier == v ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: state.montantJournalier == v ? AppColors.primary : AppColors.bordure),
              ),
              child: Text('${v} F', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: state.montantJournalier == v ? AppColors.primary : AppColors.texte)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: montantCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => notifier.setMontant(int.tryParse(v) ?? 500),
          decoration: _dropDeco(hint: 'Ex: 500', suffix: 'FCFA'),
        ),
        const SizedBox(height: 16),

        // Estimation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Objectif estimé · 90 jours', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text('${state.montantJournalier * 90} FCFA', style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  const Text('Notifié par SMS au client chaque semaine', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _dropDeco({String? hint, String? suffix}) => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    hintText: hint, suffixText: suffix,
  );
}

// ─── Étape 4 : Consentement + Signature ──────────────────────────
class _StepConsentement extends StatelessWidget {
  final EnrolementState state;
  final EnrolementNotifier notifier;
  final SignatureController signCtrl;
  const _StepConsentement({required this.state, required this.notifier, required this.signCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Consentement et signature'),
        const SizedBox(height: 8),
        Text('Le client doit signer lui-même. Cette signature prouve son accord pour l\'enrôlement terrain.', style: AppTextStyles.corpsSecond),

        const SizedBox(height: 20),
        // Zone de signature
        _FieldLabel('Signature du client *'),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Signature(
              controller: signCtrl,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => signCtrl.clear(),
            icon: const Icon(Icons.refresh, size: 16, color: AppColors.muted),
            label: const Text('Effacer', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.muted)),
          ),
        ),

        const SizedBox(height: 16),
        // Consentement
        InkWell(
          onTap: () => notifier.setConsentement(!state.consentement),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: state.consentement ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: state.consentement ? AppColors.primary : AppColors.bordure),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(state.consentement ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: state.consentement ? AppColors.primary : AppColors.muted),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Le client consent à l\'enrôlement terrain. Consentement verbal et signature capturés. Le client a été informé de ses droits et que toute opération sensible exige son OTP SMS.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Info SMS après enrôlement
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.sms_outlined, color: AppColors.info, size: 18),
                  SizedBox(width: 8),
                  Text('SMS envoyé au client après enrôlement', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.info)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '"TontineBénin: Bienvenue {nom}. Compte terrain créé. ID: TP-XXX. Code USSD: *155*0*TP384#. Toute opération sensible exige votre OTP. Ne le donnez jamais à votre collecteur."',
                  style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Le collecteur ne verra jamais l\'OTP du client.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.attention),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Widgets communs ──────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.titre3);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted));
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _Field({required this.label, required this.controller, this.hint, this.prefixText, this.keyboardType, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            filled: true, fillColor: Colors.white,
            hintText: hint, prefixText: prefixText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}
