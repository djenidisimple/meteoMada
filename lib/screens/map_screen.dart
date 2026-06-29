import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/models/ville.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _centre = LatLng(-19.5, 46.75);
  String _coucheActive = 'Pluie';
  List<Ville> _villes = [];
  bool _charge = true;

  @override
  void initState() {
    super.initState();
    _chargerVilles();
  }

  Future<void> _chargerVilles() async {
    final repo = VilleRepository();
    final villes = await repo.getAllVilles();
    if (mounted) setState(() { _villes = villes; _charge = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _charge
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: _centre,
                      initialZoom: 5.5,
                      minZoom: 5,
                      maxZoom: 12,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: LatLngBounds(
                          LatLng(-25.5, 42.5),
                          LatLng(-12.0, 50.8),
                        ),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _urlTemplate,
                        userAgentPackageName: 'com.example.meteomada',
                      ),
                      MarkerLayer(markers: _marqueurs),
                    ],
                  ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _layerChips(),
                  const Spacer(),
                  _bottomCard(context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _urlTemplate {
    switch (_coucheActive) {
      case 'Pluie':
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case 'Temp.':
        return 'https://tiles.opentopomap.org/{z}/{x}/{y}.png';
      case 'Vent':
        return 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png';
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<Marker> get _marqueurs {
    return _villes.map((v) {
      final est = v.nom == 'Antananarivo';
      return Marker(
        point: LatLng(v.latitude, v.longitude),
        width: est ? 80 : 60,
        height: est ? 70 : 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: est ? AppTheme.accentBlue.withValues(alpha: 0.50) : AppTheme.cardBorder,
                  width: est ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📍', style: TextStyle(fontSize: est ? 14 : 11)),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(v.nom,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.poppins(
                            fontSize: est ? 11 : 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: est ? AppTheme.accentBlue : AppTheme.accentGreen,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _layerChips() {
    final couches = ['Pluie', 'Temp.', 'Vent'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: couches.map((c) {
        final isActive = _coucheActive == c;
        return GestureDetector(
          onTap: () => setState(() => _coucheActive = c),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: isActive
                ? BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentBlue.withValues(alpha: 0.40), width: 0.8),
                  )
                : BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  c == 'Pluie' ? Icons.water_drop_rounded :
                  c == 'Temp.' ? Icons.thermostat_rounded : Icons.air_rounded,
                  size: 14,
                  color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(c,
                    style: AppTheme.poppins(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bottomCard(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final p = wp.previsionActuelle;
    final v = wp.villeActuelle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: _blurFilter(),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _conditionEmoji(p?.condition ?? ''),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v?.nom ?? 'Antananarivo',
                          style: AppTheme.poppins(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(
                        '${p?.condition ?? 'Partiellement nuageux'} · ${p?.temperature.toStringAsFixed(0) ?? '--'}°C',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/home/detail/${v?.id ?? 'antananarivo'}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.30), width: 0.5),
                    ),
                    child: Text('Détails',
                        style: AppTheme.poppins(
                            fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentBlue)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _conditionEmoji(String condition) {
    if (condition.contains('dégagé')) return '☀️';
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return '⛅';
    if (condition.contains('Brumeux')) return '🌫️';
    if (condition.contains('Pluie') || condition.contains('Bruine')) return '🌧️';
    if (condition.contains('Averses')) return '🌦️';
    if (condition.contains('Orage')) return '⛈️';
    return '☁️';
  }

  ImageFilter _blurFilter() {
    return ImageFilter.blur(sigmaX: 8, sigmaY: 8);
  }
}
