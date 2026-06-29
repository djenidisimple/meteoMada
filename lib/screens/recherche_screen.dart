import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/services/geocoding_service.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/providers/weather_provider.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _villeRepo = VilleRepository();
  final _geo = GeocodingService();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Ville> _locales = [];
  List<GeocodingResult> _nominatim = [];
  bool _chargement = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _rechercher(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _rechercher(String terme) async {
    if (terme.isEmpty) {
      setState(() {
        _locales = [];
        _nominatim = [];
      });
      return;
    }
    setState(() => _chargement = true);
    try {
      final locaux = await _villeRepo.rechercherVilles(terme);
      List<GeocodingResult> osm = [];
      if (locaux.length < 10) {
        try {
          osm = await _geo.rechercher(terme);
        } catch (_) {}
      }
      setState(() {
        _locales = locaux;
        _nominatim = osm;
      });
    } catch (_) {
      setState(() {
        _locales = [];
        _nominatim = [];
      });
    } finally {
      setState(() => _chargement = false);
    }
  }

  void _selectionner(Ville ville) async {
    await context.read<WeatherProvider>().chargerMeteo(ville);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasQuery
                            ? AppTheme.accentBlue.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: AppTheme.poppins(fontSize: 15, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Village, ville, district...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppTheme.accentBlue, size: 22),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded,
                                    color: AppTheme.textSecondary, size: 20),
                                onPressed: () {
                                  _controller.clear();
                                  _focusNode.requestFocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text('Annuler',
                      style: AppTheme.poppins(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: hasQuery ? _buildResultats() : _buildAccueil(),
          ),
        ]),
      ),
    );
  }

  Widget _buildAccueil() {
    final suggestions = [
      'Antananarivo', 'Toamasina', 'Antsiranana', 'Fianarantsoa',
      'Toliara', 'Nosy Be', 'Morondava', 'Ambatondrazaka',
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text('Toutes les localités de Madagascar',
            style: AppTheme.poppins(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Recherchez un village, une ville ou un district',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        Text('Suggestions',
            style: AppTheme.poppins(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map((nom) => GestureDetector(
                    onTap: () {
                      _controller.text = nom;
                      _rechercher(nom);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(nom,
                          style: AppTheme.poppins(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResultats() {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator());
    }

    final tous = <dynamic>[..._locales, ..._nominatim];
    if (tous.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Aucun lieu trouvé à Madagascar',
                style: AppTheme.poppins(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Essayez un autre nom de localité',
                style: TextStyle(fontSize: 11, color: AppTheme.textDim)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_locales.isNotEmpty) ...[
          Text('Villes principales',
              style: AppTheme.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentBlueLight)),
          const SizedBox(height: 6),
          ..._locales.map((ville) => _carte(
                nom: ville.nom,
                sousTitre: ville.region,
                icone: Icons.location_city,
                couleur: AppTheme.accentBlue,
                onTap: () => _selectionner(ville),
              )),
          const SizedBox(height: 10),
        ],
        if (_nominatim.isNotEmpty) ...[
          Text('Autres localités',
              style: AppTheme.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentGreenLight)),
          const SizedBox(height: 6),
          ..._nominatim.map((r) {
            final v = _geo.geocodingToVille(r);
            return _carte(
              nom: r.nom.split(',').first.trim(),
              sousTitre: r.region ?? r.type,
              icone: _typeIcone(r.type),
              couleur: AppTheme.accentGreen,
              onTap: () {
                _villeRepo.insererVille(v);
                _selectionner(v);
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _carte({
    required String nom,
    required String sousTitre,
    required IconData icone,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, size: 18, color: couleur),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nom,
                      style: AppTheme.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(sousTitre,
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }

  IconData _typeIcone(String type) {
    switch (type) {
      case 'city':
      case 'town':
        return Icons.location_city;
      case 'village':
        return Icons.house;
      case 'hamlet':
        return Icons.home;
      case 'island':
        return Icons.public;
      case 'mountain':
      case 'peak':
        return Icons.terrain;
      case 'river':
        return Icons.water;
      default:
        return Icons.place;
    }
  }
}
