import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/calendrier_cultural.dart';

class CalendrierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.calendrierCulturalStore;

  Future<List<CalendrierCultural>> getCalendrierParRegion(
      String region) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('region', region),
      sortOrders: [SortOrder('type_culture')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<CalendrierCultural>> getCalendrierParTypeCulture(
      String typeCulture) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('type_culture', typeCulture),
      sortOrders: [SortOrder('region')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<CalendrierCultural>> getCalendrierDuMois(
      int mois) async {
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
