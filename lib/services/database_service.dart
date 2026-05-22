import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart' as sembast_web;
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:path_provider/path_provider.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/models/utilisateur.dart';
import 'package:meteomada/models/favori.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:meteomada/models/calendrier_cultural.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;
  bool _initializing = false;

  final villes = stringMapStoreFactory.store('ville');
  final previsions = stringMapStoreFactory.store('prevision');
  final conditionsMarines = stringMapStoreFactory.store('condition_marine');
  final utilisateurs = stringMapStoreFactory.store('utilisateur');
  final favoris = stringMapStoreFactory.store('favori');
  final alertesCyclone = stringMapStoreFactory.store('alerte_cyclone');
  final alertesRegions = stringMapStoreFactory.store('alerte_region');
  final calendriers = stringMapStoreFactory.store('calendrier_cultural');
  final notifications = stringMapStoreFactory.store('notification');

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_initializing) {
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_db != null) return _db!;
      }
    }
    _initializing = true;
    try {
      _db = await _initDb();
      await _seedInitialData();
    } finally {
      _initializing = false;
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      return await sembast_web.databaseFactoryWeb.openDatabase('toerana');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return await sembast_io.databaseFactoryIo
          .openDatabase('${dir.path}/toerana.db');
    }
  }

  Future<void> _seedInitialData() async {
    final db = await database;
    final existing = await villes.count(db);
    if (existing > 0) return;

    final data = [
      {'id': 'TNR', 'nom': 'Antananarivo', 'region': 'Analamanga', 'latitude': -18.8792, 'longitude': 47.5079, 'altitude': 1276, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'TOA', 'nom': 'Toamasina', 'region': 'Atsinanana', 'latitude': -18.1443, 'longitude': 49.3958, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'MJV', 'nom': 'Mahajanga', 'region': 'Boeny', 'latitude': -15.7167, 'longitude': 46.3167, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'TLE', 'nom': 'Toliara', 'region': 'Atsimo-Andrefana', 'latitude': -23.3500, 'longitude': 43.6667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'ANT', 'nom': 'Antsiranana', 'region': 'Diana', 'latitude': -12.2667, 'longitude': 49.2833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'FNR', 'nom': 'Fianarantsoa', 'region': 'Haute Matsiatra', 'latitude': -21.4333, 'longitude': 47.0833, 'altitude': 1200, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'TMM', 'nom': "Taolagnaro", 'region': 'Anosy', 'latitude': -25.0167, 'longitude': 46.9833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'NOS', 'nom': 'Nosy Be', 'region': 'Diana', 'latitude': -13.3000, 'longitude': 48.2667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
    ];
    for (final v in data) {
      await villes.record(v['id'] as String).put(db, v);
    }

    await utilisateurs.record('default_user').put(db, {
      'id': 'default_user',
      'pseudo': 'Utilisateur',
      'langue_preferee': 'fr',
      'type_utilisateur': 'citoyen',
      'alertes_cyclone_activees': 1,
      'alertes_pluie_activees': 0,
    });

    final calendriersData = [
      {'id': 'CC001', 'region': 'Analamanga', 'type_culture': 'vary', 'mois_semis_debut': 10, 'mois_semis_fin': 12, 'mois_recolte_debut': 3, 'mois_recolte_fin': 5, 'conseils_meteo': 'Semer en début de saison des pluies. Récolter avant la saison sèche.'},
      {'id': 'CC002', 'region': 'Boeny', 'type_culture': 'vary', 'mois_semis_debut': 11, 'mois_semis_fin': 1, 'mois_recolte_debut': 4, 'mois_recolte_fin': 6, 'conseils_meteo': 'Riz inondé adapté aux plaines du Boeny.'},
      {'id': 'CC003', 'region': 'Haute Matsiatra', 'type_culture': 'katsaka', 'mois_semis_debut': 10, 'mois_semis_fin': 11, 'mois_recolte_debut': 2, 'mois_recolte_fin': 3, 'conseils_meteo': 'Culture pluviale. Surveiller les précipitations.'},
      {'id': 'CC004', 'region': 'Atsimo-Andrefana', 'type_culture': 'mangahazo', 'mois_semis_debut': 9, 'mois_semis_fin': 12, 'mois_recolte_debut': 15, 'mois_recolte_fin': 18, 'conseils_meteo': 'Résistant à la sécheresse. Plantation en début de saison humide.'},
    ];
    for (final c in calendriersData) {
      await calendriers.record(c['id'] as String).put(db, c);
    }
  }

  // ─── VILLES ──────────────────────────────────────────────
  Future<List<Ville>> getAllVilles() async {
    final db = await database;
    final snapshots = await villes.find(db,
        finder: Finder(sortOrders: [SortOrder('nom')]));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  Future<Ville?> getVilleParId(String id) async {
    final db = await database;
    final map = await villes.record(id).get(db);
    if (map == null) return null;
    return Ville.fromMap(map);
  }

  Future<Ville?> getVilleParCoordonnees(double lat, double lon) async {
    final db = await database;
    const tol = 0.5;
    final snapshots = await villes.find(db, finder: Finder(
      filter: Filter.and([
        Filter.custom((v) =>
            (v['latitude'] as num).toDouble() >= lat - tol &&
            (v['latitude'] as num).toDouble() <= lat + tol),
        Filter.custom((v) =>
            (v['longitude'] as num).toDouble() >= lon - tol &&
            (v['longitude'] as num).toDouble() <= lon + tol),
      ]),
      limit: 1,
    ));
    if (snapshots.isEmpty) return null;
    return Ville.fromMap(snapshots.first.value);
  }

  Future<List<Ville>> rechercherVilles(String terme) async {
    final db = await database;
    final t = terme.toLowerCase();
    final snapshots = await villes.find(db, finder: Finder(
      filter: Filter.custom((v) {
        final nom = (v['nom'] as String).toLowerCase();
        final region = (v['region'] as String).toLowerCase();
        return nom.contains(t) || region.contains(t);
      }),
      sortOrders: [SortOrder('nom')],
    ));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  Future<List<Ville>> getVillesCotieres() async {
    final db = await database;
    final snapshots = await villes.find(db, finder: Finder(
      filter: Filter.equals('est_cotiere', 1),
      sortOrders: [SortOrder('nom')],
    ));
    return snapshots.map((s) => Ville.fromMap(s.value)).toList();
  }

  // ─── PREVISIONS ──────────────────────────────────────────
  Future<Prevision?> getPrevisionActive(String villeId) async {
    final db = await database;
    final snapshots = await previsions.find(db, finder: Finder(
      filter: Filter.equals('ville_id', villeId),
      sortOrders: [SortOrder('date_creation', false)],
      limit: 1,
    ));
    if (snapshots.isEmpty) return null;
    return Prevision.fromMap(snapshots.first.value);
  }

  Future<bool> estExpiree(String villeId) async {
    final p = await getPrevisionActive(villeId);
    if (p == null) return true;
    return p.estExpiree();
  }

  Future<void> supprimerVieillesPrevisions(String villeId) async {
    final db = await database;
    final limite =
        DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String();
    await previsions.delete(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.custom((v) =>
            (v['date_creation'] as String).compareTo(limite) < 0),
      ]),
    ));
  }

  Future<void> sauvegarderPrevision(Prevision p) async {
    final db = await database;
    await previsions.record(p.id).put(db, p.toMap());
  }

  Future<void> sauvegarderPrevisions(List<Prevision> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final p in list) {
        await previsions.record(p.id).put(txn, p.toMap());
      }
    });
  }

  // ─── FAVORIS ─────────────────────────────────────────────
  Future<List<Favori>> getFavoris(String userId) async {
    final db = await database;
    final snapshots = await favoris.find(db, finder: Finder(
      filter: Filter.equals('utilisateur_id', userId),
      sortOrders: [SortOrder('ordre_affichage')],
    ));
    return snapshots.map((s) => Favori.fromMap(s.value)).toList();
  }

  Future<void> ajouterFavori(Favori f) async {
    final db = await database;
    await favoris.record(f.id).put(db, f.toMap());
  }

  Future<void> supprimerFavori(String id) async {
    final db = await database;
    await favoris.record(id).delete(db);
  }

  Future<void> mettreAJourOrdre(List<Favori> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < list.length; i++) {
        final record = await favoris.record(list[i].id).get(txn);
        if (record != null) {
          final updated = Map<String, dynamic>.from(record);
          updated['ordre_affichage'] = i;
          await favoris.record(list[i].id).put(txn, updated);
        }
      }
    });
  }

  Future<void> mettreAJourFavori(Favori f) async {
    final db = await database;
    await favoris.record(f.id).put(db, f.toMap());
  }

  Future<bool> estFavori(String villeId, String userId) async {
    final db = await database;
    final results = await favoris.find(db, finder: Finder(
      filter: Filter.and([
        Filter.equals('ville_id', villeId),
        Filter.equals('utilisateur_id', userId),
      ]),
    ));
    return results.isNotEmpty;
  }

  // ─── UTILISATEUR ─────────────────────────────────────────
  Future<Utilisateur?> getUtilisateur(String id) async {
    final db = await database;
    final map = await utilisateurs.record(id).get(db);
    if (map == null) return null;
    return Utilisateur.fromMap(map);
  }

  Future<void> sauvegarderUtilisateur(Utilisateur u) async {
    final db = await database;
    await utilisateurs.record(u.id).put(db, u.toMap());
  }

  // ─── ALERTES ─────────────────────────────────────────────
  Future<List<AlerteCyclone>> getAlertesActives() async {
    final db = await database;
    final snapshots = await alertesCyclone.find(db, finder: Finder(
      filter: Filter.equals('est_active', 1),
      sortOrders: [SortOrder('date_emission', false)],
    ));
    return snapshots.map((s) => AlerteCyclone.fromMap(s.value)).toList();
  }

  Future<List<AlerteCyclone>> getToutesAlertes() async {
    final db = await database;
    final snapshots = await alertesCyclone.find(db,
        finder: Finder(sortOrders: [SortOrder('date_emission', false)]));
    return snapshots.map((s) => AlerteCyclone.fromMap(s.value)).toList();
  }

  Future<void> sauvegarderAlerte(AlerteCyclone a) async {
    final db = await database;
    await alertesCyclone.record(a.id).put(db, a.toMap());
  }

  // ─── CALENDRIER ──────────────────────────────────────────
  Future<List<CalendrierCultural>> getCalendrierParRegion(
      String region) async {
    final db = await database;
    final snapshots = await calendriers.find(db, finder: Finder(
      filter: Filter.equals('region', region),
      sortOrders: [SortOrder('type_culture')],
    ));
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<List<String>> getToutesRegions() async {
    final db = await database;
    final snapshots = await calendriers.find(db);
    return snapshots
        .map((s) => s.value['region'] as String)
        .toSet()
        .toList()
      ..sort();
  }
}
