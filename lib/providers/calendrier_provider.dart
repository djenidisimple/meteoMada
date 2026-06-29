import 'package:flutter/material.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/repositories/calendrier_repository.dart';

class CalendrierProvider extends ChangeNotifier {
  final _repo = CalendrierRepository();

  List<CalendrierCultural> _donnees = [];
  List<String> _regions = [];
  String? _regionSelectionnee;
  bool _chargement = false;
  String _recherche = '';

  List<CalendrierCultural> get donnees => _donnees;
  bool get chargement => _chargement;
  List<String> get regions => _regions;
  String? get regionSelectionnee => _regionSelectionnee;

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

  Future<void> initialiser() async {
    _chargement = true;
    notifyListeners();
    _donnees = await _repo.getTout();
    _regions = _donnees.map((c) => c.region).toSet().toList()..sort();
    _chargement = false;
    notifyListeners();
  }

  void setRecherche(String value) {
    _recherche = value;
    notifyListeners();
  }

  void setRegion(String? region) {
    _regionSelectionnee = region;
    _recherche = '';
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
