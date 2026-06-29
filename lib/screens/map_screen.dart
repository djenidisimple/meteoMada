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

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const _centre = LatLng(-18.7669, 46.8691);

  final _repo = VilleRepository();
  final _mapController = MapController();
  final _searchController = TextEditingController();

  List<Ville> _villes = [];
  List<Ville> _villesFiltrees = [];
  bool _charge = true;
  bool _isOffline = false;
  String _filtre = 'toutes'; // 'toutes' | 'cotiere' | 'interieure'
  Ville? _villeSelectionnee;
  bool _searchVisible = false;

  late final AnimationController _sheetAnim;
  late final Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sheetAnim, curve: Curves.easeOutCubic));
    _chargerVilles();
    _verifierConnectivite();
  }

  @override
  void dispose() {
    _sheetAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chargerVilles() async {
    final villes = await _repo.getAllVilles();
    if (mounted) {
      setState(() {
        _villes = villes;
        _villesFiltrees = villes;
        _charge = false;
      });
    }
  }

  Future<void> _verifierConnectivite() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() => _isOffline = result.contains(ConnectivityResult.none));
    }
  }

  void _appliquerFiltre(String filtre) {
    setState(() {
      _filtre = filtre;
      final query = _searchController.text.toLowerCase();
      _villesFiltrees = _villes.where((v) {
        final matchSearch = query.isEmpty ||
            v.nom.toLowerCase().contains(query) ||
            v.region.toLowerCase().contains(query);
        final matchFiltre = filtre == 'toutes' ||
            (filtre == 'cotiere' && v.estCotiere) ||
            (filtre == 'interieure' && !v.estCotiere);
        return matchSearch && matchFiltre;
      }).toList();
    });
  }

  void _onSearch(String query) {
    _appliquerFiltre(_filtre);
  }

  void _onMarkerTap(Ville ville) {
    setState(() => _villeSelectionnee = ville);
    _sheetAnim.forward();
    // Centre la carte sur la ville sélectionnée
    _mapController.move(LatLng(ville.latitude, ville.longitude), 7.5);
  }

  void _fermerSheet() {
    _sheetAnim.reverse().then((_) {
      if (mounted) setState(() => _villeSelectionnee = null);
    });
  }

  void _voirDetail() {
    if (_villeSelectionnee == null) return;
    final id = _villeSelectionnee!.id;
    _fermerSheet();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) context.push('/home/detail/$id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.homeDarkBottom),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── CARTE ─────────────────────────────────────────
            if (_charge)
              const Center(child: CircularProgressIndicator())
            else
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _centre,
                  initialZoom: 5.5,
                  minZoom: 5,
                  maxZoom: 13,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      LatLng(-27.0, 41.0),
                      LatLng(-11.0, 52.0),
                    ),
                  ),
                  onTap: (_, __) => _fermerSheet(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.meteomada',
                  ),
                  MarkerLayer(markers: _marqueurs),
                ],
              ),

            // ── OFFLINE BANNER ────────────────────────────────
            if (_isOffline)
              Positioned(
                top: 0, left: 0, right: 0,
                child: _offlineBanner(),
              ),

            // ── TOP UI ────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _topBar(),
                  ),
                  if (_searchVisible)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _searchBar(),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _filtreChips(),
                  ),
                ],
              ),
            ),

            // ── ZOOM CONTROLS ─────────────────────────────────
            Positioned(
              right: 16,
              bottom: 110,
              child: _zoomControls(),
            ),

            // ── CITY BOTTOM SHEET ─────────────────────────────
            if (_villeSelectionnee != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: SlideTransition(
                  position: _sheetSlide,
                  child: _citySheet(_villeSelectionnee!),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.accentOrange.withValues(alpha: 0.85),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode hors-ligne · Affichage limité',
              style: AppTheme.poppins(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────
  Widget _topBar() {
    final visibles = _villesFiltrees.length;
    final total = _villes.length;
    return Row(
      children: [
        // Badge infos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.map_pin_ellipse, size: 13, color: AppTheme.accentBlue),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  text: '$visibles',
                  style: AppTheme.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  children: [
                    TextSpan(
                      text: '/$total villes',
                      style: AppTheme.poppins(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Bouton recherche
        GestureDetector(
          onTap: () => setState(() => _searchVisible = !_searchVisible),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _searchVisible
                  ? AppTheme.accentBlue.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _searchVisible
                    ? AppTheme.accentBlue.withValues(alpha: 0.40)
                    : Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Icon(
              CupertinoIcons.search,
              size: 17,
              color: _searchVisible ? AppTheme.accentBlue : Colors.white70,
            ),
          ),
        ),
        if (_isOffline) ...[
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 17, color: AppTheme.accentOrange),
          ),
        ],
      ],
    );
  }

  // ─── SEARCH BAR ──────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, size: 15, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: true,
              style: AppTheme.poppins(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville ou région...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _onSearch('');
              },
              child: Icon(CupertinoIcons.clear_circled_solid, size: 15, color: Colors.white38),
            ),
        ],
      ),
    );
  }

  // ─── FILTRE CHIPS ────────────────────────────────────────
  Widget _filtreChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('toutes', Icons.location_on_rounded, 'Toutes'),
          const SizedBox(width: 8),
          _chip('cotiere', Icons.waves_rounded, 'Côtières'),
          const SizedBox(width: 8),
          _chip('interieure', Icons.terrain_rounded, 'Intérieures'),
        ],
      ),
    );
  }

  Widget _chip(String value, IconData icon, String label) {
    final isActive = _filtre == value;
    final color = value == 'cotiere'
        ? AppTheme.accentCyan
        : value == 'interieure'
            ? AppTheme.accentGreen
            : AppTheme.accentBlue;
    return GestureDetector(
      onTap: () => _appliquerFiltre(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.10),
            width: isActive ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? color : Colors.white54),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTheme.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? color : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ZOOM CONTROLS ───────────────────────────────────────
  Widget _zoomControls() {
    return Column(
      children: [
        _zoomBtn(Icons.add_rounded, () => _mapController.move(
            _mapController.camera.center, _mapController.camera.zoom + 1)),
        const SizedBox(height: 6),
        _zoomBtn(Icons.remove_rounded, () => _mapController.move(
            _mapController.camera.center, _mapController.camera.zoom - 1)),
        const SizedBox(height: 6),
        _zoomBtn(CupertinoIcons.scope, () => _mapController.move(_centre, 5.5)),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, size: 18, color: Colors.white70),
      ),
    );
  }

  // ─── MARKERS ─────────────────────────────────────────────
  List<Marker> get _marqueurs {
    return _villesFiltrees.map((v) {
      final estCapitale = v.nom == 'Antananarivo';
      final estSelectionnee = _villeSelectionnee?.id == v.id;
      final color = estCapitale
          ? AppTheme.accentBlue
          : v.estCotiere
              ? AppTheme.accentCyan
              : AppTheme.accentGreen;

      return Marker(
        point: LatLng(v.latitude, v.longitude),
        width: estCapitale ? 96 : 78,
        height: estCapitale ? 62 : 50,
        child: GestureDetector(
          onTap: () => _onMarkerTap(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estSelectionnee
                      ? color.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: estSelectionnee
                        ? color.withValues(alpha: 0.70)
                        : color.withValues(alpha: estCapitale ? 0.45 : 0.20),
                    width: estSelectionnee ? 1.2 : (estCapitale ? 0.8 : 0.5),
                  ),
                ),
                child: Text(
                  v.nom,
                  style: AppTheme.poppins(
                    fontSize: estCapitale ? 10 : 9,
                    fontWeight: estCapitale || estSelectionnee ? FontWeight.w700 : FontWeight.w500,
                    color: estSelectionnee || estCapitale ? color : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: estSelectionnee ? 14 : (estCapitale ? 12 : 8),
                height: estSelectionnee ? 14 : (estCapitale ? 12 : 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: estSelectionnee ? 0.8 : 0.5),
                      blurRadius: estSelectionnee ? 14 : (estCapitale ? 10 : 5),
                      spreadRadius: estSelectionnee ? 3 : 1,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
                    width: estCapitale || estSelectionnee ? 2.0 : 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─── CITY BOTTOM SHEET ───────────────────────────────────
  Widget _citySheet(Ville ville) {
    final estCapitale = ville.nom == 'Antananarivo';
    final color = estCapitale
        ? AppTheme.accentBlue
        : ville.estCotiere
            ? AppTheme.accentCyan
            : AppTheme.accentGreen;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 90),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2028), Color(0xFF14151C)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée + bouton fermer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _fermerSheet,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(CupertinoIcons.xmark, size: 13, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête ville
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Icon(
                        estCapitale
                            ? CupertinoIcons.star_fill
                            : ville.estCotiere
                                ? Icons.waves_rounded
                                : Icons.terrain_rounded,
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
                            style: AppTheme.poppins(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (estCapitale)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'Capitale',
                          style: AppTheme.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accentBlue),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stats rapides
                Row(
                  children: [
                    _statBadge(Icons.height_rounded, '${ville.altitude} m', 'Altitude', AppTheme.accentPurple),
                    const SizedBox(width: 8),
                    _statBadge(
                      ville.estCotiere ? Icons.waves_rounded : Icons.terrain_rounded,
                      ville.estCotiere ? 'Côtière' : 'Intérieure',
                      'Type',
                      ville.estCotiere ? AppTheme.accentCyan : AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    _statBadge(CupertinoIcons.map_pin, '${ville.latitude.toStringAsFixed(1)}°', 'Latitude', AppTheme.accentOrange),
                  ],
                ),

                if (ville.estCotiere) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.water_outlined, size: 14, color: AppTheme.accentCyan),
                        const SizedBox(width: 8),
                        Text(
                          'Météo marine disponible pour cette ville',
                          style: AppTheme.poppins(fontSize: 11, color: AppTheme.accentCyan),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Bouton principal
                GestureDetector(
                  onTap: _voirDetail,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.12)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wb_sunny_rounded, size: 16, color: color),
                        const SizedBox(width: 8),
                        Text(
                          'Voir la météo complète',
                          style: AppTheme.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(IconData icon, String valeur, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 5),
            Text(valeur, style: AppTheme.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label, style: AppTheme.poppins(fontSize: 9, color: AppTheme.textDim)),
          ],
        ),
      ),
    );
  }
}
