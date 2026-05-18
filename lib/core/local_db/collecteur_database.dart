import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'collecteur_database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

/// Cache générique clé/JSON
class CacheKv extends Table {
  TextColumn get cle => text()();
  TextColumn get jsonData => text().named('json_data')();
  DateTimeColumn get cachedAt => dateTime().named('cached_at')();

  @override
  Set<Column> get primaryKey => {cle};
}

/// File d'attente des opérations saisies hors ligne.
/// Envoyées automatiquement au retour de la connexion.
class OperationsEnAttente extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get typeOp => text().named('type_op')(); // COTISATION | CHECK_IN | ENROLEMENT
  TextColumn get payload => text()();                  // JSON de la requête
  TextColumn get endpoint => text()();                 // ex: /transactions/cotiser
  TextColumn get methode => text().withDefault(const Constant('POST'))();
  DateTimeColumn get creeLe => dateTime().named('cree_le').withDefault(currentDateAndTime)();
  IntColumn get tentatives => integer().withDefault(const Constant(0))();
  TextColumn? get erreurDerniere => text().named('erreur_derniere').nullable()();
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [CacheKv, OperationsEnAttente])
class CollecteurDatabase extends _$CollecteurDatabase {
  CollecteurDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Cache KV ──────────────────────────────────────────────────────────────

  Future<String?> lireCache(String cle) async {
    final row = await (select(cacheKv)
          ..where((t) => t.cle.equals(cle)))
        .getSingleOrNull();
    return row?.jsonData;
  }

  Future<void> ecrireCache(String cle, String json) =>
      into(cacheKv).insertOnConflictUpdate(
        CacheKvCompanion.insert(
          cle: cle,
          jsonData: json,
          cachedAt: DateTime.now(),
        ),
      );

  // ── File d'attente ────────────────────────────────────────────────────────

  Future<void> ajouterOperation({
    required String typeOp,
    required String payload,
    required String endpoint,
    String methode = 'POST',
  }) =>
      into(operationsEnAttente).insert(
        OperationsEnAttenteCompanion.insert(
          typeOp: typeOp,
          payload: payload,
          endpoint: endpoint,
          methode: Value(methode),
        ),
      );

  Future<List<OperationsEnAttenteData>> operationsNonSyncs() =>
      (select(operationsEnAttente)
            ..where((t) => t.tentatives.isSmallerOrEqualValue(3))
            ..orderBy([(t) => OrderingTerm.asc(t.creeLe)]))
          .get();

  Future<void> incrementerTentative(int id, String? erreur) =>
      (update(operationsEnAttente)..where((t) => t.id.equals(id))).write(
        OperationsEnAttenteCompanion(
          tentatives: const Value.absent(),
          erreurDerniere: Value(erreur),
        ),
      );

  Future<void> supprimerOperation(int id) =>
      (delete(operationsEnAttente)..where((t) => t.id.equals(id))).go();

  Future<int> compterOperationsEnAttente() =>
      (select(operationsEnAttente)).get().then((l) => l.length);

  Future<void> viderTout() async {
    await delete(cacheKv).go();
    await delete(operationsEnAttente).go();
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'tontinepro_collecteur');

final collecteurDb = CollecteurDatabase();
