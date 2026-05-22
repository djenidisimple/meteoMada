import 'package:flutter/material.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/services/database_service.dart';

class CalendrierProvider extends ChangeNotifier {
  final _db = DatabaseService();

  List<CalendrierCultural> _donnees = [];
  List<String> _regions = [];
  String? _regionSelectionnee;

  List<CalendrierCultural> get donnees => _donnees;
  List<CalendrierCultural> get filtered {
    if (_regionSelectionnee == null) return _donnees;
    return _donnees
        .where((c) => c.region == _regionSelectionnee)
        .toList();
  }

  List<String> get regions => _regions;
  String? get regionSelectionnee => _regionSelectionnee;

  Future<void> initialiser() async {
    _regions = await _db.getToutesRegions();
    notifyListeners();
  }

  void setRegion(String? region) {
    _regionSelectionnee = region;
    notifyListeners();
  }

  Future<void> chargerCalendrier(String region) async {
    _donnees = await _db.getCalendrierParRegion(region);
    _regionSelectionnee = region;
    notifyListeners();
  }
}
