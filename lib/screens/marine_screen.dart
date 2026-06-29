import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
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
      mp.chargerCondition(
          widget.villeId, ville.latitude, ville.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final mp = context.watch<MarineProvider>();
    final c = mp.condition;
    final ville = wp.villeActuelle;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.marineGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 38,
              height: 38,
              decoration: AppTheme.glass(radius: 12),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Text(
                ville?.nom ?? 'Antananarivo',
                style: AppTheme.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Côtière',
                  style: AppTheme.poppins(
                      fontSize: 9,
                      color: AppTheme.accentGreenLight,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        body: mp.chargement && c == null
            ? const LoadingView(
                message: "Chargement des données marines...")
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: AppTheme.glass(radius: 14),
                              child: Text(
                                'Météo',
                                textAlign: TextAlign.center,
                                style: AppTheme.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: AppTheme.glassActive(
                                radius: 14,
                                accent: AppTheme.accentGreen),
                            child: Text(
                              'Marine',
                              textAlign: TextAlign.center,
                              style: AppTheme.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGreenLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Main wave card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassTinted(
                          radius: 24, tint: AppTheme.accentGreen),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HAUTEUR DES VAGUES',
                                      style: AppTheme.poppins(
                                          fontSize: 10,
                                          color: AppTheme.textDim,
                                          letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c?.hauteurVagues
                                                  .toStringAsFixed(1) ??
                                              '1.2',
                                          style: AppTheme.poppins(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  AppTheme.accentGreenLight),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(
                                            ' m',
                                            style: AppTheme.poppins(
                                                fontSize: 22,
                                                color:
                                                    AppTheme.accentGreenLight),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Houle ${c?.houle.toStringAsFixed(1) ?? '0.8'}m',
                                      style: AppTheme.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.water,
                                      size: 32,
                                      color: AppTheme.accentGreen),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Direction',
                                    style: AppTheme.poppins(
                                        fontSize: 11,
                                        color: AppTheme.textDim),
                                  ),
                                  Text(
                                    c?.ventMarin ?? 'NE',
                                    style: AppTheme.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                      childAspectRatio: 2.2,
                      children: [
                        _marineMetric(Icons.thermostat_outlined,
                            '${c?.temperatureEau.toStringAsFixed(1) ?? '26'}°C',
                            'Temp. eau', AppTheme.accentBlueLight),
                        _marineMetric(Icons.water_drop_outlined,
                            c?.etatMaree ?? 'Haute',
                            'État marée', AppTheme.accentGreenLight),
                        _marineMetric(Icons.air_outlined,
                            c?.ventMarin ?? 'NE',
                            'Vent marin', AppTheme.accentOrangeLight),
                        _marineMetric(Icons.waves_outlined,
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
                                : AppTheme.glassTinted(
                                    radius: 16,
                                    tint: AppTheme.accentGreen),
                            child: Row(
                              children: [
                                Icon(
                                  (c?.baignadeDangereuse ?? false)
                                      ? Icons.gpp_bad_rounded
                                      : Icons.pool_rounded,
                                  size: 18,
                                  color: (c?.baignadeDangereuse ?? false)
                                      ? AppTheme.accentRed
                                      : AppTheme.accentGreenLight,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (c?.baignadeDangereuse ?? false)
                                      ? 'Baignade déconseillée'
                                      : 'Baignade OK',
                                  style: AppTheme.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          (c?.baignadeDangereuse ?? false)
                                              ? AppTheme.accentRed
                                              : AppTheme.accentGreenLight),
                                ),
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
                                ? AppTheme.glassTinted(
                                    radius: 16,
                                    tint: AppTheme.accentGreen)
                                : AppTheme.warningCard,
                            child: Row(
                              children: [
                                Icon(
                                  (c?.pechePossible ?? true)
                                      ? Icons.set_meal_outlined
                                      : Icons.warning_amber_rounded,
                                  size: 18,
                                  color: (c?.pechePossible ?? true)
                                      ? AppTheme.accentGreenLight
                                      : AppTheme.accentOrange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (c?.pechePossible ?? true)
                                      ? 'Pêche possible'
                                      : 'Pêche déconseillée',
                                  style: AppTheme.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          (c?.pechePossible ?? true)
                                              ? AppTheme.accentGreenLight
                                              : AppTheme.accentOrange),
                                ),
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
      IconData icon, String valeur, String label, Color couleur) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: couleur),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valeur,
                style: AppTheme.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: couleur),
              ),
              Text(
                label,
                style: AppTheme.poppins(
                    fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
