import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/metric_strip.dart';
import 'package:meteomada/widgets/hourly_card.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/alerte_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _conditionEmoji(String condition) {
    if (condition.contains('dégagé')) {
      return '☀️';
    }
    if (condition.contains('nuageux') || condition.contains('Partiellement')) {
      return '⛅';
    }
    if (condition.contains('Brumeux')) {
      return '🌫️';
    }
    if (condition.contains('Pluie') || condition.contains('Bruine')) {
      return '🌧️';
    }
    if (condition.contains('Averses')) {
      return '🌦️';
    }
    if (condition.contains('Orage')) {
      return '⛈️';
    }
    return '☁️';
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

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (ville != null) {
                    await weather.chargerMeteo(ville);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => context.push('/plus/settings'),
                              borderRadius: BorderRadius.circular(17),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: AppTheme.glassCard,
                                child: const Icon(Icons.menu_rounded,
                                    color: Colors.white, size: 18),
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
                                    width: 34,
                                    height: 34,
                                    decoration: AppTheme.glassCard,
                                    child: const Icon(Icons.notifications_none_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                  if (alerte.countActives > 0)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.accentRed,
                                          border: Border.all(
                                              color: AppTheme.backgroundDark, width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _conditionEmoji(
                                  p?.condition ?? 'Partiellement nuageux'),
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p?.temperature.toStringAsFixed(0) ?? '--',
                                  style: GoogleFonts.syne(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -4,
                                      color: Colors.white),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text('°C',
                                      style: GoogleFonts.syne(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                            Text(
                              p?.condition ?? 'Partiellement nuageux',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.05),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ville?.nom ?? 'Antananarivo',
                              style: GoogleFonts.syne(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Min 22° · Max 30° · Ressenti ${p?.temperatureRessentie.toStringAsFixed(0) ?? '--'}°',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textDim),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (p != null)
                        GestureDetector(
                          onTap: () {
                            final id = ville?.id ?? 'antananarivo';
                            context.push('/home/detail/$id');
                          },
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color:
                                        AppTheme.accentGreen.withOpacity(0.30)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🌊', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Voir météo marine',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: AppTheme.accentGreenLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prévisions horaires',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            GestureDetector(
                              onTap: () {
                                final id = ville?.id ?? 'antananarivo';
                                context.push('/home/hourly/$id');
                              },
                              child: Text('Voir tout',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppTheme.accentBlue)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                        SizedBox(
                        height: 114,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 8,
                          itemBuilder: (context, i) {
                            final now = DateTime.now();
                            final h = (now.hour + i * 3) % 24;
                            final heure =
                                '${h.toString().padLeft(2, '0')}h';
                            return GestureDetector(
                              onTap: () {
                                final id = ville?.id ?? 'antananarivo';
                                context.push('/home/hourly/$id');
                              },
                              child: HourlyCard(
                                heure: heure,
                                emoji: i == 0 ? '⛅' : i % 2 == 0 ? '☀️' : '☁️',
                                temp:
                                    '${(p?.temperature ?? 27) + (i * 1.5 - 2)}°',
                                isActive: i == 0,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prévisions 5 jours',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            GestureDetector(
                              onTap: () {
                                final id = ville?.id ?? 'antananarivo';
                                context.push('/home/forecast/$id');
                              },
                              child: Text('Voir tout',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppTheme.accentBlue)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(5, (i) {
                        final jours = [
                          'Aujourd\'hui', 'Demain', 'Mer', 'Jeu', 'Ven'
                        ];
                        final dates = [
                          '24 Mai', '25 Mai', '26 Mai', '27 Mai', '28 Mai'
                        ];
                        final emojis = ['⛅', '☀️', '🌧️', '⛅', '☀️'];
                        return GestureDetector(
                          onTap: () {
                            final id = ville?.id ?? 'antananarivo';
                            context.push('/home/forecast/$id');
                          },
                          child: ForecastRow(
                            jour: jours[i],
                            date: dates[i],
                            emoji: emojis[i],
                            tempMin: 20 + (i * 0.5),
                            tempMax: 28 + (i * 0.8),
                            probabilitePluie: i == 2 ? 75 : null,
                            vitesseVent: i == 0 ? 12 : null,
                            indiceUV: i == 1 ? 7 : null,
                            isToday: i == 0,
                          ),
                        );
                      }),
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

  Widget _locationChip(BuildContext context, String ville) {
    return InkWell(
      onTap: () => context.push('/favoris/search'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: AppTheme.glassCard,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 6),
            Text(ville,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
