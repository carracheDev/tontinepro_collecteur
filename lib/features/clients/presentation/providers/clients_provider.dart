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

enum FiltreClients { tous, aVisiter, visites, kyc }

final filtreClientsProvider =
    StateProvider.autoDispose<FiltreClients>((ref) => FiltreClients.tous);

final clientsFiltresProvider =
    Provider.autoDispose<AsyncValue<List<ClientResume>>>((ref) {
  final async = ref.watch(clientsDuJourProvider);
  final filtre = ref.watch(filtreClientsProvider);
  return async.whenData((data) {
    switch (filtre) {
      case FiltreClients.aVisiter:
        return data.clients.where((c) => !c.dejaVisite).toList();
      case FiltreClients.visites:
        return data.clients.where((c) => c.dejaVisite).toList();
      case FiltreClients.kyc:
        return data.clients.where((c) => c.kycVerifie).toList();
      case FiltreClients.tous:
        return data.clients;
    }
  });
});
