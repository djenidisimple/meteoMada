import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/utils/weather_helper.dart';

class ForecastScreen extends StatelessWidget {
  final String villeId;
  const ForecastScreen({super.key, required this.villeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prévisions 7 jours',
                style: AppTheme.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Consumer<WeatherProvider>(
                builder: (_, wp, __) => Text(
                  wp.villeActuelle?.nom ?? '',
                  style: AppTheme.poppins(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final previsions = wp.previsions7Jours;
            if (previsions.isEmpty && wp.chargement) {
              return const Center(child: CircularProgressIndicator());
            }
            if (previsions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune prévision disponible',
                      style: AppTheme.poppins(
                          fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: previsions.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _resumeCard(previsions);
                }
                final idx = i - 1;
                final p = previsions[idx];
                final estAujourdhui = idx == 0;
                final jour = estAujourdhui
                    ? "Aujourd'hui"
                    : WeatherHelper.jourSemaine(p.dateHeure.weekday);
                final date =
                    '${p.dateHeure.day} ${WeatherHelper.mois(p.dateHeure.month)}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ForecastRow(
                    jour: jour,
                    date: date,
                    condition: p.condition,
                    tempMin: p.temperatureMin,
                    tempMax: p.temperatureMax,
                    probabilitePluie:
                        p.probabilitePluie > 0 ? p.probabilitePluie : null,
                    vitesseVent:
                        p.vitesseVent > 0 ? p.vitesseVent : null,
                    indiceUV: p.indiceUV > 0 ? p.indiceUV : null,
                    isToday: estAujourdhui,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _resumeCard(List<Prevision> previsions) {
    final maxT = previsions.fold<double>(
        0, (m, p) => p.temperatureMax > m ? p.temperatureMax : m);
    final minT = previsions.fold<double>(
        50, (m, p) => p.temperatureMin < m ? p.temperatureMin : m);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glass(radius: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: AppTheme.accentBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résumé de la semaine',
                  style: AppTheme.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${previsions.length} jours de prévisions',
                  style: AppTheme.poppins(
                      fontSize: 11, color: AppTheme.textDim),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${maxT.toStringAsFixed(0)}°',
                style: AppTheme.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentOrange,
                ),
              ),
              Text(
                'Max',
                style:
                    AppTheme.poppins(fontSize: 9, color: AppTheme.textDim),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                '${minT.toStringAsFixed(0)}°',
                style: AppTheme.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentBlue,
                ),
              ),
              Text(
                'Min',
                style:
                    AppTheme.poppins(fontSize: 9, color: AppTheme.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
