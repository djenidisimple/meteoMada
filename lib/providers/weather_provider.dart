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
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      _villeActuelle = ville;
      _previsionsHoraires = [];

      final valide = await _previsionRepo.cacheValide(ville.id);
      if (valide) {
        _previsionActuelle = await _previsionRepo.getDernierePrevision(ville.id);
        _previsions7Jours = await _previsionRepo.getPrevisions7Jours(ville.id);
      } else {
        await _previsionRepo.supprimerVieillesPrevisions(ville.id);
        final actuelle = await _api.requeteMeteoActuelle(ville.latitude, ville.longitude);
        final p7 = await _api.requetePrevisions7Jours(ville.latitude, ville.longitude);
        final horaires = await _api.requetePrevisionsHoraires(ville.latitude, ville.longitude);

        final avecVille = actuelle.copyWith(villeId: ville.id);
        final p7AvecVille = p7.map((p) => p.copyWith(villeId: ville.id)).toList();
        final hAvecVille = horaires.map((p) => p.copyWith(villeId: ville.id)).toList();

        await _previsionRepo.insererPrevision(avecVille);
        await _previsionRepo.insererPrevisions(p7AvecVille);

        _previsionActuelle = avecVille;
        _previsions7Jours = p7AvecVille;
        _previsionsHoraires = hAvecVille;
      }
      _chargement = false;
      notifyListeners();
    } catch (e) {
      _previsionActuelle = await _previsionRepo.getDernierePrevision(ville.id);
      _chargement = false;
      _erreur = 'Erreur de chargement';
      notifyListeners();
    }
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

extension on Prevision {
  Prevision copyWith({
    String? id,
    String? villeId,
    String? condition,
    String? directionVent,
    String? icone,
    DateTime? dateHeure,
    DateTime? dateCreation,
    double? temperature,
    double? temperatureRessentie,
    double? humidite,
    double? vitesseVent,
    double? probabilitePluie,
    double? indiceUV,
  }) =>
      Prevision(
        id: id ?? this.id,
        villeId: villeId ?? this.villeId,
        condition: condition ?? this.condition,
        directionVent: directionVent ?? this.directionVent,
        icone: icone ?? this.icone,
        dateHeure: dateHeure ?? this.dateHeure,
        dateCreation: dateCreation ?? this.dateCreation,
        temperature: temperature ?? this.temperature,
        temperatureRessentie: temperatureRessentie ?? this.temperatureRessentie,
        humidite: humidite ?? this.humidite,
        vitesseVent: vitesseVent ?? this.vitesseVent,
        probabilitePluie: probabilitePluie ?? this.probabilitePluie,
        indiceUV: indiceUV ?? this.indiceUV,
      );
}
