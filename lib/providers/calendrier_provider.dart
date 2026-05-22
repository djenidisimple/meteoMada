import 'package:flutter/material.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/repositories/calendrier_repository.dart';

class CalendrierProvider extends ChangeNotifier {
  final _repo = CalendrierRepository();

  List<CalendrierCultural> _donnees = [];
  List<String> _regions = [];
  String? _regionSelectionnee;
  bool _chargement = false;

  List<CalendrierCultural> get donnees => _donnees;
  bool get chargement => _chargement;
  List<CalendrierCultural> get filtered {
    if (_regionSelectionnee == null) return _donnees;
    return _donnees
        .where((c) => c.region == _regionSelectionnee)
        .toList();
  }

  List<String> get regions => _regions;
  String? get regionSelectionnee => _regionSelectionnee;

  Future<void> initialiser() async {
    _chargement = true;
    notifyListeners();
    _regions = await _repo.getToutesRegions();
    _chargement = false;
    notifyListeners();
  }

  void setRegion(String? region) {
    _regionSelectionnee = region;
    notifyListeners();
  }

  Future<void> chargerCalendrier(String region) async {
    _chargement = true;
    notifyListeners();
    _donnees = await _repo.getCalendrierParRegion(region);
    _regionSelectionnee = region;
    _chargement = false;
    notifyListeners();
  }
}
