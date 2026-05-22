import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/notification_locale.dart';

class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.notificationStore;

  Future<List<NotificationLocale>> getNotifications(String? type) async {
    final db = await _dbHelper.database;
    final snapshots = type != null
        ? await _store.find(db, finder: Finder(
            filter: Filter.equals('type', type),
            sortOrders: [SortOrder('date_envoi', false)],
          ))
        : await _store.find(db, finder: Finder(
            sortOrders: [SortOrder('date_envoi', false)],
          ));
    return snapshots.map((s) => NotificationLocale.fromMap(s.value)).toList();
  }

  Future<List<NotificationLocale>> getNotificationsNonLues() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db, finder: Finder(
      filter: Filter.equals('est_lue', 0),
      sortOrders: [SortOrder('date_envoi', false)],
    ));
    return snapshots.map((s) => NotificationLocale.fromMap(s.value)).toList();
  }

  Future<void> insererNotification(NotificationLocale notification) async {
    final db = await _dbHelper.database;
    await _store.record(notification.id).put(db, notification.toMap());
  }

  Future<void> marquerCommeLue(String id) async {
    final db = await _dbHelper.database;
    final record = await _store.record(id).get(db);
    if (record != null) {
      final updated = Map<String, dynamic>.from(record);
      updated['est_lue'] = 1;
      await _store.record(id).put(db, updated);
    }
  }

  Future<void> marquerToutesLues() async {
    final db = await _dbHelper.database;
    final snapshots = await _store.find(db);
    await db.transaction((txn) async {
      for (final s in snapshots) {
        final updated = Map<String, dynamic>.from(s.value);
        updated['est_lue'] = 1;
        await _store.record(s.key).put(txn, updated);
      }
    });
  }

  Future<int> countNonLues() async {
    final db = await _dbHelper.database;
    final results = await _store.find(db, finder: Finder(
      filter: Filter.equals('est_lue', 0),
    ));
    return results.length;
  }
}
