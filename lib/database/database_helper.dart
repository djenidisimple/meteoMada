import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart' as sembast_web;
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _initialisationEnCours = false;

  final villeStore = stringMapStoreFactory.store('ville');
  final previsionStore = stringMapStoreFactory.store('prevision');
  final conditionMarineStore = stringMapStoreFactory.store('condition_marine');
  final utilisateurStore = stringMapStoreFactory.store('utilisateur');
  final favoriStore = stringMapStoreFactory.store('favori');
  final alerteCycloneStore = stringMapStoreFactory.store('alerte_cyclone');
  final alerteRegionStore = stringMapStoreFactory.store('alerte_region');
  final calendrierCulturalStore = stringMapStoreFactory.store('calendrier_cultural');
  final notificationStore = stringMapStoreFactory.store('notification');

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_initialisationEnCours) {
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_database != null) return _database!;
        if (!_initialisationEnCours) break;
      }
    }
    if (_database != null) return _database!;
    _initialisationEnCours = true;
    try {
      _database = await _initDatabase();
      await _insertInitialData();
    } finally {
      _initialisationEnCours = false;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      return await sembast_web.databaseFactoryWeb.openDatabase('meteomada');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return await sembast_io.databaseFactoryIo.openDatabase('${dir.path}/meteomada.db');
    }
  }

  Future<void> _insertInitialData() async {
    final db = await database;

    final userExists = await utilisateurStore.record('default_user').get(db);
    if (userExists != null) return;

    await utilisateurStore.record('default_user').put(db, {
      'id': 'default_user',
      'pseudo': 'Utilisateur',
      'langue_preferee': 'fr',
      'type_utilisateur': 'standard',
      'alertes_cyclone_activees': 1,
      'alertes_pluie_activees': 0,
    });

    final villes = [
      {'id': 'TNR', 'nom': 'Antananarivo', 'region': 'Analamanga', 'latitude': -18.8792, 'longitude': 47.5079, 'altitude': 1276, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'TOA', 'nom': 'Toamasina', 'region': 'Atsinanana', 'latitude': -18.1443, 'longitude': 49.3958, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'MJV', 'nom': 'Mahajanga', 'region': 'Boeny', 'latitude': -15.7167, 'longitude': 46.3167, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'TLE', 'nom': 'Toliara', 'region': 'Atsimo-Andrefana', 'latitude': -23.3500, 'longitude': 43.6667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'ANT', 'nom': 'Antsiranana', 'region': 'Diana', 'latitude': -12.2667, 'longitude': 49.2833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'FNR', 'nom': 'Fianarantsoa', 'region': 'Haute Matsiatra', 'latitude': -21.4333, 'longitude': 47.0833, 'altitude': 1200, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'TMM', 'nom': 'Taolagnaro', 'region': 'Anosy', 'latitude': -25.0167, 'longitude': 46.9833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'AMP', 'nom': 'Antsirabe', 'region': 'Vakinankaratra', 'latitude': -19.8667, 'longitude': 47.0333, 'altitude': 1500, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'MOR', 'nom': 'Morondava', 'region': 'Menabe', 'latitude': -20.2833, 'longitude': 44.2833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'AMB', 'nom': 'Ambatondrazaka', 'region': 'Alaotra-Mangoro', 'latitude': -17.8333, 'longitude': 48.4167, 'altitude': 768, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'MAN', 'nom': 'Manakara', 'region': 'Vatovavy-Fitovinany', 'latitude': -22.1333, 'longitude': 48.0167, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'FEN', 'nom': 'Fenoarivo Atsinanana', 'region': 'Analanjirofo', 'latitude': -17.3833, 'longitude': 49.4167, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'BES', 'nom': 'Besalampy', 'region': 'Melaky', 'latitude': -16.7500, 'longitude': 44.4833, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'IHA', 'nom': 'Ihosy', 'region': 'Ihorombe', 'latitude': -22.4000, 'longitude': 46.1167, 'altitude': 733, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'MIA', 'nom': 'Miarinarivo', 'region': 'Itasy', 'latitude': -18.9500, 'longitude': 46.9000, 'altitude': 1250, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'MRO', 'nom': 'Maroantsetra', 'region': 'Analanjirofo', 'latitude': -15.4333, 'longitude': 49.7333, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'NOS', 'nom': 'Nosy Be', 'region': 'Diana', 'latitude': -13.3000, 'longitude': 48.2667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'FAR', 'nom': 'Farafangana', 'region': 'Atsimo-Atsinanana', 'latitude': -22.8167, 'longitude': 47.8333, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'MDB', 'nom': 'Mandritsara', 'region': 'Sofia', 'latitude': -15.8333, 'longitude': 48.8167, 'altitude': 300, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'SAM', 'nom': 'Sambava', 'region': 'Sava', 'latitude': -14.2667, 'longitude': 50.1667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
      {'id': 'VOH', 'nom': 'Vohibinany', 'region': 'Analanjirofo', 'latitude': -17.3500, 'longitude': 49.0333, 'altitude': 80, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'BEF', 'nom': 'Befandriana Avaratra', 'region': 'Sofia', 'latitude': -15.2500, 'longitude': 48.1333, 'altitude': 100, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 0},
      {'id': 'ANR', 'nom': 'Antalaha', 'region': 'Sava', 'latitude': -14.8833, 'longitude': 50.2667, 'altitude': 6, 'fuseau_horaire': 'Indian/Antananarivo', 'est_cotiere': 1},
    ];
    for (final v in villes) {
      await villeStore.record(v['id'] as String).put(db, v);
    }

    final calendriers = [
      {'id': 'CC001', 'region': 'Analamanga', 'type_culture': 'Riz', 'mois_semis_debut': 10, 'mois_semis_fin': 12, 'mois_recolte_debut': 3, 'mois_recolte_fin': 5, 'conseils_meteo': 'Semer en début de saison des pluies. Récolter avant la saison sèche.'},
      {'id': 'CC002', 'region': 'Boeny', 'type_culture': 'Riz', 'mois_semis_debut': 11, 'mois_semis_fin': 1, 'mois_recolte_debut': 4, 'mois_recolte_fin': 6, 'conseils_meteo': 'Riz inondé adapté aux plaines du Boeny.'},
      {'id': 'CC003', 'region': 'Haute Matsiatra', 'type_culture': 'Maïs', 'mois_semis_debut': 10, 'mois_semis_fin': 11, 'mois_recolte_debut': 2, 'mois_recolte_fin': 3, 'conseils_meteo': 'Culture pluviale. Surveiller les précipitations.'},
      {'id': 'CC004', 'region': 'Atsimo-Andrefana', 'type_culture': 'Manioc', 'mois_semis_debut': 9, 'mois_semis_fin': 12, 'mois_recolte_debut': 15, 'mois_recolte_fin': 18, 'conseils_meteo': 'Résistant à la sécheresse. Plantation en début de saison humide.'},
      {'id': 'CC005', 'region': 'Analamanga', 'type_culture': 'Haricot', 'mois_semis_debut': 2, 'mois_semis_fin': 4, 'mois_recolte_debut': 4, 'mois_recolte_fin': 6, 'conseils_meteo': 'Culture de contre-saison. Arrosage régulier nécessaire.'},
      {'id': 'CC006', 'region': 'Vakinankaratra', 'type_culture': 'Pomme de terre', 'mois_semis_debut': 8, 'mois_semis_fin': 10, 'mois_recolte_debut': 11, 'mois_recolte_fin': 1, 'conseils_meteo': 'Climat frais idéal. Éviter les excès d\'eau.'},
      {'id': 'CC007', 'region': 'Diana', 'type_culture': 'Vanille', 'mois_semis_debut': 3, 'mois_semis_fin': 5, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Culture pérenne. Protection contre les cyclones essentielle.'},
      {'id': 'CC008', 'region': 'Menabe', 'type_culture': 'Arachide', 'mois_semis_debut': 10, 'mois_semis_fin': 12, 'mois_recolte_debut': 2, 'mois_recolte_fin': 4, 'conseils_meteo': 'Sol sableux idéal. Semer après les premières pluies.'},
      {'id': 'CC009', 'region': 'Atsinanana', 'type_culture': 'Café', 'mois_semis_debut': 11, 'mois_semis_fin': 1, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Ombre nécessaire. Récolte manuelle des cerises mûres.'},
      {'id': 'CC010', 'region': 'Sava', 'type_culture': 'Cacao', 'mois_semis_debut': 12, 'mois_semis_fin': 2, 'mois_recolte_debut': 24, 'mois_recolte_fin': 36, 'conseils_meteo': 'Climat humide et chaud. Protection contre les vents forts.'},
    ];
    for (final c in calendriers) {
      await calendrierCulturalStore.record(c['id'] as String).put(db, c);
    }
  }

  Future<void> peuplerSiVide() async {
    final db = await database;
    final count = await villeStore.count(db);
    if (count == 0) {
      await _insertInitialData();
    }
  }
}
