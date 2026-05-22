import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/utilisateur.dart';

class UtilisateurRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.utilisateurStore;

  Future<Utilisateur?> getUtilisateur(String id) async {
    final db = await _dbHelper.database;
    final map = await _store.record(id).get(db);
    if (map == null) return null;
    return Utilisateur.fromMap(map);
  }

  Future<Utilisateur?> getUtilisateurParDefaut() async {
    return getUtilisateur('default_user');
  }

  Future<void> insererOuMAJ(Utilisateur utilisateur) async {
    final db = await _dbHelper.database;
    await _store.record(utilisateur.id).put(db, utilisateur.toMap());
  }

  Future<void> mettreAJourLangue(String utilisateurId, String langue) async {
    final db = await _dbHelper.database;
    final record = await _store.record(utilisateurId).get(db);
    if (record != null) {
      final updated = Map<String, dynamic>.from(record);
      updated['langue_preferee'] = langue;
      await _store.record(utilisateurId).put(db, updated);
    }
  }

  Future<void> mettreAJourNotifications(
    String utilisateurId, {
    bool? cyclone,
    bool? pluie,
  }) async {
    final db = await _dbHelper.database;
    final record = await _store.record(utilisateurId).get(db);
    if (record != null) {
      final updated = Map<String, dynamic>.from(record);
      if (cyclone != null) updated['alertes_cyclone_activees'] = cyclone ? 1 : 0;
      if (pluie != null) updated['alertes_pluie_activees'] = pluie ? 1 : 0;
      await _store.record(utilisateurId).put(db, updated);
    }
  }
}
