import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meteomada/models/ville.dart';

class GeocodingResult {
  final String nom;
  final String? region;
  final double latitude;
  final double longitude;
  final String pays;
  final String type;
  final String id;

  GeocodingResult({
    required this.nom,
    this.region,
    required this.latitude,
    required this.longitude,
    required this.pays,
    required this.type,
    required this.id,
  });
}

class GeocodingService {
  String get _baseUrl =>
      dotenv.env['NOMINATIM_BASE_URL'] ?? 'https://nominatim.openstreetmap.org';

  Future<List<GeocodingResult>> rechercher(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse(
        '$_baseUrl/search?q=$query&countrycodes=mg&format=json&limit=15&addressdetails=1&accept-language=fr');
    final response = await http.get(url, headers: {
      'User-Agent': 'ToeranaMeteoMada/1.0',
    });
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final address = item['address'] as Map<String, dynamic>? ?? {};
      final type = item['type'] as String? ?? '';
      final osmType = item['osm_type'] as String? ?? '';
      final osmId = item['osm_id'] as int? ?? 0;
      return GeocodingResult(
        nom: item['display_name'] as String? ?? query,
        region: address['state'] as String? ??
            address['region'] as String? ??
            address['county'] as String?,
        latitude: double.parse(item['lat'] as String),
        longitude: double.parse(item['lon'] as String),
        pays: address['country'] as String? ?? 'Madagascar',
        type: type,
        id: 'osm_${osmType}_$osmId',
      );
    }).toList();
  }

  Ville geocodingToVille(GeocodingResult g) {
    return Ville(
      id: _genererId(g.latitude, g.longitude),
      nom: g.nom.split(',').first.trim(),
      region: g.region ?? 'Madagascar',
      latitude: g.latitude,
      longitude: g.longitude,
      altitude: 0,
      fuseauHoraire: 'Indian/Antananarivo',
      estCotiere: false,
    );
  }

  String _genererId(double lat, double lon) {
    return 'loc_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }

  static String genererId(double lat, double lon) {
    return 'loc_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }
}
