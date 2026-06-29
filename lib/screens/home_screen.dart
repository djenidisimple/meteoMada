import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/metric_strip.dart';
import 'package:meteomada/widgets/hourly_card.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/utils/weather_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.homeScreenGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer2<WeatherProvider, AlerteProvider>(
          builder: (context, weather, alerte, _) {
            final p = weather.previsionActuelle;
            final ville = weather.villeActuelle;

            if (weather.chargement && p == null) {
              return const LoadingView(message: "Chargement de la météo...");
            }

            final condition = p?.condition ?? 'Partiellement nuageux';
            final temp = p?.temperature;

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (ville != null) await weather.chargerMeteo(ville);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _header(context),
                      const SizedBox(height: 16),
                      _locationBlock(context,
                          ville: ville?.nom ?? 'Fianarantsoa',
                          pays: 'Madagascar'),
                      const SizedBox(height: 24),
                      _sunFlare(
                        child: _mainWeatherIllustration(context, condition),
                      ),
                      const SizedBox(height: 8),
                      _temperatureDisplay(temp: temp, condition: condition),
                      const SizedBox(height: 6),
                      _conditionDescription(condition),
                      const SizedBox(height: 28),
                      if (p != null)
                        MetricStrip(
                          humidite: p.humidite,
                          vitesseVent: p.vitesseVent,
                          probabilitePluie: p.probabilitePluie,
                          indiceUV: p.indiceUV,
                        ),
                      const SizedBox(height: 24),
                      if (weather.erreur != null)
                        _errorBanner(weather.erreur!),
                      if (ville != null && ville.estCotiere)
                        _marineBanner(context, ville),
                      const SizedBox(height: 8),
                      _hourlySectionHeader(context, () {
                        final id = ville?.id ?? 'antananarivo';
                        context.push('/home/hourly/$id');
                      }),
                      const SizedBox(height: 12),
                      _hourlyForecast(context, weather, ville),
                      const SizedBox(height: 24),
                      _sectionHeader(context, 'Prévisions 7 jours', () {
                        final id = ville?.id ?? 'antananarivo';
                        context.push('/home/forecast/$id');
                      }),
                      const SizedBox(height: 8),
                      _dailyForecast(context, weather, ville),
                      const SizedBox(height: 120),
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

  // ─── HEADER ──────────────────────────────────────────────
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.push('/plus/settings'),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 12,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Fianarantsoa, Madagascar',
            style: AppTheme.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => context.push('/plus/calendrier'),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                CupertinoIcons.calendar,
                size: 22,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOCATION BLOCK ──────────────────────────────────────
  Widget _locationBlock(BuildContext context,
      {required String ville, required String pays}) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: ville,
          style: AppTheme.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: ', $pays',
              style: AppTheme.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUN FLARE ───────────────────────────────────────────
  Widget _sunFlare({required Widget child}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: AppTheme.sunFlareDecoration(),
        ),
        child,
      ],
    );
  }

  // ─── MAIN WEATHER ILLUSTRATION ───────────────────────────
  Widget _mainWeatherIllustration(BuildContext context, String condition) {
    final conditionIcon = WeatherHelper.conditionIcon(condition);
    return SizedBox(
      width: 200,
      height: 180,
      child: Image.asset(
        'assets/images/3d_rain_sun.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            conditionIcon,
            size: 120,
            color: WeatherHelper.conditionColor(condition),
          );
        },
      ),
    );
  }

  // ─── TEMPERATURE DISPLAY ─────────────────────────────────
  Widget _temperatureDisplay({double? temp, required String condition}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            temp?.toStringAsFixed(0) ?? '29',
            style: AppTheme.poppins(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '°C',
              style: AppTheme.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONDITION DESCRIPTION ───────────────────────────────
  Widget _conditionDescription(String condition) {
    final desc = _descriptionForCondition(condition);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        desc,
        style: AppTheme.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _descriptionForCondition(String condition) {
    if (condition.contains('dégagé') || condition.contains('Ciel dégagé')) {
      return 'Clear skies all day.';
    }
    if (condition.contains('nuageux') || condition.contains('Partiellement')) {
      return 'Expect high rain today.';
    }
    if (condition.contains('Pluie') || condition.contains('Bruine')) {
      return 'Rain expected throughout the day.';
    }
    if (condition.contains('Orage')) {
      return 'Thunderstorms likely. Stay indoors.';
    }
    return 'Variable conditions today.';
  }

  // ─── ERROR BANNER ────────────────────────────────────────
  Widget _errorBanner(String erreur) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.dangerCard,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 18, color: AppTheme.accentRed),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                erreur,
                style: AppTheme.poppins(
                    fontSize: 11, color: AppTheme.accentRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MARINE BANNER ───────────────────────────────────────
  Widget _marineBanner(BuildContext context, Ville ville) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        borderRadius: 20,
        tintColor: AppTheme.accentGreen,
        onTap: () => context.go('/home/marine/${ville.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.water, size: 22, color: AppTheme.accentGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Météo marine',
                    style: AppTheme.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Conditions côtières et état de la mer',
                    style: AppTheme.poppins(
                        fontSize: 11, color: AppTheme.textDim),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.accentGreenLight, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── HOURLY SECTION HEADER ───────────────────────────────
  Widget _hourlySectionHeader(BuildContext context, VoidCallback onVoirTout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Hourly Forecast',
                style: AppTheme.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onVoirTout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Text(
                    'Voir tout',
                    style: AppTheme.poppins(
                        fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded,
                      size: 14, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION HEADER ──────────────────────────────────────
  Widget _sectionHeader(
      BuildContext context, String titre, VoidCallback onVoirTout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                titre,
                style: AppTheme.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onVoirTout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Text(
                    'Voir tout',
                    style: AppTheme.poppins(
                        fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 14, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HOURLY FORECAST ─────────────────────────────────────
  Widget _hourlyForecast(
      BuildContext context, WeatherProvider weather, Ville? ville) {
    final horaires = weather.previsionsHoraires;
    if (horaires.isNotEmpty) {
      return SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: horaires.length.clamp(0, 12),
          itemBuilder: (context, i) {
            final h = horaires[i];
            final heure = i == 0
                ? 'Now'
                : '${h.dateHeure.hour.toString().padLeft(2, '0')}pm';
            return GestureDetector(
              onTap: () {
                final id = ville?.id ?? 'antananarivo';
                context.push('/home/hourly/$id');
              },
              child: HourlyCard(
                heure: heure,
                icone: WeatherHelper.conditionIcon(h.condition),
                temp: '${h.temperature.toStringAsFixed(0)}°',
                isActive: i == 0,
                iconColor: WeatherHelper.conditionColor(h.condition),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 8,
        itemBuilder: (context, i) {
          final now = DateTime.now();
          final h = (now.hour + i * 3) % 24;
          final heure = i == 0
              ? 'Now'
              : '${h.toString().padLeft(2, '0')}pm';
          return GestureDetector(
            onTap: () {
              final id = ville?.id ?? 'antananarivo';
              context.push('/home/hourly/$id');
            },
            child: HourlyCard(
              heure: heure,
              icone: i == 0
                  ? Icons.wb_cloudy
                  : i % 2 == 0
                      ? Icons.wb_sunny
                      : Icons.cloud,
              temp:
                  '${(weather.previsionActuelle?.temperature ?? 27) + (i * 1.5 - 2)}°',
              isActive: i == 0,
            ),
          );
        },
      ),
    );
  }

  // ─── 7-DAY FORECAST ──────────────────────────────────────
  Widget _dailyForecast(
      BuildContext context, WeatherProvider weather, Ville? ville) {
    return Column(
      children: List.generate(
        weather.previsions7Jours.length.clamp(0, 7),
        (i) {
          final p = weather.previsions7Jours[i];
          final estAujourdhui = i == 0;
          final jour = estAujourdhui
              ? "Aujourd'hui"
              : WeatherHelper.jourSemaine(p.dateHeure.weekday);
          final date =
              '${p.dateHeure.day} ${WeatherHelper.mois(p.dateHeure.month)}';
          return GestureDetector(
            onTap: () {
              final id = ville?.id ?? 'antananarivo';
              context.push('/home/forecast/$id');
            },
            child: ForecastRow(
              jour: jour,
              date: date,
              condition: p.condition,
                    tempMin: p.temperatureMin,
                    tempMax: p.temperatureMax,
              probabilitePluie:
                  p.probabilitePluie > 0 ? p.probabilitePluie : null,
              vitesseVent: p.vitesseVent > 0 ? p.vitesseVent : null,
              indiceUV: p.indiceUV > 0 ? p.indiceUV : null,
              isToday: estAujourdhui,
            ),
          );
        },
      ),
    );
  }
}
