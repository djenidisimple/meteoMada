import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/alerte_cyclone.dart';

class AlerteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.alerteCycloneStore;
  StoreRef<String, Map<String, dynamic>> get _regionStore => _dbHelper.alerteRegionStore;

  Future<bool> alerteExistante(String alerteId) async {
    final db = await _dbHelper.database;
    final record = await _store.record(alerteId).get(db);
    return record != null;
  }

  Future<void> insererAlerte(AlerteCyclone alerte) async {
    final db = await _dbHelper.database;
    await _store.record(alerte.id).put(db, alerte.toMap());
  }

  Future<void> mettreAJourAlerte(AlerteCyclone alerte) async {
    final db = await _dbHelper.database;
    await _store.record(alerte.id).put(db, alerte.toMap());
  }

  Future<void> insererRegions(
      String alerteId, List<String> regions) async {
    final db = await _dbHelper.database;
    for (final region in regions) {
      await _regionStore.record('${alerteId}_$region').put(db, {
        'alerte_id': alerteId,
        'region': region,
      });
    }
  }

  Future<void> mettreAJourRegions(
      String alerteId, List<String> regions) async {
    final db = await _dbHelper.database;
    await _regionStore.delete(db, finder: Finder(
      filter: Filter.equals('alerte_id', alerteId),
    ));
    await insererRegions(alerteId, regions);
  }

  Future<List<AlerteCyclone>> getAlertesActives() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('est_active', 1),
      sortOrders: [SortOrder('date_emission', false)],
    ));
    final alertes = <AlerteCyclone>[];
    for (final s in snapshots) {
      final a = AlerteCyclone.fromMap(s.value);
      final regions = await getRegionsPourAlerte(a.id);
      alertes.add(AlerteCyclone(
        id: a.id,
        nomCyclone: a.nomCyclone,
        consignes: a.consignes,
        niveau: a.niveau,
        dateEmission: a.dateEmission,
        dateFinPrevue: a.dateFinPrevue,
        estActive: a.estActive,
        regions: regions,
      ));
    }
    return alertes;
  }

  Future<List<AlerteCyclone>> getToutesAlertes() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      sortOrders: [SortOrder('date_emission', false)],
    ));
    final alertes = <AlerteCyclone>[];
    for (final s in snapshots) {
      final a = AlerteCyclone.fromMap(s.value);
      final regions = await getRegionsPourAlerte(a.id);
      alertes.add(AlerteCyclone(
        id: a.id,
        nomCyclone: a.nomCyclone,
        consignes: a.consignes,
        niveau: a.niveau,
        dateEmission: a.dateEmission,
        dateFinPrevue: a.dateFinPrevue,
        estActive: a.estActive,
        regions: regions,
      ));
    }
    return alertes;
  }

  Future<List<AlerteCyclone>> getAlertesParRegion(String region) async {
    final db = await _dbHelper.database;
    final regionSnapshots = await _regionStore.find(db, finder: Finder(
      filter: Filter.equals('region', region),
    ));
    final alerteIds = regionSnapshots.map((s) => s.value['alerte_id'] as String).toSet();
    if (alerteIds.isEmpty) return [];

    final result = <AlerteCyclone>[];
    for (final id in alerteIds) {
      final alerte = await getDetailsAlerte(id);
      if (alerte != null) {
        result.add(alerte);
      }
    }
    result.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return result;
  }

  Future<List<String>> getRegionsPourAlerte(String alerteId) async {
    final db = await _dbHelper.database;
    final snapshots = await _regionStore.find(db, finder: Finder(
      filter: Filter.equals('alerte_id', alerteId),
    ));
    return snapshots.map((s) => s.value['region'] as String).toList();
  }

  Future<AlerteCyclone?> getDetailsAlerte(String alerteId) async {
    final db = await _dbHelper.database;
    final map = await _store.record(alerteId).get(db);
    if (map == null) return null;
    final a = AlerteCyclone.fromMap(map);
    final regions = await getRegionsPourAlerte(alerteId);
    return AlerteCyclone(
      id: a.id,
      nomCyclone: a.nomCyclone,
      consignes: a.consignes,
      niveau: a.niveau,
      dateEmission: a.dateEmission,
      dateFinPrevue: a.dateFinPrevue,
      estActive: a.estActive,
      regions: regions,
    );
  }
}
