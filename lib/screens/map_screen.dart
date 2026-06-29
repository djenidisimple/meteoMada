import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/models/ville.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _centre = LatLng(-18.7669, 46.8691);

  final _repo = VilleRepository();
  List<Ville> _villes = [];
  bool _charge = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _chargerVilles();
    _verifierConnectivite();
  }

  Future<void> _chargerVilles() async {
    final villes = await _repo.getAllVilles();
    if (mounted) setState(() { _villes = villes; _charge = false; });
  }

  Future<void> _verifierConnectivite() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = result.contains(ConnectivityResult.none);
      });
    }
  }

  void _onMarkerTap(Ville ville) {
    _showCitySheet(ville);
  }

  void _showCitySheet(Ville ville) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _CitySheet(
        ville: ville,
        onDetail: () {
          Navigator.pop(context);
          context.push('/home/detail/${ville.id}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.homeDarkBottom),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            if (_charge)
              const Center(child: CircularProgressIndicator())
            else
              FlutterMap(
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
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.meteomada',
                  ),
                  MarkerLayer(markers: _marqueurs),
                ],
              ),
            if (_isOffline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _offlineBanner(),
              ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _appBar(context),
                  const Spacer(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── OFFLINE BANNER ──────────────────────────────────────
  Widget _offlineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentOrange.withValues(alpha: 0.90),
            AppTheme.accentOrange.withValues(alpha: 0.70),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode hors-ligne : affichage limité de la carte',
              style: AppTheme.poppins(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────
  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.map_pin_ellipse, size: 14, color: AppTheme.accentBlue),
                const SizedBox(width: 6),
                Text(
                  'Madagascar · ${_villes.length} villes',
                  style: AppTheme.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_isOffline)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 16, color: AppTheme.accentOrange),
            ),
        ],
      ),
    );
  }

  // ─── MARKERS ─────────────────────────────────────────────
  List<Marker> get _marqueurs {
    return _villes.map((v) {
      final estCapitale = v.nom == 'Antananarivo';
      return Marker(
        point: LatLng(v.latitude, v.longitude),
        width: estCapitale ? 90 : 72,
        height: estCapitale ? 64 : 52,
        child: GestureDetector(
          onTap: () => _onMarkerTap(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: estCapitale
                        ? AppTheme.accentBlue.withValues(alpha: 0.50)
                        : Colors.white.withValues(alpha: 0.12),
                    width: estCapitale ? 1.0 : 0.5,
                  ),
                ),
                child: Text(
                  v.nom,
                  style: AppTheme.poppins(
                    fontSize: estCapitale ? 11 : 9,
                    fontWeight: estCapitale ? FontWeight.w700 : FontWeight.w500,
                    color: estCapitale ? AppTheme.accentBlueLight : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: estCapitale ? 14 : 10,
                height: estCapitale ? 14 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: estCapitale ? AppTheme.accentBlue : AppTheme.accentCyan,
                  boxShadow: [
                    BoxShadow(
                      color: (estCapitale ? AppTheme.accentBlue : AppTheme.accentCyan)
                          .withValues(alpha: 0.60),
                      blurRadius: estCapitale ? 10 : 6,
                      spreadRadius: estCapitale ? 2 : 1,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.80),
                    width: estCapitale ? 2.0 : 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ─── CITY BOTTOM SHEET ─────────────────────────────────────
class _CitySheet extends StatelessWidget {
  final Ville ville;
  final VoidCallback onDetail;

  const _CitySheet({required this.ville, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    final estCapitale = ville.nom == 'Antananarivo';
    final color = estCapitale ? AppTheme.accentBlue : AppTheme.accentCyan;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2028),
            const Color(0xFF14151C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.30)),
                ),
                child: Icon(
                  estCapitale ? CupertinoIcons.star_fill : CupertinoIcons.map_pin_ellipse,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ville.nom,
                      style: AppTheme.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ville.region,
                      style: AppTheme.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '${ville.altitude}m',
                  style: AppTheme.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (ville.estCotiere) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.water_outlined, size: 12, color: AppTheme.accentGreen),
                const SizedBox(width: 6),
                Text(
                  'Ville côtière · Météo marine disponible',
                  style: AppTheme.poppins(fontSize: 11, color: AppTheme.accentGreen),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onDetail,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.10)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      'Voir la météo détaillée',
                      style: AppTheme.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
