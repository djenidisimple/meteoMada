import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/providers/home_state.dart';
import 'package:meteomada/repositories/calendrier_repository.dart';

/// Provider pour le calendrier cultural agricole de Madagascar.
///
/// Charge les données depuis Sembast. Utilise [HomeDataState] pour
/// que l'UI puisse réagir à chaque phase (loading / success / error).
class CalendrierProvider extends ChangeNotifier {
  final _repo = CalendrierRepository();

  // ─── DONNÉES ────────────────────────────────────────────────
  List<CalendrierCultural> _donnees = [];
  List<String> _regions = [];
  String? _regionSelectionnee;
  String _recherche = '';

  // ─── ÉTAT ───────────────────────────────────────────────────
  HomeDataState _etat = HomeDataState.initial;
  String? _erreur;

  // ─── GETTERS ────────────────────────────────────────────────
  List<CalendrierCultural> get donnees => _donnees;
  HomeDataState get etat => _etat;
  String? get erreur => _erreur;
  List<String> get regions => _regions;
  String? get regionSelectionnee => _regionSelectionnee;

  /// Rétro-compatibilité
  bool get chargement => _etat == HomeDataState.loading;

  /// Liste filtrée par région et/ou recherche textuelle.
  List<CalendrierCultural> get filtered {
    var result = _donnees;
    if (_regionSelectionnee != null) {
      result = result.where((c) => c.region == _regionSelectionnee).toList();
    }
    if (_recherche.isNotEmpty) {
      final q = _recherche.toLowerCase();
      result = result.where((c) =>
        c.typeCultureLabel.toLowerCase().contains(q) ||
        c.region.toLowerCase().contains(q)
      ).toList();
    }
    return result;
  }

  // ─── INITIALISATION ─────────────────────────────────────────
  Future<void> initialiser() async {
    _etat = HomeDataState.loading;
    _erreur = null;
    notifyListeners();

    try {
      _donnees = await _repo.fetchCalendrier(); // Appelle le flux sécurisé
      _regions = _donnees.map((c) => c.region).toSet().toList()..sort();

      if (_donnees.isNotEmpty) {
        _etat = HomeDataState.success;
      } else {
        _etat = HomeDataState.error; 
        _erreur = 'Aucun calendrier disponible.';
      }
    } catch (e) {
      debugPrint('[CalendrierProvider] Erreur initialisation: $e');
      _etat = HomeDataState.error;
      _erreur = 'Impossible de charger le calendrier';
    } finally {
      // GARANTI : notifyListeners() est SYSTÉMATIQUEMENT appelé à la fin,
      // libérant ainsi l'UI de l'état 'loading' même en cas de crash.
      notifyListeners();
    }
  }

  // ─── FILTRES ────────────────────────────────────────────────
  void setRecherche(String value) {
    _recherche = value;
    notifyListeners();
  }

  void setRegion(String? region) {
    _regionSelectionnee = region;
    _recherche = '';
    notifyListeners();
  }

  // ─── CHARGEMENT PAR RÉGION ──────────────────────────────────
  Future<void> chargerCalendrier(String region) async {
    _etat = HomeDataState.loading;
    _erreur = null;
    notifyListeners();

    try {
      _donnees = await _repo.getCalendrierParRegion(region);
      _regionSelectionnee = region;
      _etat = HomeDataState.success;
      _erreur = null;
    } catch (e) {
      debugPrint('[CalendrierProvider] Erreur chargement région: $e');
      _etat = HomeDataState.error;
      _erreur = 'Erreur de chargement du calendrier';
    }

    // GARANTI : notifyListeners() est toujours appelé
    notifyListeners();
  }
}
