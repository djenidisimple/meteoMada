import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/wave_bar_chart.dart';
import 'package:meteomada/providers/marine_provider.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';

class MarineScreen extends StatefulWidget {
  final String villeId;
  const MarineScreen({super.key, required this.villeId});

  @override
  State<MarineScreen> createState() => _MarineScreenState();
}

class _MarineScreenState extends State<MarineScreen> {
  @override
  void initState() {
    super.initState();
    final wp = context.read<WeatherProvider>();
    final mp = context.read<MarineProvider>();
    final ville = wp.villeActuelle;
    if (ville != null) {
      mp.chargerCondition(widget.villeId, ville.latitude, ville.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final mp = context.watch<MarineProvider>();
    final c = mp.condition;
    final ville = wp.villeActuelle;

    return MarineGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Text(ville?.nom ?? 'Antananarivo',
                  style: AppTheme.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('🏝 Ville côtière',
                    style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.accentGreenLight,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text('MàJ 14:30',
                  style:
                      TextStyle(fontSize: 10, color: AppTheme.textDim)),
            ],
          ),
        ),
        body: mp.chargement && c == null
            ? const LoadingView(message: "Chargement des données marines...")
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: AppTheme.glassCard,
                        child: Text('☀️ Météo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: AppTheme.marineCard,
                      child: Text('🌊 Marine',
                          textAlign: TextAlign.center,
                          style: AppTheme.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGreenLight)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main wave card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.marineCard,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HAUTEUR DES VAGUES',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textDim,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      c?.hauteurVagues
                                              .toStringAsFixed(1) ??
                                          '1.2',
                                      style: AppTheme.poppins(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.accentGreenLight)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(' m',
                                        style: AppTheme.poppins(
                                            fontSize: 22,
                                            color: AppTheme.accentGreenLight)),
                                  ),
                                ],
                              ),
                              Text(
                                  'Mer peu agitée · Houle ${c?.houle.toStringAsFixed(1) ?? '0.8'}m',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('🌊',
                                style: TextStyle(fontSize: 36)),
                            Text('Direction',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textDim)),
                            Text(c?.ventMarin ?? 'NE',
                                style: AppTheme.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: WaveBarChart(
                          hauteurVagues: c?.hauteurVagues ?? 1.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Grid metrics
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2,
                children: [
                  _marineMetric('🌡',
                      '${c?.temperatureEau.toStringAsFixed(1) ?? '26'}°C',
                      'Temp. eau',
                      AppTheme.accentBlueLight),
                  _marineMetric('🌊', c?.etatMaree ?? 'Haute',
                      'État marée', AppTheme.accentGreenLight),
                  _marineMetric('💨', c?.ventMarin ?? 'NE',
                      'Vent marin', AppTheme.accentOrangeLight),
                  _marineMetric('〰️',
                      '${c?.houle.toStringAsFixed(1) ?? '0.8'}m',
                      'Houle', AppTheme.accentYellow),
                ],
              ),
              const SizedBox(height: 16),

              // Activity badges
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      decoration: (c?.baignadeDangereuse ?? false)
                          ? AppTheme.dangerCard
                          : AppTheme.marineCard,
                      child: Row(
                        children: [
                          Text((c?.baignadeDangereuse ?? false)
                              ? '⛔'
                              : '🏊'),
                          const SizedBox(width: 8),
                          Text(
                              (c?.baignadeDangereuse ?? false)
                                  ? 'Baignade déconseillée'
                                  : 'Baignade OK',
                              style: AppTheme.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (c?.baignadeDangereuse ?? false)
                                      ? AppTheme.accentRed
                                      : AppTheme.accentGreenLight)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      decoration: (c?.pechePossible ?? true)
                          ? AppTheme.marineCard
                          : AppTheme.warningCard,
                      child: Row(
                        children: [
                          Text(
                              (c?.pechePossible ?? true) ? '🎣' : '⚠️'),
                          const SizedBox(width: 8),
                          Text(
                              (c?.pechePossible ?? true)
                                  ? 'Pêche possible'
                                  : 'Pêche déconseillée',
                              style: AppTheme.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (c?.pechePossible ?? true)
                                      ? AppTheme.accentGreenLight
                                      : AppTheme.accentOrange)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _marineMetric(
      String emoji, String valeur, String label, Color couleur) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(valeur,
                  style: AppTheme.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: couleur)),
              Text(label,
                  style:
                      TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
