import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/metric_strip.dart';
import 'package:meteomada/widgets/hourly_card.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  IconData _conditionIcon(String condition) {
    if (condition.contains('dégagé')) return Icons.wb_sunny;
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return Icons.wb_cloudy;
    if (condition.contains('Brumeux')) return Icons.cloud;
    if (condition.contains('Pluie') || condition.contains('Bruine')) return Icons.water_drop;
    if (condition.contains('Averses')) return Icons.umbrella;
    if (condition.contains('Orage')) return Icons.flash_on;
    return Icons.cloud_queue;
  }

  Color _conditionColor(String condition) {
    if (condition.contains('dégagé')) return AppTheme.accentYellow;
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return AppTheme.accentBlue;
    if (condition.contains('Pluie') || condition.contains('Bruine')) return AppTheme.accentBlueLight;
    if (condition.contains('Orage')) return AppTheme.accentRed;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return WeatherGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer2<WeatherProvider, AlerteProvider>(
          builder: (context, weather, alerte, _) {
            final p = weather.previsionActuelle;
            final ville = weather.villeActuelle;

            if (weather.chargement && p == null) {
              return const LoadingView(message: "Chargement de la météo...");
            }

            final erreur = weather.erreur;
            final condition = p?.condition ?? 'Partiellement nuageux';
            final temp = p?.temperature;
            final ressenti = p?.temperatureRessentie;

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (ville != null) await weather.chargerMeteo(ville);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _header(context, ville, alerte.countActives),
                      const SizedBox(height: 20),
                      _mainWeather(context, condition, temp, ressenti, ville),
                      if (erreur != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRed.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.20)),
                            ),
                            child: Row(
                              children: [
                                const Text('⚠️', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(erreur,
                                      style: TextStyle(fontSize: 11, color: AppTheme.accentRed)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (p != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MetricStrip(
                            humidite: p.humidite,
                            vitesseVent: p.vitesseVent,
                            visibilite: 10,
                            indiceUV: p.indiceUV,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (ville != null && ville.estCotiere)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InkWell(
                            onTap: () => context.go('/home/marine/${ville.id}'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentGreen.withValues(alpha: 0.15),
                                    AppTheme.accentGreen.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppTheme.accentGreen.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(child: Text('🌊', style: TextStyle(fontSize: 22))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Météo marine',
                                            style: AppTheme.poppins(
                                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                        Text('Vagues, marées, vent côtier',
                                            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: AppTheme.accentGreenLight, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      _sectionHeader(context, 'Prévisions horaires', () {
                        final id = ville?.id ?? 'antananarivo';
                        context.push('/home/hourly/$id');
                      }),
                      const SizedBox(height: 10),
                      _hourlyForecast(context, weather, ville, condition),
                      const SizedBox(height: 20),
                      _sectionHeader(context, 'Prévisions 7 jours', () {
                        final id = ville?.id ?? 'antananarivo';
                        context.push('/home/forecast/$id');
                      }),
                      const SizedBox(height: 8),
                      _dailyForecast(context, weather, ville, condition),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, dynamic ville, int alertesCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.push('/plus/settings'),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          _locationChip(context, ville?.nom ?? 'Antananarivo'),
          const Spacer(),
          InkWell(
            onTap: () => context.push('/plus/alertes'),
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: alertesCount > 0
                        ? AppTheme.accentRed.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: alertesCount > 0
                          ? AppTheme.accentRed.withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    alertesCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                    color: alertesCount > 0 ? AppTheme.accentRed : Colors.white,
                    size: 18,
                  ),
                ),
                if (alertesCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentRed,
                        border: Border.all(color: AppTheme.backgroundDark, width: 1.5),
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

  Widget _locationChip(BuildContext context, String ville) {
    return InkWell(
      onTap: () => context.push('/favoris/search'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentBlue),
            const SizedBox(width: 4),
            Flexible(
              child: Text(ville,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _mainWeather(BuildContext context, String condition, double? temp, double? ressenti, dynamic ville) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _conditionColor(condition).withValues(alpha: 0.08),
          ),
          child: Icon(_conditionIcon(condition), size: 44, color: _conditionColor(condition)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              temp?.toStringAsFixed(0) ?? '--',
              style: AppTheme.poppins(
                  fontSize: 72, fontWeight: FontWeight.w800, letterSpacing: -4, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('°C',
                  style: AppTheme.poppins(
                      fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(condition,
            style: AppTheme.poppins(fontSize: 14, color: AppTheme.textSecondary, letterSpacing: 0.05)),
        const SizedBox(height: 4),
        Text(
          ville?.nom ?? 'Antananarivo',
          style: AppTheme.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        if (ressenti != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('Ressenti $ressenti°C',
                style: TextStyle(fontSize: 12, color: AppTheme.textDim)),
          ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String titre, VoidCallback onVoirTout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(titre,
                  style: AppTheme.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          GestureDetector(
            onTap: onVoirTout,
            child: Row(
              children: [
                Text('Voir tout',
                    style: AppTheme.poppins(fontSize: 12, color: AppTheme.accentBlue)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 14, color: AppTheme.accentBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hourlyForecast(BuildContext context, WeatherProvider weather, dynamic ville, String condition) {
    final horaires = weather.previsionsHoraires;
    if (horaires.isNotEmpty) {
      return SizedBox(
        height: 114,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: horaires.length.clamp(0, 12),
          itemBuilder: (context, i) {
            final h = horaires[i];
            final heure = '${h.dateHeure.hour.toString().padLeft(2, '0')}h';
            return GestureDetector(
              onTap: () {
                final id = ville?.id ?? 'antananarivo';
                context.push('/home/hourly/$id');
              },
              child: HourlyCard(
                heure: heure,
                icone: _conditionIcon(h.condition),
                temp: '${h.temperature.toStringAsFixed(0)}°',
                isActive: i == 0,
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 114,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 8,
        itemBuilder: (context, i) {
          final now = DateTime.now();
          final h = (now.hour + i * 3) % 24;
          final heure = '${h.toString().padLeft(2, '0')}h';
          return GestureDetector(
            onTap: () {
              final id = ville?.id ?? 'antananarivo';
              context.push('/home/hourly/$id');
            },
            child: HourlyCard(
              heure: heure,
              icone: i == 0 ? Icons.wb_cloudy : i % 2 == 0 ? Icons.wb_sunny : Icons.cloud,
              temp: '${(weather.previsionActuelle?.temperature ?? 27) + (i * 1.5 - 2)}°',
              isActive: i == 0,
            ),
          );
        },
      ),
    );
  }

  Widget _dailyForecast(BuildContext context, WeatherProvider weather, dynamic ville, String condition) {
    return Column(
      children: List.generate(
        weather.previsions7Jours.length.clamp(0, 7),
        (i) {
          final p = weather.previsions7Jours[i];
          final estAujourdhui = i == 0;
          final jour = estAujourdhui ? "Aujourd'hui" : _jourSemaine(p.dateHeure.weekday);
          final date = '${p.dateHeure.day} ${_mois(p.dateHeure.month)}';
          return GestureDetector(
            onTap: () {
              final id = ville?.id ?? 'antananarivo';
              context.push('/home/forecast/$id');
            },
            child: ForecastRow(
              jour: jour,
              date: date,
              icone: Icon(_conditionIcon(p.condition), color: Colors.white, size: 20),
              tempMin: p.temperatureRessentie,
              tempMax: p.temperature,
              probabilitePluie: p.probabilitePluie > 0 ? p.probabilitePluie : null,
              vitesseVent: p.vitesseVent > 0 ? p.vitesseVent : null,
              indiceUV: p.indiceUV > 0 ? p.indiceUV : null,
              isToday: estAujourdhui,
            ),
          );
        },
      ),
    );
  }

  String _jourSemaine(int weekday) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return jours[weekday - 1];
  }

  String _mois(int m) {
    const mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return mois[m - 1];
  }
}
