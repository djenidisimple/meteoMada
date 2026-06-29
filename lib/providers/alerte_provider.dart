import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:meteomada/repositories/alerte_repository.dart';
import 'package:meteomada/services/api_service.dart';
import 'package:meteomada/services/notification_service.dart';

class AlerteProvider extends ChangeNotifier {
  final _repo = AlerteRepository();
  final _api = ApiService();
  final _notif = NotificationService();

  List<AlerteCyclone> _actives = [];
  List<AlerteCyclone> _historique = [];
  String? _filtreRegion;
  bool _chargement = false;

  List<AlerteCyclone> get actives => _actives;
  List<AlerteCyclone> get historique => _historique;
  List<AlerteCyclone> get toutes => [..._actives, ..._historique];
  String? get filtreRegion => _filtreRegion;
  bool get chargement => _chargement;
  int get countActives => _actives.length;

  List<AlerteCyclone> get filtrees {
    if (_filtreRegion == null) return toutes;
    return toutes
        .where((a) => a.regions.any((r) =>
            r.toLowerCase().contains(_filtreRegion!.toLowerCase())))
        .toList();
  }

  Future<void> initialiser() async {
    try {
      await _notif.initialiser();
      _chargement = true;
      notifyListeners();
      _actives = await _repo.getAlertesActives();
      _historique = (await _repo.getToutesAlertes())
          .where((a) => !a.estActive)
          .toList();
    } catch (_) {}
    _chargement = false;
    notifyListeners();

    Timer.periodic(const Duration(minutes: 30), (_) async {
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
      notifyListeners();
    });
  }

  void setFiltreRegion(String? region) {
    _filtreRegion = region;
    notifyListeners();
  }
}
