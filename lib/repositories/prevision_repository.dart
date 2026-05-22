import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/prevision.dart';

class PrevisionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.previsionStore;

  Future<List<Prevision>> getPrevisionsParVille(String villeId) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('ville_id', villeId),
      sortOrders: [SortOrder('date_heure')],
    ));
    return snapshots.map((s) => Prevision.fromMap(s.value)).toList();
  }

  Future<Prevision?> getDernierePrevision(String villeId) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('ville_id', villeId),
      sortOrders: [SortOrder('date_creation', false)],
      limit: 1,
    ));
    if (snapshots.isEmpty) return null;
    return Prevision.fromMap(snapshots.first.value);
  }

  Future<bool> cacheValide(String villeId) async {
    final prevision = await getDernierePrevision(villeId);
    if (prevision == null) return false;
    return !prevision.estExpiree();
  }

  Future<void> insererPrevision(Prevision prevision) async {
    final db = await _dbHelper.database;
    await _store.record(prevision.id).put(db, prevision.toMap());
  }

  Future<void> insererPrevisions(List<Prevision> previsions) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (final p in previsions) {
        await _store.record(p.id).put(txn, p.toMap());
      }
    });
  }

  Future<void> supprimerVieillesPrevisions(String villeId) async {
    final db = await _dbHelper.database;
    final limite = DateTime.now()
        .subtract(const Duration(minutes: 30))
        .toIso8601String();
    await _store.delete(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.custom((value) {
          return (value['date_creation'] as String).compareTo(limite) < 0;
        }),
      ]),
    ));
  }

  Future<List<Prevision>> getPrevisions7Jours(String villeId) async {
    final db = await _dbHelper.database;
    final maintenant = DateTime.now().toIso8601String();
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.custom((value) {
          return (value['date_heure'] as String).compareTo(maintenant) >= 0;
        }),
      ]),
      sortOrders: [SortOrder('date_heure')],
      limit: 7,
    ));
    return snapshots.map((s) => Prevision.fromMap(s.value)).toList();
  }
}
