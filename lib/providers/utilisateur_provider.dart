import 'package:flutter/material.dart';
import 'package:meteomada/models/utilisateur.dart';
import 'package:meteomada/repositories/utilisateur_repository.dart';

class UtilisateurProvider extends ChangeNotifier {
  final _repo = UtilisateurRepository();

  Utilisateur? _utilisateur;
  bool _chargement = false;

  Utilisateur? get utilisateur => _utilisateur;
  bool get chargement => _chargement;
  String get userId => _utilisateur?.id ?? 'default_user';

  Future<void> initialiser() async {
    _chargement = true;
    notifyListeners();
    _utilisateur = await _repo.getUtilisateurParDefaut();
    if (_utilisateur == null) {
      _utilisateur = Utilisateur(
        id: 'default_user',
        pseudo: 'Utilisateur',
        languePreferee: 'fr',
        typeUtilisateur: 'citoyen',
      );
      await _repo.insererOuMAJ(_utilisateur!);
    }
    _chargement = false;
    notifyListeners();
  }

  Future<void> updateLangue(String langue) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(languePreferee: langue);
    await _repo.insererOuMAJ(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateTypeUtilisateur(String type) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(typeUtilisateur: type);
    await _repo.insererOuMAJ(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateAlertesCyclone(bool value) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(alertesCycloneActivees: value);
    await _repo.insererOuMAJ(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateAlertesPluie(bool value) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(alertesPluieActivees: value);
    await _repo.insererOuMAJ(_utilisateur!);
    notifyListeners();
  }
}
