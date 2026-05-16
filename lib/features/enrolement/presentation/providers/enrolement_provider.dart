import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart' show extraireMessageErreur;
import '../../data/repositories/enrolement_repository.dart'
    show EnrolementRepository, EnrolementResult, enrolementRepositoryProvider;

class EnrolementState {
  final int etape;
  final bool loading;
  final String? erreur;
  final String nom;
  final String telephone;
  final String quartier;
  final String? cip;
  final String typeTontine;
  final String politiqueRetrait;
  final int montantJournalier;
  final bool consentement;
  final String? photoBase64;
  final String? cipPhotoBase64;
  final String? signatureBase64;

  const EnrolementState({
    this.etape = 0,
    this.loading = false,
    this.erreur,
    this.nom = '',
    this.telephone = '',
    this.quartier = '',
    this.cip,
    this.typeTontine = 'PERSONNEL',
    this.politiqueRetrait = 'FLEXIBLE',
    this.montantJournalier = 500,
    this.consentement = false,
    this.photoBase64,
    this.cipPhotoBase64,
    this.signatureBase64,
  });

  EnrolementState copyWith({
    int? etape,
    bool? loading,
    Object? erreur = _sentinel,
    String? nom,
    String? telephone,
    String? quartier,
    String? cip,
    String? typeTontine,
    String? politiqueRetrait,
    int? montantJournalier,
    bool? consentement,
    Object? photoBase64 = _sentinel,
    Object? cipPhotoBase64 = _sentinel,
    Object? signatureBase64 = _sentinel,
  }) =>
      EnrolementState(
        etape: etape ?? this.etape,
        loading: loading ?? this.loading,
        erreur: erreur == _sentinel ? this.erreur : erreur as String?,
        nom: nom ?? this.nom,
        telephone: telephone ?? this.telephone,
        quartier: quartier ?? this.quartier,
        cip: cip ?? this.cip,
        typeTontine: typeTontine ?? this.typeTontine,
        politiqueRetrait: politiqueRetrait ?? this.politiqueRetrait,
        montantJournalier: montantJournalier ?? this.montantJournalier,
        consentement: consentement ?? this.consentement,
        photoBase64: photoBase64 == _sentinel ? this.photoBase64 : photoBase64 as String?,
        cipPhotoBase64: cipPhotoBase64 == _sentinel ? this.cipPhotoBase64 : cipPhotoBase64 as String?,
        signatureBase64: signatureBase64 == _sentinel ? this.signatureBase64 : signatureBase64 as String?,
      );
}

const _sentinel = Object();

class EnrolementNotifier extends StateNotifier<EnrolementState> {
  final EnrolementRepository _repo;
  EnrolementNotifier(this._repo) : super(const EnrolementState());

  void suivant() => state = state.copyWith(etape: state.etape + 1, erreur: null);
  void precedent() =>
      state = state.copyWith(etape: state.etape > 0 ? state.etape - 1 : 0);

  void setNom(String v) => state = state.copyWith(nom: v, erreur: null);
  void setTelephone(String v) => state = state.copyWith(telephone: v, erreur: null);
  void setQuartier(String v) => state = state.copyWith(quartier: v);
  void setCip(String v) => state = state.copyWith(cip: v);
  void setTypeTontine(String v) => state = state.copyWith(typeTontine: v);
  void setPolitiqueRetrait(String v) => state = state.copyWith(politiqueRetrait: v);
  void setMontant(int v) => state = state.copyWith(montantJournalier: v);
  void setConsentement(bool v) => state = state.copyWith(consentement: v, erreur: null);
  void setErreur(String? msg) => state = state.copyWith(erreur: msg);
  void setPhotoBase64(String? v) => state = state.copyWith(photoBase64: v);
  void setCipPhotoBase64(String? v) => state = state.copyWith(cipPhotoBase64: v);
  void setSignatureBase64(String? v) => state = state.copyWith(signatureBase64: v);

  Future<EnrolementResult?> soumettre() async {
    if (!state.consentement) {
      state = state.copyWith(erreur: 'Consentement obligatoire');
      return null;
    }
    state = EnrolementState(
      etape: state.etape,
      loading: true,
      nom: state.nom,
      telephone: state.telephone,
      quartier: state.quartier,
      cip: state.cip,
      typeTontine: state.typeTontine,
      politiqueRetrait: state.politiqueRetrait,
      montantJournalier: state.montantJournalier,
      consentement: state.consentement,
      photoBase64: state.photoBase64,
      cipPhotoBase64: state.cipPhotoBase64,
      signatureBase64: state.signatureBase64,
    );
    try {
      final tel = state.telephone.startsWith('+229')
          ? state.telephone
          : '+229${state.telephone.replaceAll(RegExp(r'\D'), '')}';
      // Payload strictement conforme au DTO backend (forbidNonWhitelisted)
      final payload = <String, dynamic>{
        'nom': state.nom,
        'telephone': tel,
        'quartier': state.quartier.isNotEmpty ? state.quartier : 'Terrain',
        'typeTontine': state.typeTontine,
        'montantJournalierFcfa': state.montantJournalier,
        'consentementTexte': 'CONSENTEMENT_TERRAIN',
        if (state.cip != null && state.cip!.isNotEmpty) 'cip': state.cip,
        // Photos optionnelles — envoyées seulement si présentes
        if (state.photoBase64 != null) 'photoUrl': state.photoBase64,
        if (state.signatureBase64 != null) 'signatureUrl': state.signatureBase64,
      };
      final result = await _repo.enroler(payload);
      state = state.copyWith(loading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        erreur: extraireMessageErreur(e),
      );
      return null;
    }
  }
}

final enrolementProvider =
    StateNotifierProvider.autoDispose<EnrolementNotifier, EnrolementState>(
  (ref) => EnrolementNotifier(ref.read(enrolementRepositoryProvider)),
);
