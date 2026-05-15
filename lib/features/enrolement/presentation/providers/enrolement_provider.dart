import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final int montantJournalier;
  final bool consentement;

  const EnrolementState({
    this.etape = 0,
    this.loading = false,
    this.erreur,
    this.nom = '',
    this.telephone = '',
    this.quartier = '',
    this.cip,
    this.typeTontine = 'PERSONNEL',
    this.montantJournalier = 500,
    this.consentement = false,
  });

  EnrolementState copyWith({
    int? etape,
    bool? loading,
    String? erreur,
    String? nom,
    String? telephone,
    String? quartier,
    String? cip,
    String? typeTontine,
    int? montantJournalier,
    bool? consentement,
  }) =>
      EnrolementState(
        etape: etape ?? this.etape,
        loading: loading ?? this.loading,
        erreur: erreur,
        nom: nom ?? this.nom,
        telephone: telephone ?? this.telephone,
        quartier: quartier ?? this.quartier,
        cip: cip ?? this.cip,
        typeTontine: typeTontine ?? this.typeTontine,
        montantJournalier: montantJournalier ?? this.montantJournalier,
        consentement: consentement ?? this.consentement,
      );
}

class EnrolementNotifier extends StateNotifier<EnrolementState> {
  final EnrolementRepository _repo;
  EnrolementNotifier(this._repo) : super(const EnrolementState());

  void suivant() => state = state.copyWith(etape: state.etape + 1, erreur: null);
  void precedent() =>
      state = state.copyWith(etape: state.etape > 0 ? state.etape - 1 : 0);

  void setNom(String v) => state = state.copyWith(nom: v);
  void setTelephone(String v) => state = state.copyWith(telephone: v);
  void setQuartier(String v) => state = state.copyWith(quartier: v);
  void setCip(String v) => state = state.copyWith(cip: v);
  void setTypeTontine(String v) => state = state.copyWith(typeTontine: v);
  void setMontant(int v) => state = state.copyWith(montantJournalier: v);
  void setConsentement(bool v) => state = state.copyWith(consentement: v);

  Future<EnrolementResult?> soumettre() async {
    if (!state.consentement) {
      state = state.copyWith(erreur: 'Consentement obligatoire');
      return null;
    }
    state = state.copyWith(loading: true, erreur: null);
    try {
      final tel = state.telephone.startsWith('+229')
          ? state.telephone
          : '+229${state.telephone.replaceAll(RegExp(r'\D'), '')}';
      final result = await _repo.enroler({
        'nom': state.nom,
        'telephone': tel,
        'quartier': state.quartier,
        if (state.cip != null && state.cip!.isNotEmpty) 'cip': state.cip,
        'typeTontine': state.typeTontine,
        'montantJournalierFcfa': state.montantJournalier,
        'consentementTexte': 'CONSENTEMENT_TERRAIN_COLLECTEUR',
      });
      state = state.copyWith(loading: false);
      return result;
    } catch (e) {
      state = state.copyWith(loading: false, erreur: e.toString());
      return null;
    }
  }
}

final enrolementProvider =
    StateNotifierProvider.autoDispose<EnrolementNotifier, EnrolementState>(
  (ref) => EnrolementNotifier(ref.read(enrolementRepositoryProvider)),
);
