import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'collecteur_database.dart';

/// Service de synchronisation des opérations saisies hors ligne.
///
/// Usage :
///   - `SyncService.instance.ajouterOperation(...)` depuis n'importe quel repo
///   - Le service écoute la reconnexion et rejoue automatiquement la file
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final CollecteurDatabase _db = collecteurDb;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _syncing = false;

  // ── Démarrage de l'écoute (appeler dans main.dart) ──────────────────────

  void demarrer(Dio dio) {
    _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((resultats) async {
      final enLigne = resultats.any((r) => r != ConnectivityResult.none);
      if (enLigne) await synchroniser(dio);
    });
  }

  void arreter() => _sub?.cancel();

  // ── Ajouter une opération à la file ─────────────────────────────────────

  Future<void> ajouterOperation({
    required String typeOp,
    required Map<String, dynamic> payload,
    required String endpoint,
    String methode = 'POST',
  }) =>
      _db.ajouterOperation(
        typeOp: typeOp,
        payload: jsonEncode(payload),
        endpoint: endpoint,
        methode: methode,
      );

  // ── Synchroniser la file dès le retour de connexion ─────────────────────

  Future<void> synchroniser(Dio dio) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final ops = await _db.operationsNonSyncs();
      for (final op in ops) {
        try {
          final body = jsonDecode(op.payload) as Map<String, dynamic>;
          switch (op.methode.toUpperCase()) {
            case 'POST':
              await dio.post(op.endpoint, data: body);
            case 'PUT':
              await dio.put(op.endpoint, data: body);
            case 'PATCH':
              await dio.patch(op.endpoint, data: body);
            default:
              await dio.post(op.endpoint, data: body);
          }
          // Succès → supprimer de la file
          await _db.supprimerOperation(op.id);
        } catch (e) {
          // Échec → incrémenter tentatives (max 3, après on abandonne)
          await _db.incrementerTentative(op.id, e.toString());
          if (op.tentatives >= 3) {
            await _db.supprimerOperation(op.id);
          }
        }
      }
    } finally {
      _syncing = false;
    }
  }

  /// Nombre d'opérations en attente (pour badge UI)
  Future<int> compterEnAttente() => _db.compterOperationsEnAttente();
}
