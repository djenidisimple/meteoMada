import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meteomada/models/condition_marine.dart';
import 'package:meteomada/providers/home_state.dart';
import 'package:meteomada/repositories/condition_marine_repository.dart';
import 'package:meteomada/services/api_service.dart';

/// Provider pour les conditions marines (villes côtières uniquement).
///
/// Gère le cycle : cache Sembast → API → fallback.
/// Utilise [HomeDataState] pour que l'UI affiche shimmer, données ou erreur.
class MarineProvider extends ChangeNotifier {
  final _repo = ConditionMarineRepository();
  final _api = ApiService();

  // ─── DONNÉES ────────────────────────────────────────────────
  ConditionMarine? _condition;

  // ─── ÉTAT ───────────────────────────────────────────────────
  HomeDataState _etat = HomeDataState.initial;
  String? _erreur;

  // ─── GETTERS ────────────────────────────────────────────────
  ConditionMarine? get condition => _condition;
  HomeDataState get etat => _etat;
  String? get erreur => _erreur;

  /// Rétro-compatibilité
  bool get chargement => _etat == HomeDataState.loading;

  // ─── CHARGEMENT ─────────────────────────────────────────────
  Future<void> chargerCondition(String villeId, double lat, double lon) async {
    _etat = HomeDataState.loading;
    _erreur = null;
    notifyListeners();

    try {
      // 1. Tenter de charger depuis le cache Sembast d'abord
      final cache = await _repo.getConditionMarine(villeId);
      if (cache != null) {
        _condition = cache;
        _etat = HomeDataState.success;
        notifyListeners();
      }

      // 2. Tenter de rafraîchir depuis l'API
      final marine = await _api.requeteConditionsMarines(lat, lon);
      final avecVille = marine.copyWith(villeId: villeId);

      // 3. Persister dans Sembast pour le mode hors-ligne
      await _repo.insererConditionMarine(avecVille);
      _condition = avecVille;
      _etat = HomeDataState.success;
      _erreur = null;
    } catch (e) {
      debugPrint('[MarineProvider] Erreur chargement: $e');

      // FALLBACK : utiliser les données Sembast en cache
      if (_condition == null) {
        final cache = await _repo.getConditionMarine(villeId);
        _condition = cache;
      }

      if (_condition != null) {
        // On a des données en cache → success avec warning
        _etat = HomeDataState.success;
        _erreur = 'Données marines en cache';
      } else {
        // Aucune donnée → erreur
        _etat = HomeDataState.error;
        _erreur = 'Conditions marines indisponibles';
      }
    }

    // GARANTI : notifyListeners() est toujours appelé
    notifyListeners();
  }
}
