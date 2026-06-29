import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/providers/home_state.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/repositories/prevision_repository.dart';
import 'package:meteomada/services/api_service.dart';

/// Provider principal de la météo.
///
/// Gère le cycle complet : chargement depuis le cache Sembast → appel API
/// → mise à jour de l'état. Utilise [HomeDataState] pour que l'UI
/// puisse réagir à chaque phase (loading / success / error).
class WeatherProvider extends ChangeNotifier {
  final _villeRepo = VilleRepository();
  final _previsionRepo = PrevisionRepository();
  final _api = ApiService();

  // ─── DONNÉES ────────────────────────────────────────────────
  Ville? _villeActuelle;
  Prevision? _previsionActuelle;
  List<Prevision> _previsions7Jours = [];
  List<Prevision> _previsionsHoraires = [];

  // ─── ÉTAT ───────────────────────────────────────────────────
  HomeDataState _etat = HomeDataState.initial;
  String? _erreur;

  // ─── GETTERS ────────────────────────────────────────────────
  Ville? get villeActuelle => _villeActuelle;
  Prevision? get previsionActuelle => _previsionActuelle;
  List<Prevision> get previsions7Jours => _previsions7Jours;
  List<Prevision> get previsionsHoraires => _previsionsHoraires;
  HomeDataState get etat => _etat;
  String? get erreur => _erreur;

  /// Rétro-compatibilité : le HomeScreen existant utilise `chargement`.
  bool get chargement => _etat == HomeDataState.loading;

  // ─── INITIALISATION ─────────────────────────────────────────
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
    } catch (e) {
      debugPrint('[WeatherProvider] Erreur initialisation: $e');
      _etat = HomeDataState.error;
      _erreur = 'Erreur de démarrage';
      notifyListeners();
    }
  }

  // ─── CHARGEMENT MÉTÉO ───────────────────────────────────────
  Future<void> chargerMeteo(Ville ville) async {
    _erreur = null;
    _villeActuelle = ville;
    _previsionsHoraires = [];

    // 1. Charger depuis le cache Sembast en priorité
    _previsionActuelle =
        await _previsionRepo.getDernierePrevision(ville.id);
    _previsions7Jours =
        await _previsionRepo.getPrevisions7Jours(ville.id);

    // 2. Si le cache est valide, afficher immédiatement et rafraîchir en arrière-plan
    final valide = await _previsionRepo.cacheValide(ville.id);
    if (valide && _previsionActuelle != null) {
      _etat = HomeDataState.success;
      notifyListeners();
      _rafraichirArrierePlan(ville);
    } else {
      // Cache expiré ou vide → afficher le shimmer
      _etat = HomeDataState.loading;
      notifyListeners();
      await _rafraichirArrierePlan(ville);
    }
  }

  // ─── RAFRAÎCHISSEMENT API ───────────────────────────────────
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

      // Persister dans Sembast pour le mode hors-ligne
      await _previsionRepo.supprimerVieillesPrevisions(ville.id);
      await _previsionRepo.insererPrevision(actuelle);
      await _previsionRepo.insererPrevisions(p7);

      _previsionActuelle = actuelle;
      _previsions7Jours = p7;
      _previsionsHoraires = horaires;
      _etat = HomeDataState.success;
      _erreur = null;
    } catch (e) {
      debugPrint('[WeatherProvider] Erreur rafraîchissement: $e');

      // FALLBACK : utiliser les données Sembast en cache
      _previsionActuelle ??=
          await _previsionRepo.getDernierePrevision(ville.id);

      // Si on a des données en cache, on passe en success avec un warning
      if (_previsionActuelle != null) {
        _etat = HomeDataState.success;
        _erreur = 'Données en cache (hors ligne)';
      } else {
        // Aucune donnée disponible → erreur
        _etat = HomeDataState.error;
        _erreur = 'Impossible de charger la météo';
      }
    }
    // GARANTI : notifyListeners() est toujours appelé
    notifyListeners();
  }

  // ─── CHARGEMENT PAR COORDONNÉES ─────────────────────────────
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
