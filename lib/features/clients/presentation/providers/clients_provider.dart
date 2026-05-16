import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client_models.dart';
import '../../data/repositories/clients_repository.dart';

final clientsDuJourProvider =
    FutureProvider.autoDispose<ClientsDuJourResult>((ref) async {
  return ref.read(clientsRepositoryProvider).clientsDuJour();
});

final ficheClientProvider = FutureProvider.autoDispose
    .family<FicheTerrain, String>((ref, clientId) async {
  return ref.read(clientsRepositoryProvider).ficheTerrain(clientId);
});

enum FiltreClients { tous, aVisiter, visites, eligibleCredit, aRelancer }

final filtreClientsProvider =
    StateProvider.autoDispose<FiltreClients>((ref) => FiltreClients.tous);

final rechercheClientsProvider =
    StateProvider.autoDispose<String>((ref) => '');

final clientsFiltresProvider =
    Provider.autoDispose<AsyncValue<List<ClientResume>>>((ref) {
  final async = ref.watch(clientsDuJourProvider);
  final filtre = ref.watch(filtreClientsProvider);
  final recherche = ref.watch(rechercheClientsProvider).toLowerCase().trim();
  return async.whenData((data) {
    var liste = data.clients;
    switch (filtre) {
      case FiltreClients.aVisiter:
        liste = liste.where((c) => !c.dejaVisite).toList();
      case FiltreClients.visites:
        liste = liste.where((c) => c.dejaVisite).toList();
      case FiltreClients.eligibleCredit:
        liste = liste.where((c) => c.score >= 60).toList();
      case FiltreClients.aRelancer:
        liste = liste.where((c) => !c.dejaVisite).toList();
      case FiltreClients.tous:
        break;
    }
    if (recherche.isNotEmpty) {
      liste = liste
          .where((c) =>
              c.nom.toLowerCase().contains(recherche) ||
              c.telephone.contains(recherche))
          .toList();
    }
    return liste;
  });
});
