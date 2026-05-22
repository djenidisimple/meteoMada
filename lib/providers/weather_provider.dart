import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/services/database_service.dart';
import 'package:meteomada/services/api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _api = ApiService();

  Ville? _villeActuelle;
  Prevision? _previsionActuelle;
  List<Prevision> _previsions7Jours = [];
  bool _chargement = false;
  String? _erreur;

  Ville? get villeActuelle => _villeActuelle;
  Prevision? get previsionActuelle => _previsionActuelle;
  List<Prevision> get previsions7Jours => _previsions7Jours;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  Future<void> initialiser() async {
    _villeActuelle = await _db.getVilleParId('TNR');
    if (_villeActuelle != null) {
      await chargerMeteo(_villeActuelle!);
    }
    _api.demarrerPolling(() async {
      if (_villeActuelle != null) {
        await chargerMeteo(_villeActuelle!);
      }
    });
  }

  Future<void> chargerMeteo(Ville ville) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      _villeActuelle = ville;
      final active = await _db.getPrevisionActive(ville.id);
      if (active != null && !active.estExpiree()) {
        _previsionActuelle = active;
      } else {
        await _db.supprimerVieillesPrevisions(ville.id);
        final actuelle = await _api.requeteMeteoActuelle(ville.latitude, ville.longitude);
        final p7 = await _api.requetePrevisions7Jours(ville.latitude, ville.longitude);

        final avecVille = actuelle.copyWith(villeId: ville.id);
        final p7AvecVille = p7.map((p) => p.copyWith(villeId: ville.id)).toList();

        await _db.sauvegarderPrevision(avecVille);
        await _db.sauvegarderPrevisions(p7AvecVille);

        _previsionActuelle = avecVille;
        _previsions7Jours = p7AvecVille;
      }
      _chargement = false;
      notifyListeners();
    } catch (e) {
      final active = await _db.getPrevisionActive(ville.id);
      _previsionActuelle = active;
      _chargement = false;
      _erreur = 'Erreur de chargement';
      notifyListeners();
    }
  }

  Future<void> chargerPourPosition(double lat, double lon) async {
    final ville = await _db.getVilleParCoordonnees(lat, lon);
    if (ville != null) {
      await chargerMeteo(ville);
    }
  }

  Future<void> chargerPourDefaut() async {
    _villeActuelle = await _db.getVilleParId('TNR');
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
