import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/ville.dart';

class VilleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.villeStore;

  Future<List<Ville>> rechercherVilles(String terme) async {
    final db = await _dbHelper.database;
    final t = terme.toLowerCase();
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.custom((value) {
        final nom = (value['nom'] as String).toLowerCase();
        final region = (value['region'] as String).toLowerCase();
        return nom.contains(t) || region.contains(t);
      }),
      sortOrders: [SortOrder('nom')],
    ));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  Future<Ville?> getVilleParCoordonnees(double lat, double lon) async {
    final db = await _dbHelper.database;
    const tolerance = 0.5;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.and([
        Filter.custom((value) {
          final vlat = (value['latitude'] as num).toDouble();
          return vlat >= lat - tolerance && vlat <= lat + tolerance;
        }),
        Filter.custom((value) {
          final vlon = (value['longitude'] as num).toDouble();
          return vlon >= lon - tolerance && vlon <= lon + tolerance;
        }),
      ]),
      limit: 1,
    ));
    if (snapshots.isEmpty) return null;
    return Ville.fromMap(snapshots.first.value);
  }

  Future<Ville?> getVilleParId(String id) async {
    final db = await _dbHelper.database;
    final map = await _store.record(id).get(db);
    if (map == null) return null;
    return Ville.fromMap(map);
  }

  Future<List<Ville>> getAllVilles() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(sortOrders: [SortOrder('nom')]));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  Future<List<Ville>> getVillesCotieres() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('est_cotiere', 1),
      sortOrders: [SortOrder('nom')],
    ));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  Future<void> insererVille(Ville ville) async {
    final db = await _dbHelper.database;
    await _store.record(ville.id).put(db, ville.toMap());
  }

  Future<void> reinitialiserDonnees() async {
    await _dbHelper.peuplerSiVide();
  }
}
