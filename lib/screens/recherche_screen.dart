import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/repositories/ville_repository.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _villeRepo = VilleRepository();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Ville> _resultats = [];
  final List<String> _recentes = [];
  bool _chargement = false;

  static const _suggestions = [
    'Antananarivo',
    'Antsiranana',
    'Fianarantsoa',
    'Mahajanga',
    'Nosy Be',
  ];

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
      setState(() => _resultats = []);
      return;
    }
    setState(() => _chargement = true);
    try {
      final locaux = await _villeRepo.rechercherVilles(terme);
      setState(() => _resultats = locaux);
    } catch (_) {
      setState(() => _resultats = []);
    } finally {
      setState(() => _chargement = false);
    }
  }

  void _selectionner(Ville ville) {
    setState(() {
      _recentes.remove(ville.nom);
      _recentes.insert(0, ville.nom);
      if (_recentes.length > 5) _recentes.removeLast();
    });
    context.push('/detail/${ville.id}');
  }

  Widget _surligner(String text, String query) {
    if (query.isEmpty)
      return Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 14));
    final idx = text.toLowerCase().indexOf(query.toLowerCase());
    if (idx < 0)
      return Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 14));
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(color: AppTheme.accentBlue),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.isNotEmpty;
    return WeatherGradientBg(
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
        body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hasQuery
                                ? AppTheme.accentBlue.withOpacity(0.5)
                                : Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Rechercher une ville...',
                            hintStyle: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 15),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: AppTheme.accentBlue, size: 22),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close_rounded,
                                        color: AppTheme.textSecondary,
                                        size: 20),
                                    onPressed: () {
                                      _controller.clear();
                                      _focusNode.requestFocus();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text('Annuler',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: hasQuery ? _buildResultats() : _buildAccueil(),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildAccueil() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_recentes.isNotEmpty) ...[
          Text('Récents',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          ..._recentes.map((nom) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () => _rechercher(nom),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 18, color: AppTheme.textDim),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(nom,
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary)),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.textDim),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        Text('Suggestions',
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((nom) => GestureDetector(
                    onTap: () {
                      _controller.text = nom;
                      _rechercher(nom);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Text(nom,
                          style: GoogleFonts.poppins(
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
    if (_resultats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Aucune ville trouvée',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _resultats.length,
      itemBuilder: (_, i) {
        final ville = _resultats[i];
        final isFirst = i == 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => _selectionner(ville),
            decoration: isFirst ? AppTheme.activeCard : null,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ville.estCotiere
                        ? AppTheme.accentGreen.withOpacity(0.12)
                        : AppTheme.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(ville.estCotiere ? '🌊' : '📍',
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _surligner(ville.nom, _controller.text),
                      if (ville.estCotiere)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('🌊 Côtière',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.accentGreenLight)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('--°',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}
