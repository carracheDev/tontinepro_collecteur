import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollecteFormState {
  final String? clientId;
  final String? clientNom;
  final String? tontineId;
  final int montant;
  final String operateur;
  final bool loading;
  final String? erreur;

  const CollecteFormState({
    this.clientId,
    this.clientNom,
    this.tontineId,
    this.montant = 0,
    this.operateur = 'MTN',
    this.loading = false,
    this.erreur,
  });

  CollecteFormState copyWith({
    String? clientId,
    String? clientNom,
    String? tontineId,
    int? montant,
    String? operateur,
    bool? loading,
    String? erreur,
  }) =>
      CollecteFormState(
        clientId: clientId ?? this.clientId,
        clientNom: clientNom ?? this.clientNom,
        tontineId: tontineId ?? this.tontineId,
        montant: montant ?? this.montant,
        operateur: operateur ?? this.operateur,
        loading: loading ?? this.loading,
        erreur: erreur,
      );
}

class CollecteFormNotifier extends StateNotifier<CollecteFormState> {
  CollecteFormNotifier() : super(const CollecteFormState());

  void initialiser(Map<String, dynamic>? extra) {
    if (extra == null) return;
    state = state.copyWith(
      clientId: extra['clientId'] as String?,
      clientNom: extra['clientNom'] as String?,
      tontineId: extra['tontineId'] as String?,
    );
  }

  void setMontant(int v) => state = state.copyWith(montant: v);
  void setOperateur(String v) => state = state.copyWith(operateur: v);
  void setClient(String id, String nom) =>
      state = state.copyWith(clientId: id, clientNom: nom);
}

final collecteFormProvider =
    StateNotifierProvider.autoDispose<CollecteFormNotifier, CollecteFormState>(
  (ref) => CollecteFormNotifier(),
);

final operationEnCoursProvider =
    StateProvider.autoDispose<String?>((ref) => null);
