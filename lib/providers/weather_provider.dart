import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/repositories/prevision_repository.dart';
import 'package:meteomada/services/api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _villeRepo = VilleRepository();
  final _previsionRepo = PrevisionRepository();
  final _api = ApiService();

  Ville? _villeActuelle;
  Prevision? _previsionActuelle;
  List<Prevision> _previsions7Jours = [];
  List<Prevision> _previsionsHoraires = [];
  bool _chargement = false;
  String? _erreur;

  Ville? get villeActuelle => _villeActuelle;
  Prevision? get previsionActuelle => _previsionActuelle;
  List<Prevision> get previsions7Jours => _previsions7Jours;
  List<Prevision> get previsionsHoraires => _previsionsHoraires;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  Future<void> initialiser() async {
    try {
      _villeActuelle = await _villeRepo.getVilleParId('TNR');
      if (_villeActuelle != null) {
        await chargerMeteo(_villeActuelle!);
      }
      _api.demarrerPolling(() async {
        if (_villeActuelle != null) {
          await chargerMeteo(_villeActuelle!);
        }
      });
    } catch (_) {
      _chargement = false;
      _erreur = 'Erreur de démarrage';
      notifyListeners();
    }
  }

  Future<void> chargerMeteo(Ville ville) async {
    _erreur = null;
    _villeActuelle = ville;
    _previsionsHoraires = [];

    _previsionActuelle =
        await _previsionRepo.getDernierePrevision(ville.id);
    _previsions7Jours =
        await _previsionRepo.getPrevisions7Jours(ville.id);

    final valide = await _previsionRepo.cacheValide(ville.id);
    if (valide && _previsionActuelle != null) {
      _chargement = false;
      notifyListeners();
      _rafraichirArrierePlan(ville);
    } else {
      _chargement = true;
      notifyListeners();
      await _rafraichirArrierePlan(ville);
    }
  }

  Future<void> _rafraichirArrierePlan(Ville ville) async {
    try {
      final results = await Future.wait([
        _api.requeteMeteoActuelle(ville.latitude, ville.longitude),
        _api.requetePrevisions7Jours(ville.latitude, ville.longitude),
        _api.requetePrevisionsHoraires(ville.latitude, ville.longitude),
      ]);

      final actuelle = (results[0] as Prevision).copyWith(villeId: ville.id);
      final p7 = (results[1] as List<Prevision>)
          .map((p) => p.copyWith(villeId: ville.id))
          .toList();
      final horaires = (results[2] as List<Prevision>)
          .map((p) => p.copyWith(villeId: ville.id))
          .toList();

      await _previsionRepo.supprimerVieillesPrevisions(ville.id);
      await _previsionRepo.insererPrevision(actuelle);
      await _previsionRepo.insererPrevisions(p7);

      _previsionActuelle = actuelle;
      _previsions7Jours = p7;
      _previsionsHoraires = horaires;
      _chargement = false;
      _erreur = null;
    } catch (_) {
      _previsionActuelle ??=
          await _previsionRepo.getDernierePrevision(ville.id);
      _chargement = false;
      _erreur = 'Erreur de chargement';
    }
    notifyListeners();
  }

  Future<void> chargerPourVilleDepuisCoords(double lat, double lon) async {
    final id = GeocodingId.generer(lat, lon);
    var ville = await _villeRepo.getVilleParId(id);
    if (ville == null) {
      ville = Ville(
        id: id,
        nom: 'Position $lat, $lon',
        region: 'Madagascar',
        latitude: lat,
        longitude: lon,
        altitude: 0,
        fuseauHoraire: 'Indian/Antananarivo',
        estCotiere: false,
      );
      await _villeRepo.insererVille(ville);
    }
    await chargerMeteo(ville);
  }

  void mettreAJourVille(Ville ville) {
    _villeActuelle = ville;
    notifyListeners();
  }

  Future<void> chargerPourDefaut() async {
    _villeActuelle = await _villeRepo.getVilleParId('TNR');
    if (_villeActuelle != null) {
      await chargerMeteo(_villeActuelle!);
    }
  }

  @override
  void dispose() {
    _api.arreterPolling();
    super.dispose();
  }
}

class GeocodingId {
  static String generer(double lat, double lon) {
    return 'loc_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }
}
