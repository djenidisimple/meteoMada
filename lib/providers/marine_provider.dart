import 'package:flutter/material.dart';
import 'package:meteomada/models/condition_marine.dart';
import 'package:meteomada/repositories/condition_marine_repository.dart';
import 'package:meteomada/services/api_service.dart';

class MarineProvider extends ChangeNotifier {
  final _repo = ConditionMarineRepository();
  final _api = ApiService();

  ConditionMarine? _condition;
  bool _chargement = false;

  ConditionMarine? get condition => _condition;
  bool get chargement => _chargement;

  Future<void> chargerCondition(String villeId, double lat, double lon) async {
    _chargement = true;
    notifyListeners();
    try {
      final cache = await _repo.getConditionMarine(villeId);
      if (cache != null) {
        _condition = cache;
      } else {
        final marine = await _api.requeteConditionsMarines(lat, lon);
        final avecVille = ConditionMarine(
          id: marine.id,
          villeId: villeId,
          hauteurVagues: marine.hauteurVagues,
          temperatureEau: marine.temperatureEau,
          etatMaree: marine.etatMaree,
          ventMarin: marine.ventMarin,
          houle: marine.houle,
          baignadeDangereuse: marine.baignadeDangereuse,
          pechePossible: marine.pechePossible,
        );
        await _repo.insererConditionMarine(avecVille);
        _condition = avecVille;
      }
    } catch (_) {
      _condition = await _repo.getConditionMarine(villeId);
    }
    _chargement = false;
    notifyListeners();
  }
}
