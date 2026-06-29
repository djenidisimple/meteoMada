import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/culture_timeline.dart';
import 'package:meteomada/providers/calendrier_provider.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/widgets/loading_view.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cp = context.read<CalendrierProvider>();
    cp.initialiser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('Calendrier Cultural',
              style: AppTheme.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: Consumer<CalendrierProvider>(
          builder: (_, cp, __) {
            if (cp.chargement) {
              return const LoadingView(message: 'Chargement du calendrier...');
            }
            if (cp.regions.isEmpty && cp.donnees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco_outlined, size: 48, color: AppTheme.textDim),
                    const SizedBox(height: 16),
                    Text('Aucune donnée disponible',
                        style: AppTheme.poppins(
                            fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendrier Cultural',
                      style: AppTheme.poppins(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Conseils météo par culture · Madagascar',
                      style: AppTheme.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  _buildSearchBar(cp),
                  const SizedBox(height: 12),
                  if (cp.regions.isNotEmpty) _buildRegionChips(cp),
                  const SizedBox(height: 16),
                  if (cp.filtered.isEmpty)
                    _buildEmptyState(cp)
                  else
                    ...cp.filtered.map((c) => _cultureCard(c)),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(CalendrierProvider cp) {
    return Container(
      decoration: AppTheme.glass(radius: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, size: 16, color: AppTheme.textDim),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => cp.setRecherche(v),
              style: AppTheme.poppins(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une culture ou une région...',
                hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                cp.setRecherche('');
              },
              child: Icon(CupertinoIcons.clear_circled_solid,
                  size: 14, color: AppTheme.textDim),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionChips(CalendrierProvider cp) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => cp.setRegion(null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: cp.regionSelectionnee == null
                    ? AppTheme.activeCard
                    : AppTheme.glassCard,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.globe, size: 10),
                    const SizedBox(width: 4),
                    Text('Toutes',
                        style: AppTheme.poppins(
                            fontSize: 11,
                            color: cp.regionSelectionnee == null
                                ? AppTheme.accentBlue
                                : AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          ...cp.regions.map((r) {
            final isActive = r == cp.regionSelectionnee;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => cp.setRegion(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: isActive ? AppTheme.activeCard : AppTheme.glassCard,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.map_pin_ellipse, size: 10),
                      const SizedBox(width: 4),
                      Text(r,
                          style: AppTheme.poppins(
                              fontSize: 11,
                              color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CalendrierProvider cp) {
    String message;
    IconData icon;
    if (_searchController.text.isNotEmpty) {
      message = 'Aucun résultat pour "${_searchController.text}"';
      icon = CupertinoIcons.search;
    } else if (cp.regionSelectionnee == null) {
      message = 'Sélectionnez une région';
      icon = CupertinoIcons.map_pin_ellipse;
    } else {
      message = 'Aucune donnée pour ${cp.regionSelectionnee}';
      icon = Icons.eco_outlined;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppTheme.textDim),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTheme.poppins(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _cultureCard(CalendrierCultural c) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final isActive = c.moisSemisDebut <= currentMonth && currentMonth <= c.moisSemisFin;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accentGreen.withValues(alpha: 0.12)
                        : AppTheme.accentBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(c.typeCultureIcon, size: 18,
                        color: isActive ? AppTheme.accentGreen : AppTheme.accentBlue),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.typeCultureLabel,
                      style: AppTheme.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: isActive
                      ? AppTheme.marineCard
                      : AppTheme.watchCard,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? CupertinoIcons.check_mark_circled : CupertinoIcons.clock,
                        size: 10,
                        color: isActive ? AppTheme.accentGreenLight : AppTheme.accentYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(isActive ? 'Saison active' : 'À venir',
                          style: AppTheme.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppTheme.accentGreenLight
                                  : AppTheme.accentYellow)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CultureTimeline(
              moisSemisDebut: c.moisSemisDebut,
              moisSemisFin: c.moisSemisFin,
              moisRecolteDebut: c.moisRecolteDebut,
              moisRecolteFin: c.moisRecolteFin,
            ),
            if (c.conseilsMeteo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: AppTheme.accentGreen.withValues(alpha: 0.18), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.lightbulb, size: 12,
                        color: AppTheme.accentYellow),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c.conseilsMeteo,
                          style: AppTheme.poppins(
                              fontSize: 11,
                              height: 1.5,
                              color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
