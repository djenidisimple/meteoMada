import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/favori.dart';

class FavoriRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.favoriStore;

  Future<List<Favori>> getFavoris(String utilisateurId) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('utilisateur_id', utilisateurId),
      sortOrders: [SortOrder('ordre_affichage')],
    ));
    return snapshots.map((s) => Favori.fromMap(s.value)).toList();
  }

  Future<bool> estFavori(String villeId, String utilisateurId) async {
    final db = await _dbHelper.database;
    final results = await _store.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.equals('utilisateur_id', utilisateurId),
      ]),
    ));
    return results.isNotEmpty;
  }

  Future<void> ajouterFavori(Favori favori) async {
    final db = await _dbHelper.database;
    await _store.record(favori.id).put(db, favori.toMap());
  }

  Future<void> supprimerFavori(String id) async {
    final db = await _dbHelper.database;
    await _store.record(id).delete(db);
  }

  Future<void> supprimerFavoriParVille(
      String villeId, String utilisateurId) async {
    final db = await _dbHelper.database;
    await _store.delete(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.equals('utilisateur_id', utilisateurId),
      ]),
    ));
  }

  Future<void> reordonner(List<Favori> favoris) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (int i = 0; i < favoris.length; i++) {
        final record = await _store.record(favoris[i].id).get(txn);
        if (record != null) {
          final updated = Map<String, dynamic>.from(record);
          updated['ordre_affichage'] = i;
          await _store.record(favoris[i].id).put(txn, updated);
        }
      }
    });
  }
}
