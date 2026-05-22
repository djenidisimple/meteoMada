import 'package:flutter/material.dart';
import 'package:meteomada/models/condition_marine.dart';
import 'package:meteomada/services/api_service.dart';

class MarineProvider extends ChangeNotifier {
  final _api = ApiService();

  ConditionMarine? _condition;
  bool _chargement = false;

  ConditionMarine? get condition => _condition;
  bool get chargement => _chargement;

  Future<void> chargerCondition(String villeId, double lat, double lon) async {
    _chargement = true;
    notifyListeners();
    try {
      _condition = await _api.requeteConditionsMarines(lat, lon);
    } catch (_) {
      _condition = null;
    }
    _chargement = false;
    notifyListeners();
  }
}
