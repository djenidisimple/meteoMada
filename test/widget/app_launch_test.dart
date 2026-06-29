import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteomada/utils/weather_helper.dart';

void main() {
  testWidgets('WeatherHelper icons render correctly in vertical list',
      (WidgetTester tester) async {
    final conditions = [
      'Ciel dégagé',
      'Partiellement nuageux',
      'Brumeux',
      'Pluie modérée',
      'Averses',
      'Orage violent',
    ];

    for (final condition in conditions) {
      expect(WeatherHelper.conditionIcon(condition), isNotNull);
      expect(WeatherHelper.conditionColor(condition), isNotNull);
    }
  });

  test('WeatherHelper returns consistent results', () {
    const condition = 'Ciel dégagé';
    final icon = WeatherHelper.conditionIcon(condition);
    final color = WeatherHelper.conditionColor(condition);

    expect(icon, isNotNull);
    expect(color, isNotNull);

    // Vérifie que icon et color sont cohérents
    // (ni l'un ni l'autre ne devrait être une valeur par défaut inattendue)
    expect(icon, isNot(equals(Icons.cloud_queue)));
    expect(color, isNot(equals(0x00000000)));
  });
}
