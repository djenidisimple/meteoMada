import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider qui gère la locale active de l'application.
/// Persiste le choix via SharedPreferences.
class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isMalagasy => _locale.languageCode == 'mg';

  /// Charge la locale sauvegardée au démarrage.
  Future<void> initialiser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'fr';
      _locale = Locale(code);
      notifyListeners();
    } catch (e) {
      debugPrint('[LocaleProvider] Erreur chargement locale: $e');
    }
  }

  /// Change la locale et la persiste.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
    } catch (e) {
      debugPrint('[LocaleProvider] Erreur sauvegarde locale: $e');
    }
  }
}
