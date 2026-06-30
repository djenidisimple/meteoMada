import 'package:sembast/sembast.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/models/calendrier_cultural.dart';

class CalendrierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  StoreRef<String, Map<String, dynamic>> get _store => _dbHelper.calendrierCulturalStore;

  /// Tente de récupérer les données depuis le store local.
  /// Si le store est vide, insère les données initiales.
  Future<List<CalendrierCultural>> fetchCalendrier() async {
    final db = await _dbHelper.database;
    var snapshots = await _store.find(db);
    if (snapshots.isEmpty) {
      await _seedDonnees(db);
      snapshots = await _store.find(db);
    }
    return snapshots.map((s) => CalendrierCultural.fromMap(s.value)).toList();
  }

  Future<void> _seedDonnees(Database db) async {
    final calendriers = [
      {'id': 'CC001', 'region': 'Analamanga', 'type_culture': 'vary', 'mois_semis_debut': 10, 'mois_semis_fin': 12, 'mois_recolte_debut': 3, 'mois_recolte_fin': 5, 'conseils_meteo': 'Semer en début de saison des pluies. Récolter avant la saison sèche.'},
      {'id': 'CC002', 'region': 'Boeny', 'type_culture': 'vary', 'mois_semis_debut': 11, 'mois_semis_fin': 1, 'mois_recolte_debut': 4, 'mois_recolte_fin': 6, 'conseils_meteo': 'Riz inondé adapté aux plaines du Boeny.'},
      {'id': 'CC003', 'region': 'Haute Matsiatra', 'type_culture': 'katsaka', 'mois_semis_debut': 10, 'mois_semis_fin': 11, 'mois_recolte_debut': 2, 'mois_recolte_fin': 3, 'conseils_meteo': 'Culture pluviale. Surveiller les précipitations.'},
      {'id': 'CC004', 'region': 'Atsimo-Andrefana', 'type_culture': 'mangahazo', 'mois_semis_debut': 9, 'mois_semis_fin': 12, 'mois_recolte_debut': 15, 'mois_recolte_fin': 18, 'conseils_meteo': 'Résistant à la sécheresse. Plantation en début de saison humide.'},
      {'id': 'CC005', 'region': 'Analamanga', 'type_culture': 'haricot', 'mois_semis_debut': 2, 'mois_semis_fin': 4, 'mois_recolte_debut': 4, 'mois_recolte_fin': 6, 'conseils_meteo': 'Culture de contre-saison. Arrosage régulier nécessaire.'},
      {'id': 'CC006', 'region': 'Vakinankaratra', 'type_culture': 'pomme_de_terre', 'mois_semis_debut': 8, 'mois_semis_fin': 10, 'mois_recolte_debut': 11, 'mois_recolte_fin': 1, 'conseils_meteo': 'Climat frais idéal. Éviter les excès d\'eau.'},
      {'id': 'CC007', 'region': 'Diana', 'type_culture': 'vanille', 'mois_semis_debut': 3, 'mois_semis_fin': 5, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Culture pérenne. Protection contre les cyclones essentielle.'},
      {'id': 'CC008', 'region': 'Menabe', 'type_culture': 'arachide', 'mois_semis_debut': 10, 'mois_semis_fin': 12, 'mois_recolte_debut': 2, 'mois_recolte_fin': 4, 'conseils_meteo': 'Sol sableux idéal. Semer après les premières pluies.'},
      {'id': 'CC009', 'region': 'Atsinanana', 'type_culture': 'cafe', 'mois_semis_debut': 11, 'mois_semis_fin': 1, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Ombre nécessaire. Récolte manuelle des cerises mûres.'},
      {'id': 'CC010', 'region': 'Sava', 'type_culture': 'cacao', 'mois_semis_debut': 12, 'mois_semis_fin': 2, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Climat humide et chaud. Protection contre les vents forts.'},
    ];
    for (final c in calendriers) {
      await _store.record(c['id'] as String).put(db, c);
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
