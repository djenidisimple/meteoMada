import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/models/condition_marine.dart';
import 'package:meteomada/models/alerte_cyclone.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  String get _baseUrl =>
      dotenv.env['API_OPEN_METEO_BASE_URL'] ?? 'https://api.open-meteo.com/v1';
  String get _marineBaseUrl =>
      dotenv.env['API_OPEN_METEO_MARINE_URL'] ?? 'https://marine-api.open-meteo.com/v1';
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

  // ─── MÉTÉO ACTUELLE ─────────────────────────────────────
  Future<Prevision> requeteMeteoActuelle(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,uv_index'
      '&daily=sunrise,sunset'
      '&timezone=auto',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>?;
    final code = current['weather_code'] as int? ?? 0;

    String sunrise = '';
    String sunset = '';
    if (daily != null) {
      final sunrises = daily['sunrise'] as List<dynamic>?;
      final sunsets = daily['sunset'] as List<dynamic>?;
      if (sunrises != null && sunrises.isNotEmpty) {
        final dt = DateTime.parse(sunrises[0] as String);
        sunrise = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      if (sunsets != null && sunsets.isNotEmpty) {
        final dt = DateTime.parse(sunsets[0] as String);
        sunset = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    final temp = (current['temperature_2m'] as num).toDouble();
    return Prevision(
      id: _uuid.v4(),
      villeId: '',
      condition: _codeToCondition(code),
      directionVent:
          _degToDir((current['wind_direction_10m'] as num?)?.toDouble() ?? 0),
      icone: _codeToIcon(code),
      leverSoleil: sunrise,
      coucherSoleil: sunset,
      dateHeure: DateTime.parse(current['time'] as String),
      dateCreation: DateTime.now(),
      temperature: temp,
      temperatureMin: temp,
      temperatureMax: temp,
      temperatureRessentie:
          (current['apparent_temperature'] as num).toDouble(),
      humidite: (current['relative_humidity_2m'] as num).toDouble(),
      vitesseVent: (current['wind_speed_10m'] as num).toDouble(),
      probabilitePluie: 0,
      indiceUV: (current['uv_index'] as num?)?.toDouble() ?? 0,
    );
  }

  // ─── PRÉVISIONS 7 JOURS ──────────────────────────────────
  Future<List<Prevision>> requetePrevisions7Jours(
      double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast'
      '?latitude=$lat&longitude=$lon'
      '&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,wind_speed_10m_max,uv_index_max,sunrise,sunset'
      '&timezone=auto',
    );
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
    final sunrises = daily['sunrise'] as List<dynamic>?;
    final sunsets = daily['sunset'] as List<dynamic>?;

    final now = DateTime.now();
    final results = <Prevision>[];
    for (int i = 0; i < times.length; i++) {
      final code = (codes[i] as num).toInt();

      String sunrise = '';
      String sunset = '';
      if (sunrises != null && i < sunrises.length) {
        final dt = DateTime.parse(sunrises[i] as String);
        sunrise =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      if (sunsets != null && i < sunsets.length) {
        final dt = DateTime.parse(sunsets[i] as String);
        sunset =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }

      final tMax = (tempMax[i] as num).toDouble();
      final tMin = (tempMin[i] as num).toDouble();
      results.add(Prevision(
        id: _uuid.v4(),
        villeId: '',
        condition: _codeToCondition(code),
        directionVent: '',
        icone: _codeToIcon(code),
        leverSoleil: sunrise,
        coucherSoleil: sunset,
        dateHeure: DateTime.parse(times[i] as String),
        dateCreation: now,
        temperature: tMax,
        temperatureMin: tMin,
        temperatureMax: tMax,
        temperatureRessentie: 0,
        humidite: 0,
        vitesseVent: wind != null ? (wind[i] as num).toDouble() : 0,
        probabilitePluie: precip != null ? (precip[i] as num).toDouble() : 0,
        indiceUV: uv != null ? (uv[i] as num).toDouble() : 0,
      ));
    }
    return results;
  }

  // ─── PRÉVISIONS HORAIRES ─────────────────────────────────
  Future<List<Prevision>> requetePrevisionsHoraires(double lat, double lon,
      {int jours = 1}) async {
    final url = Uri.parse(
      '$_baseUrl/forecast'
      '?latitude=$lat&longitude=$lon'
      '&hourly=temperature_2m,relative_humidity_2m,weather_code,precipitation_probability,wind_speed_10m,uv_index'
      '&timezone=auto&forecast_days=$jours',
    );
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

  // ─── CONDITIONS MARINES (Open-Meteo Marine API) ──────────
  Future<ConditionMarine> requeteConditionsMarines(
      double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_marineBaseUrl/marine'
        '?latitude=$lat&longitude=$lon'
        '&hourly=wave_height,wave_direction,wave_period,swell_wave_height,swell_wave_direction,wind_wave_height'
        '&timezone=auto&forecast_days=1',
      );
      final response = await http.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = data['hourly'] as Map<String, dynamic>;

      final waveHeights = hourly['wave_height'] as List<dynamic>?;
      final waveDirs = hourly['wave_direction'] as List<dynamic>?;
      final swellHeights = hourly['swell_wave_height'] as List<dynamic>?;

      final hVagues =
          (waveHeights?.isNotEmpty == true && (waveHeights![0] as num) >= 0)
              ? (waveHeights[0] as num).toDouble()
              : 0.5;
      final hHoule =
          (swellHeights?.isNotEmpty == true && (swellHeights![0] as num) >= 0)
              ? (swellHeights[0] as num).toDouble()
              : 0.3;
      final dirVagues =
          (waveDirs?.isNotEmpty == true && (waveDirs![0] as num) >= 0)
              ? _degToDir((waveDirs[0] as num).toDouble())
              : 'NE';

      // Température de l'eau via estimation (Open-Meteo ne fournit pas SST gratuitement)
      final tempEau = 26.0 + ((lat + 25) * 0.15).clamp(0, 4);

      final baignade = hVagues > 1.5 || hHoule > 2.0;

      String etatMaree;
      final now = DateTime.now();
      final minuteOfDay = now.hour * 60 + now.minute;
      // Approx marée via cycle lunaire (12h25min)
      final tidePhase = (minuteOfDay % (12 * 60 + 25)) / (12 * 60 + 25);
      if (tidePhase < 0.45) {
        etatMaree = 'Marée haute';
      } else if (tidePhase < 0.95) {
        etatMaree = 'Marée basse';
      } else {
        etatMaree = 'Marée haute';
      }

      return ConditionMarine(
        id: _uuid.v4(),
        villeId: '',
        etatMaree: etatMaree,
        ventMarin: dirVagues,
        hauteurVagues: hVagues,
        temperatureEau: tempEau,
        houle: hHoule,
        baignadeDangereuse: baignade,
        pechePossible: hVagues < 2.0,
      );
    } catch (_) {
      // Fallback données simulées si API indisponible
      return ConditionMarine(
        id: _uuid.v4(),
        villeId: '',
        etatMaree: 'Marée haute',
        ventMarin: 'Nord-Est',
        hauteurVagues: 1.2,
        temperatureEau: 26.0,
        houle: 0.8,
        baignadeDangereuse: false,
        pechePossible: true,
      );
    }
  }

  // ─── ALERTES CYCLONES ────────────────────────────────────
  Future<List<AlerteCyclone>> requeteAlertesActives() async {
    try {
      // Connecteur pour flux RSS Météo-France / sources publiques
      // Utilise une URL configurable via .env (API_CYCLONE_URL)
      final cycloneUrl = dotenv.env['API_CYCLONE_URL'] ?? '';
      if (cycloneUrl.isNotEmpty) {
        final url = Uri.parse(cycloneUrl);
        final response = await http.get(url).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          return data.map((item) => _parseCyclone(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // Données de démonstration pour la saison cyclonique (nov-avr)
    final now = DateTime.now();
    if (now.month >= 11 || now.month <= 4) {
      try {
        // Tentative d'accès à un flux public simplifié
        const fallbackUrl =
            'https://raw.githubusercontent.com/j04n-b/json-data/main/cyclones.json';
        final url = Uri.parse(fallbackUrl);
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          return data.map((item) => _parseCyclone(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return [];
  }

  AlerteCyclone _parseCyclone(Map<String, dynamic> item) {
    return AlerteCyclone(
      id: item['id'] as String? ?? _uuid.v4(),
      nomCyclone: item['nom'] as String? ?? 'Sans nom',
      consignes: item['consignes'] as String? ?? '',
      niveau: item['niveau'] as String? ?? 'surveillance',
      dateEmission: item['date_emission'] != null
          ? DateTime.parse(item['date_emission'] as String)
          : DateTime.now(),
      dateFinPrevue: item['date_fin_prevue'] != null
          ? DateTime.parse(item['date_fin_prevue'] as String)
          : null,
      estActive: item['est_active'] as bool? ?? true,
      regions: (item['regions'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────
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
