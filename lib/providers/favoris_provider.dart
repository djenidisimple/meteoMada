import 'package:flutter/material.dart';
import 'package:meteomada/models/favori.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/repositories/favori_repository.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/repositories/prevision_repository.dart';
import 'package:uuid/uuid.dart';

class FavoriComplet {
  final Favori favori;
  final Ville ville;
  final Prevision? prevision;
  FavoriComplet({required this.favori, required this.ville, this.prevision});
}

class FavorisProvider extends ChangeNotifier {
  final _favoriRepo = FavoriRepository();
  final _villeRepo = VilleRepository();
  final _previsionRepo = PrevisionRepository();
  final _uuid = const Uuid();

  List<FavoriComplet> _favoris = [];
  String? _userId;
  bool _chargement = false;

  List<FavoriComplet> get favoris => _favoris;
  bool get chargement => _chargement;

  Future<void> initialiser(String? userId) async {
    _userId = userId;
    if (userId == null) {
      _favoris = [];
      _chargement = false;
      notifyListeners();
      return;
    }
    _chargement = true;
    notifyListeners();
    final list = await _favoriRepo.getFavoris(userId);
    final complets = <FavoriComplet>[];
    for (final f in list) {
      final ville = await _villeRepo.getVilleParId(f.villeId);
      if (ville != null) {
        final prev = await _previsionRepo.getDernierePrevision(ville.id);
        complets.add(FavoriComplet(favori: f, ville: ville, prevision: prev));
      }
    }
    _favoris = complets;
    _chargement = false;
    notifyListeners();
  }

  Future<void> ajouter(String villeId) async {
    if (_userId == null) return;
    final favori = Favori(
      id: _uuid.v4(),
      utilisateurId: _userId!,
      villeId: villeId,
      dateAjout: DateTime.now(),
      ordreAffichage: _favoris.length,
    );
    await _favoriRepo.ajouterFavori(favori);
    await initialiser(_userId);
  }

  Future<void> supprimer(String favoriId) async {
    await _favoriRepo.supprimerFavori(favoriId);
    await initialiser(_userId);
  }

  Future<void> reordonner(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _favoris.removeAt(oldIndex);
    _favoris.insert(newIndex, item);
    await _favoriRepo.reordonner(_favoris.map((f) => f.favori).toList());
    notifyListeners();
  }

  Future<bool> estFavori(String villeId) async {
    if (_userId == null) return false;
    return _favoriRepo.estFavori(villeId, _userId!);
  }

  Future<void> basculerNotifications(String favoriId) async {
    final idx = _favoris.indexWhere((f) => f.favori.id == favoriId);
    if (idx < 0) return;
    final old = _favoris[idx];
    final updated = old.favori.copyWith(notificationsActives: !old.favori.notificationsActives);
    await _favoriRepo.ajouterFavori(updated);
    await initialiser(_userId);
  }
}
