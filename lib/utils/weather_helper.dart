import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class WeatherHelper {
  static IconData conditionIcon(String condition) {
    if (condition.contains('dégagé') || condition.contains('Ciel dégagé')) {
      return Icons.wb_sunny;
    }
    if (condition.contains('nuageux') || condition.contains('Partiellement')) {
      return Icons.wb_cloudy;
    }
    if (condition.contains('Brumeux')) return Icons.cloud;
    if (condition.contains('Pluie') || condition.contains('Bruine')) {
      return Icons.water_drop;
    }
    if (condition.contains('Averses')) return Icons.umbrella;
    if (condition.contains('Orage')) return Icons.flash_on;
    return Icons.cloud_queue;
  }

  static Color conditionColor(String condition) {
    if (condition.contains('dégagé') || condition.contains('Ciel dégagé')) {
      return AppTheme.accentYellow;
    }
    if (condition.contains('nuageux') || condition.contains('Partiellement')) {
      return AppTheme.accentBlue;
    }
    if (condition.contains('Pluie') || condition.contains('Bruine')) {
      return AppTheme.accentBlueLight;
    }
    if (condition.contains('Orage')) return AppTheme.accentRed;
    return AppTheme.textSecondary;
  }

  static String jourSemaine(int weekday) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    if (weekday < 1 || weekday > 7) return '';
    return jours[weekday - 1];
  }

  static String jourSemaineComplet(int weekday) {
    const jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    if (weekday < 1 || weekday > 7) return '';
    return jours[weekday - 1];
  }

  static String mois(int m) {
    const mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    if (m < 1 || m > 12) return '';
    return mois[m - 1];
  }

  static String moisComplet(int m) {
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    if (m < 1 || m > 12) return '';
    return mois[m - 1];
  }

  static Color uvColor(double uv) {
    if (uv <= 2) return AppTheme.accentGreen;
    if (uv <= 5) return AppTheme.accentYellow;
    if (uv <= 7) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  static String uvLabel(double uv) {
    if (uv <= 2) return 'Faible';
    if (uv <= 5) return 'Modéré';
    if (uv <= 7) return 'Élevé';
    return 'Extrême';
  }

  static String ventLabel(double vitesse) {
    if (vitesse < 5) return 'Calme';
    if (vitesse < 15) return 'Brise légère';
    if (vitesse < 30) return 'Brise modérée';
    if (vitesse < 50) return 'Vent fort';
    return 'Tempête';
  }
}
