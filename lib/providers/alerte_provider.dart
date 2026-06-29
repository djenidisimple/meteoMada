import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:meteomada/providers/home_state.dart';
import 'package:meteomada/repositories/alerte_repository.dart';
import 'package:meteomada/services/api_service.dart';
import 'package:meteomada/services/notification_service.dart';

/// Provider pour les alertes cycloniques.
///
/// Gère la synchronisation des alertes depuis l'API et le cache Sembast.
/// Utilise [HomeDataState] pour que l'UI puisse réagir correctement.
class AlerteProvider extends ChangeNotifier {
  final _repo = AlerteRepository();
  final _api = ApiService();
  final _notif = NotificationService();

  // ─── DONNÉES ────────────────────────────────────────────────
  List<AlerteCyclone> _actives = [];
  List<AlerteCyclone> _historique = [];
  String? _filtreRegion;
  Timer? _pollingTimer;

  // ─── ÉTAT ───────────────────────────────────────────────────
  HomeDataState _etat = HomeDataState.initial;
  String? _erreur;

  // ─── GETTERS ────────────────────────────────────────────────
  List<AlerteCyclone> get actives => _actives;
  List<AlerteCyclone> get historique => _historique;
  List<AlerteCyclone> get toutes => [..._actives, ..._historique];
  String? get filtreRegion => _filtreRegion;
  HomeDataState get etat => _etat;
  String? get erreur => _erreur;
  int get countActives => _actives.length;

  /// Rétro-compatibilité
  bool get chargement => _etat == HomeDataState.loading;

  /// Liste filtrée par région.
  List<AlerteCyclone> get filtrees {
    if (_filtreRegion == null) return toutes;
    return toutes
        .where((a) => a.regions.any((r) =>
            r.toLowerCase().contains(_filtreRegion!.toLowerCase())))
        .toList();
  }

  // ─── INITIALISATION ─────────────────────────────────────────
  Future<void> initialiser() async {
    _etat = HomeDataState.loading;
    _erreur = null;
    notifyListeners();

    try {
      await _notif.initialiser();
      _actives = await _repo.getAlertesActives();
      _historique = (await _repo.getToutesAlertes())
          .where((a) => !a.estActive)
          .toList();
      _etat = HomeDataState.success;
      _erreur = null;
    } catch (e) {
      debugPrint('[AlerteProvider] Erreur initialisation: $e');
      _etat = HomeDataState.error;
      _erreur = 'Impossible de charger les alertes';
    }

    // GARANTI : notifyListeners() est toujours appelé
    notifyListeners();

    // Polling toutes les 30 minutes pour synchroniser les alertes
    _pollingTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      await _synchroniserAlertes();
    });
  }

  // ─── SYNCHRONISATION API ────────────────────────────────────
  Future<void> _synchroniserAlertes() async {
    try {
      final apiAlertes = await _api.requeteAlertesActives();
      for (final a in apiAlertes) {
        final existe = await _repo.alerteExistante(a.id);
        if (!existe) {
          await _repo.insererAlerte(a);
          await _repo.insererRegions(a.id, a.regions);
          if (a.niveau == 'alerte_orange' || a.niveau == 'alerte_rouge') {
            _notif.creerNotificationAlerte(a);
          }
        } else {
          final existante = await _repo.getDetailsAlerte(a.id);
          if (existante != null && existante.niveau != a.niveau) {
            await _repo.mettreAJourAlerte(a);
            await _repo.mettreAJourRegions(a.id, a.regions);
            _notif.creerNotificationMiseAJour(a);
          }
        }
      }
      _actives = await _repo.getAlertesActives();
      _etat = HomeDataState.success;
    } catch (e) {
      debugPrint('[AlerteProvider] Erreur synchronisation: $e');
      // On garde les données existantes, pas de changement d'état
      // sauf si on n'a aucune donnée
      if (_actives.isEmpty && _historique.isEmpty) {
        _etat = HomeDataState.error;
        _erreur = 'Erreur de synchronisation des alertes';
      }
    }
    notifyListeners();
  }

  // ─── FILTRES ────────────────────────────────────────────────
  void setFiltreRegion(String? region) {
    _filtreRegion = region;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    super.dispose();
  }
}
