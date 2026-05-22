import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/condition_marine.dart';

class ConditionMarineRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.conditionMarineStore;

  Future<ConditionMarine?> getConditionMarine(String villeId) async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('ville_id', villeId),
      limit: 1,
    ));
    if (snapshots.isEmpty) return null;
    return ConditionMarine.fromMap(snapshots.first.value);
  }

  Future<void> insererConditionMarine(ConditionMarine condition) async {
    final db = await _dbHelper.database;
    await _store.record(condition.id).put(db, condition.toMap());
  }

  Future<void> supprimerConditionMarine(String villeId) async {
    final db = await _dbHelper.database;
    await _store.delete(db, finder: Finder(
      filter: Filter.equals('ville_id', villeId),
    ));
  }
}
