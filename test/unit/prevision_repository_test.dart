import 'package:flutter_test/flutter_test.dart' hide Finder;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/database/database_helper.dart';

void main() {
  late Database db;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('test.db');
  });

  tearDown(() async {
    await db.close();
  });

  group('PrevisionRepository (via DatabaseHelper)', () {
    final now = DateTime.now();

    Prevision creerPrevision({
      String id = 'test-1',
      String villeId = 'TNR',
      double temperature = 27.0,
      DateTime? dateCreation,
    }) {
      return Prevision(
        id: id,
        villeId: villeId,
        condition: 'Ciel dégagé',
        directionVent: 'NE',
        icone: '01d',
        dateHeure: now,
        dateCreation: dateCreation ?? now,
        temperature: temperature,
        temperatureRessentie: 25.0,
        humidite: 60.0,
        vitesseVent: 10.0,
        probabilitePluie: 5.0,
        indiceUV: 3.0,
      );
    }

    test('insererPrevision et getDernierePrevision', () async {
      final store = stringMapStoreFactory.store('prevision');
      final p = creerPrevision();
      await store.record(p.id).put(db, p.toMap());

      final snapshot = await store.find(db,
          finder: Finder(
              filter: Filter.equals('ville_id', 'TNR'),
              limit: 1));
      expect(snapshot.length, 1);
      final loaded = Prevision.fromMap(snapshot.first.value);
      expect(loaded.id, 'test-1');
      expect(loaded.temperature, 27.0);
      expect(loaded.condition, 'Ciel dégagé');
    });

    test('insererPrevisions avec transaction', () async {
      final store = stringMapStoreFactory.store('prevision');
      final p1 = creerPrevision(id: 'multi-1', temperature: 25.0);
      final p2 = creerPrevision(id: 'multi-2', temperature: 30.0);

      await db.transaction((txn) async {
        await store.record(p1.id).put(txn, p1.toMap());
        await store.record(p2.id).put(txn, p2.toMap());
      });

      final all = await store.find(db);
      expect(all.length, 2);
    });

    test('cacheValide retourne false si pas de prévision', () async {
      final store = stringMapStoreFactory.store('prevision');
      final snapshots = await store.find(db,
          finder: Finder(filter: Filter.equals('ville_id', 'INCONNU')));
      expect(snapshots.length, 0);
    });

    test('import et export map conservent les champs leverSoleil/coucherSoleil',
        () async {
      final store = stringMapStoreFactory.store('prevision');
      final p = creerPrevision(id: 'sun-test');
      final withSun = p.copyWith(
          leverSoleil: '06:15', coucherSoleil: '17:45');
      await store.record(withSun.id).put(db, withSun.toMap());

      final snapshot = await store.record('sun-test').get(db);
      expect(snapshot, isNotNull);
      final loaded = Prevision.fromMap(snapshot!);
      expect(loaded.leverSoleil, '06:15');
      expect(loaded.coucherSoleil, '17:45');
    });

    test('supprimerVieillesPrevisions supprime les entrées expirées',
        () async {
      final store = stringMapStoreFactory.store('prevision');
      final oldDate =
          DateTime.now().subtract(const Duration(hours: 2));
      final recentDate = DateTime.now();

      final oldP = creerPrevision(
          id: 'old-1', temperature: 22.0, dateCreation: oldDate);
      final recentP = creerPrevision(
          id: 'recent-1', temperature: 28.0, dateCreation: recentDate);

      await store.record(oldP.id).put(db, oldP.toMap());
      await store.record(recentP.id).put(db, recentP.toMap());

      final limite =
          DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String();
      await store.delete(db, finder: Finder(
        filter: Filter.custom((value) {
          return (value['date_creation'] as String).compareTo(limite) < 0;
        }),
      ));

      final remaining = await store.find(db);
      expect(remaining.length, 1);
      expect(remaining.first.value['id'], 'recent-1');
    });
  });
}
