import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/calendrier_cultural.dart';

class CalendrierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.calendrierCulturalStore;

  /// Tente de récupérer les données (ex: depuis l'API).
  /// En cas d'échec, bascule automatiquement sur le store Sembast local.
  Future<List<CalendrierCultural>> fetchCalendrier() async {
    try {
      // NOTE: Remplacer par un véritable appel API quand le backend sera prêt.
      // Pour l'instant on lit Sembast en guise de source principale.
      final db = await _dbHelper.database;
      final snapshots = await _store.find(db);
      if (snapshots.isEmpty) {
        throw Exception('Source principale vide ou injoignable');
      }
      return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
    } catch (e) {
      // FLUX DE REPLI LOCAL : Fallback sur Sembast
      return await getFallbackLocal();
    }
  }

  /// Lecture de secours stricte depuis Sembast.
  /// Si le store est vide ou corrompu, renvoie une liste vide proprement.
  Future<List<CalendrierCultural>> getFallbackLocal() async {
    try {
      final db = await _dbHelper.database;
      final snapshots = await _store.find(db);
      if (snapshots.isEmpty) {
        return []; // Renvoie une liste vide au lieu de bloquer
      }
      return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
    } catch (e) {
      return []; // Sécurité ultime : liste vide en cas de crash
    }
  }

  Future<List<CalendrierCultural>> getCalendrierParRegion(String region) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('region', region),
      sortOrders: [SortOrder('type_culture')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<CalendrierCultural>> getCalendrierParTypeCulture(String typeCulture) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('type_culture', typeCulture),
      sortOrders: [SortOrder('region')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<CalendrierCultural>> getCalendrierDuMois(int mois) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.custom((value) {
        final debut = value['mois_semis_debut'] as int;
        final fin = value['mois_semis_fin'] as int;
        return debut <= mois && fin >= mois;
      }),
      sortOrders: [SortOrder('region'), SortOrder('type_culture')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<String>> getToutesRegions() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db);
    final regions = snapshots.map((s) => s.value['region'] as String).toSet().toList();
    regions.sort();
    return regions;
  }

  Future<List<String>> getTousTypesCulture() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db);
    final types = snapshots.map((s) => s.value['type_culture'] as String).toSet().toList();
    types.sort();
    return types;
  }
}
