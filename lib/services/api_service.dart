import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/models/condition_marine.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  static const _baseUrl = 'https://api.open-meteo.com/v1';
  final _uuid = const Uuid();
  Timer? _pollingTimer;

  void demarrerPolling(void Function() onTick) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      onTick();
    });
  }

  void arreterPolling() {
    _pollingTimer?.cancel();
  }

  Future<Prevision> requeteMeteoActuelle(double lat, double lon) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,uv_index&timezone=auto');
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final code = current['weather_code'] as int? ?? 0;

    return Prevision(
      id: _uuid.v4(),
      villeId: '',
      condition: _codeToCondition(code),
      directionVent: _degToDir((current['wind_direction_10m'] as num?)?.toDouble() ?? 0),
      icone: _codeToIcon(code),
      dateHeure: DateTime.parse(current['time'] as String),
      dateCreation: DateTime.now(),
      temperature: (current['temperature_2m'] as num).toDouble(),
      temperatureRessentie: (current['apparent_temperature'] as num).toDouble(),
      humidite: (current['relative_humidity_2m'] as num).toDouble(),
      vitesseVent: (current['wind_speed_10m'] as num).toDouble(),
      probabilitePluie: 0,
      indiceUV: (current['uv_index'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<List<Prevision>> requetePrevisions7Jours(double lat, double lon) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,wind_speed_10m_max,uv_index_max&timezone=auto');
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final times = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final tempMax = daily['temperature_2m_max'] as List<dynamic>;
    final tempMin = daily['temperature_2m_min'] as List<dynamic>;
    final precip = daily['precipitation_probability_max'] as List<dynamic>?;
    final wind = daily['wind_speed_10m_max'] as List<dynamic>?;
    final uv = daily['uv_index_max'] as List<dynamic>?;

    final now = DateTime.now();
    final results = <Prevision>[];
    for (int i = 0; i < times.length; i++) {
      final code = (codes[i] as num).toInt();
      results.add(Prevision(
        id: _uuid.v4(),
        villeId: '',
        condition: _codeToCondition(code),
        directionVent: '',
        icone: _codeToIcon(code),
        dateHeure: DateTime.parse(times[i] as String),
        dateCreation: now,
        temperature: (tempMax[i] as num).toDouble(),
        temperatureRessentie: (tempMin[i] as num).toDouble(),
        humidite: 0,
        vitesseVent: wind != null ? (wind[i] as num).toDouble() : 0,
        probabilitePluie: precip != null ? (precip[i] as num).toDouble() : 0,
        indiceUV: uv != null ? (uv[i] as num).toDouble() : 0,
      ));
    }
    return results;
  }

  Future<List<Prevision>> requetePrevisionsHoraires(double lat, double lon, {int jours = 1}) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,relative_humidity_2m,weather_code,precipitation_probability,wind_speed_10m,uv_index&timezone=auto&forecast_days=$jours');
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>;
    final times = hourly['time'] as List<dynamic>;
    final codes = hourly['weather_code'] as List<dynamic>;
    final temps = hourly['temperature_2m'] as List<dynamic>;
    final humidites = hourly['relative_humidity_2m'] as List<dynamic>?;
    final precip = hourly['precipitation_probability'] as List<dynamic>?;
    final winds = hourly['wind_speed_10m'] as List<dynamic>?;
    final uvs = hourly['uv_index'] as List<dynamic>?;

    final now = DateTime.now();
    final results = <Prevision>[];
    for (int i = 0; i < times.length; i++) {
      final date = DateTime.parse(times[i] as String);
      if (date.isBefore(now.add(const Duration(hours: -1)))) continue;
      if (results.length >= 24) break;
      final code = (codes[i] as num).toInt();
      results.add(Prevision(
        id: _uuid.v4(),
        villeId: '',
        condition: _codeToCondition(code),
        directionVent: '',
        icone: _codeToIcon(code),
        dateHeure: date,
        dateCreation: now,
        temperature: (temps[i] as num).toDouble(),
        temperatureRessentie: (temps[i] as num).toDouble(),
        humidite: humidites != null ? (humidites[i] as num).toDouble() : 0,
        vitesseVent: winds != null ? (winds[i] as num).toDouble() : 0,
        probabilitePluie: precip != null ? (precip[i] as num).toDouble() : 0,
        indiceUV: uvs != null ? (uvs[i] as num).toDouble() : 0,
      ));
    }
    return results;
  }

  Future<ConditionMarine> requeteConditionsMarines(double lat, double lon) async {
    return ConditionMarine(
      id: _uuid.v4(),
      villeId: '',
      etatMaree: 'Marée haute',
      ventMarin: 'Nord-Est',
      hauteurVagues: 1.2 + (DateTime.now().millisecond % 30) / 10,
      temperatureEau: 26.0 + (DateTime.now().millisecond % 5).toDouble(),
      houle: 0.8 + (DateTime.now().millisecond % 20) / 10,
      baignadeDangereuse: false,
      pechePossible: true,
    );
  }

  Future<List<AlerteCyclone>> requeteAlertesActives() async {
    return [];
  }

  String _codeToCondition(int code) {
    if (code == 0) return 'Ciel dégagé';
    if (code <= 3) return 'Partiellement nuageux';
    if (code <= 48) return 'Brumeux';
    if (code <= 57) return 'Bruine';
    if (code <= 67) return 'Pluie';
    if (code <= 77) return 'Neige';
    if (code <= 82) return 'Averses';
    if (code <= 86) return 'Averses de neige';
    if (code <= 99) return 'Orage';
    return 'Nuageux';
  }

  String _codeToIcon(int code) {
    if (code == 0) return '01d';
    if (code <= 3) return '02d';
    if (code <= 48) return '50d';
    if (code <= 67) return '10d';
    if (code <= 86) return '09d';
    if (code <= 99) return '11d';
    return '04d';
  }

  String _degToDir(double deg) {
    if (deg < 22.5) return 'N';
    if (deg < 67.5) return 'NE';
    if (deg < 112.5) return 'E';
    if (deg < 157.5) return 'SE';
    if (deg < 202.5) return 'S';
    if (deg < 247.5) return 'SO';
    if (deg < 292.5) return 'O';
    if (deg < 337.5) return 'NO';
    return 'N';
  }
}
