import 'package:flutter_test/flutter_test.dart';
import 'package:meteomada/models/prevision.dart';

void main() {
  group('Prevision Model', () {
    final now = DateTime.now();
    final baseMap = <String, dynamic>{
      'id': 'test-123',
      'ville_id': 'TNR',
      'condition': 'Ciel dégagé',
      'direction_vent': 'NE',
      'icone': '01d',
      'lever_soleil': '06:15',
      'coucher_soleil': '17:30',
      'date_heure': now.toIso8601String(),
      'date_creation': now.toIso8601String(),
      'temperature': 27.5,
      'temperature_ressentie': 25.0,
      'humidite': 65.0,
      'vitesse_vent': 12.0,
      'probabilite_pluie': 10.0,
      'indice_uv': 5.0,
    };

    test('fromMap crée une instance correcte', () {
      final p = Prevision.fromMap(baseMap);

      expect(p.id, 'test-123');
      expect(p.villeId, 'TNR');
      expect(p.condition, 'Ciel dégagé');
      expect(p.directionVent, 'NE');
      expect(p.icone, '01d');
      expect(p.leverSoleil, '06:15');
      expect(p.coucherSoleil, '17:30');
      expect(p.temperature, 27.5);
      expect(p.temperatureRessentie, 25.0);
      expect(p.humidite, 65.0);
      expect(p.vitesseVent, 12.0);
      expect(p.probabilitePluie, 10.0);
      expect(p.indiceUV, 5.0);
    });

    test('toMap retourne les mêmes champs que fromMap', () {
      final p = Prevision.fromMap(baseMap);
      final map = p.toMap();

      expect(map['id'], 'test-123');
      expect(map['ville_id'], 'TNR');
      expect(map['temperature'], 27.5);
      expect(map['humidite'], 65.0);
    });

    test('copyWith modifie seulement les champs spécifiés', () {
      final p = Prevision.fromMap(baseMap);
      final modified = p.copyWith(temperature: 30.0, condition: 'Orage');

      expect(modified.id, p.id);
      expect(modified.villeId, p.villeId);
      expect(modified.temperature, 30.0);
      expect(modified.condition, 'Orage');
      expect(modified.humidite, p.humidite);
      expect(modified.vitesseVent, p.vitesseVent);
    });

    test('copyWith conserve les valeurs par défaut (leverSoleil, coucherSoleil)', () {
      final p = Prevision.fromMap(baseMap);
      final modified = p.copyWith(villeId: 'TOA');

      expect(modified.leverSoleil, '06:15');
      expect(modified.coucherSoleil, '17:30');
      expect(modified.villeId, 'TOA');
    });

    test('estExpiree retourne true pour une prévision de plus de 30 min', () {
      final old = DateTime.now().subtract(const Duration(minutes: 45));
      final p = Prevision(
        id: 'expired',
        villeId: 'TNR',
        condition: 'Pluie',
        directionVent: 'S',
        icone: '10d',
        dateHeure: old,
        dateCreation: old,
        temperature: 22.0,
        temperatureRessentie: 20.0,
        humidite: 80.0,
        vitesseVent: 15.0,
        probabilitePluie: 80.0,
        indiceUV: 1.0,
      );
      expect(p.estExpiree(), true);
    });

    test('estExpiree retourne false pour une prévision récente', () {
      final recent = DateTime.now().subtract(const Duration(minutes: 10));
      final p = Prevision(
        id: 'recent',
        villeId: 'TNR',
        condition: 'Partiellement nuageux',
        directionVent: 'E',
        icone: '02d',
        dateHeure: recent,
        dateCreation: recent,
        temperature: 25.0,
        temperatureRessentie: 23.0,
        humidite: 55.0,
        vitesseVent: 8.0,
        probabilitePluie: 20.0,
        indiceUV: 4.0,
      );
      expect(p.estExpiree(), false);
    });

    test('fromMap gère lever_soleil et coucher_soleil vides', () {
      final map = Map<String, dynamic>.from(baseMap);
      map.remove('lever_soleil');
      map.remove('coucher_soleil');

      final p = Prevision.fromMap(map);
      expect(p.leverSoleil, '');
      expect(p.coucherSoleil, '');
    });
  });
}
