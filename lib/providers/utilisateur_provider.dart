import 'package:flutter/material.dart';
import 'package:meteomada/models/utilisateur.dart';
import 'package:meteomada/services/database_service.dart';

class UtilisateurProvider extends ChangeNotifier {
  final _db = DatabaseService();

  Utilisateur? _utilisateur;

  Utilisateur? get utilisateur => _utilisateur;
  String get userId => _utilisateur?.id ?? 'default_user';

  Future<void> initialiser() async {
    _utilisateur = await _db.getUtilisateur('default_user');
    if (_utilisateur == null) {
      _utilisateur = Utilisateur(
        id: 'default_user',
        pseudo: 'Utilisateur',
        languePreferee: 'fr',
        typeUtilisateur: 'citoyen',
      );
      await _db.sauvegarderUtilisateur(_utilisateur!);
    }
    notifyListeners();
  }

  Future<void> updateLangue(String langue) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(languePreferee: langue);
    await _db.sauvegarderUtilisateur(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateTypeUtilisateur(String type) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(typeUtilisateur: type);
    await _db.sauvegarderUtilisateur(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateAlertesCyclone(bool value) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(alertesCycloneActivees: value);
    await _db.sauvegarderUtilisateur(_utilisateur!);
    notifyListeners();
  }

  Future<void> updateAlertesPluie(bool value) async {
    if (_utilisateur == null) return;
    _utilisateur = _utilisateur!.copyWith(alertesPluieActivees: value);
    await _db.sauvegarderUtilisateur(_utilisateur!);
    notifyListeners();
  }
}
