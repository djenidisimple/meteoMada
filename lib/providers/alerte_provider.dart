import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:meteomada/services/database_service.dart';
import 'package:meteomada/services/api_service.dart';

class AlerteProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _api = ApiService();

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
    _chargement = true;
    notifyListeners();
    try {
      _actives = await _db.getAlertesActives();
      _historique = (await _db.getToutesAlertes())
          .where((a) => !a.estActive)
          .toList();
    } catch (_) {}
    _chargement = false;
    notifyListeners();

    Timer.periodic(const Duration(minutes: 30), (_) async {
      final apiAlertes = await _api.requeteAlertesActives();
      for (final a in apiAlertes) {
        await _db.sauvegarderAlerte(a);
      }
      _actives = await _db.getAlertesActives();
      notifyListeners();
    });
  }

  void setFiltreRegion(String? region) {
    _filtreRegion = region;
    notifyListeners();
  }
}
