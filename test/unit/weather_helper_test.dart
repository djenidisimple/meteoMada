import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteomada/utils/weather_helper.dart';

void main() {
  group('WeatherHelper', () {
    group('conditionIcon', () {
      test('retourne wb_sunny pour ciel dégagé', () {
        expect(WeatherHelper.conditionIcon('Ciel dégagé'), Icons.wb_sunny);
        expect(WeatherHelper.conditionIcon('dégagé'), Icons.wb_sunny);
      });

      test('retourne wb_cloudy pour nuageux', () {
        expect(WeatherHelper.conditionIcon('Partiellement nuageux'),
            Icons.wb_cloudy);
        expect(WeatherHelper.conditionIcon('Nuageux'), Icons.wb_cloudy);
      });

      test('retourne water_drop pour pluie/bruine', () {
        expect(
            WeatherHelper.conditionIcon('Pluie modérée'), Icons.water_drop);
        expect(WeatherHelper.conditionIcon('Bruine légère'), Icons.water_drop);
      });

      test('retourne flash_on pour orage', () {
        expect(WeatherHelper.conditionIcon('Orage violent'), Icons.flash_on);
      });

      test('retourne cloud_queue pour condition inconnue', () {
        expect(WeatherHelper.conditionIcon('Tempête de sable'),
            Icons.cloud_queue);
      });
    });

    group('conditionColor', () {
      test('retourne accentYellow pour dégagé', () {
        expect(WeatherHelper.conditionColor('Ciel dégagé'),
            const Color(0xFFFFD54F));
      });

      test('retourne accentBlue pour nuageux', () {
        expect(WeatherHelper.conditionColor('Partiellement nuageux'),
            const Color(0xFF4FC3F7));
      });

      test('retourne accentBlueLight pour pluie', () {
        expect(WeatherHelper.conditionColor('Pluie'),
            const Color(0xFF81D4FA));
      });

      test('retourne accentRed pour orage', () {
        expect(
            WeatherHelper.conditionColor('Orage'), const Color(0xFFE57373));
      });
    });

    group('jourSemaine', () {
      test('retourne le bon jour pour chaque weekday', () {
        expect(WeatherHelper.jourSemaine(1), 'Lun');
        expect(WeatherHelper.jourSemaine(2), 'Mar');
        expect(WeatherHelper.jourSemaine(3), 'Mer');
        expect(WeatherHelper.jourSemaine(4), 'Jeu');
        expect(WeatherHelper.jourSemaine(5), 'Ven');
        expect(WeatherHelper.jourSemaine(6), 'Sam');
        expect(WeatherHelper.jourSemaine(7), 'Dim');
      });
    });

    group('mois', () {
      test('retourne le bon mois abrégé', () {
        expect(WeatherHelper.mois(1), 'Jan');
        expect(WeatherHelper.mois(6), 'Jui');
        expect(WeatherHelper.mois(12), 'Déc');
      });
    });

    group('uvColor', () {
      test('retourne vert pour UV <= 2', () {
        expect(
            WeatherHelper.uvColor(1.0), const Color(0xFF66BB6A));
      });

      test('retourne jaune pour UV entre 3 et 5', () {
        expect(
            WeatherHelper.uvColor(4.0), const Color(0xFFFFD54F));
      });

      test('retourne orange pour UV entre 6 et 7', () {
        expect(
            WeatherHelper.uvColor(6.5), const Color(0xFFFF8A65));
      });

      test('retourne rouge pour UV > 7', () {
        expect(
            WeatherHelper.uvColor(8.0), const Color(0xFFE57373));
      });
    });

    group('uvLabel', () {
      test('retourne Faible pour UV <= 2', () {
        expect(WeatherHelper.uvLabel(1.0), 'Faible');
      });

      test('retourne Modéré pour UV entre 3 et 5', () {
        expect(WeatherHelper.uvLabel(4.0), 'Modéré');
      });

      test('retourne Élevé pour UV entre 6 et 7', () {
        expect(WeatherHelper.uvLabel(6.5), 'Élevé');
      });

      test('retourne Extrême pour UV > 7', () {
        expect(WeatherHelper.uvLabel(8.0), 'Extrême');
      });
    });

    group('ventLabel', () {
      test('retourne Calme pour vent < 5', () {
        expect(WeatherHelper.ventLabel(2.0), 'Calme');
      });

      test('retourne Brise légère pour vent entre 5 et 15', () {
        expect(WeatherHelper.ventLabel(10.0), 'Brise légère');
      });

      test('retourne Brise modérée pour vent entre 15 et 30', () {
        expect(WeatherHelper.ventLabel(22.0), 'Brise modérée');
      });

      test('retourne Vent fort pour vent entre 30 et 50', () {
        expect(WeatherHelper.ventLabel(40.0), 'Vent fort');
      });

      test('retourne Tempête pour vent > 50', () {
        expect(WeatherHelper.ventLabel(60.0), 'Tempête');
      });
    });
  });
}
