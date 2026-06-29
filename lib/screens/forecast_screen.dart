import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';

class ForecastScreen extends StatelessWidget {
  final String villeId;
  const ForecastScreen({super.key, required this.villeId});

  IconData _conditionIcon(String condition) {
    if (condition.contains('dégagé')) return Icons.wb_sunny;
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return Icons.wb_cloudy;
    if (condition.contains('Brumeux')) return Icons.cloud;
    if (condition.contains('Pluie') || condition.contains('Bruine')) return Icons.water_drop;
    if (condition.contains('Averses')) return Icons.umbrella;
    if (condition.contains('Orage')) return Icons.flash_on;
    return Icons.cloud_queue;
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prévisions 7 jours',
                  style: AppTheme.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              Consumer<WeatherProvider>(
                builder: (_, wp, __) => Text(wp.villeActuelle?.nom ?? '',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
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
                    Text('Aucune prévision disponible',
                        style: AppTheme.poppins(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            final maxT = previsions.fold<double>(0, (m, p) => p.temperature > m ? p.temperature : m);
            final minT = previsions.fold<double>(50, (m, p) => p.temperatureRessentie < m ? p.temperatureRessentie : m);

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: previsions.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _resumeCard(previsions, maxT, minT);
                }
                final idx = i - 1;
                final p = previsions[idx];
                final estAujourdhui = idx == 0;
                final jour = estAujourdhui ? "Aujourd'hui" : _jourSemaine(p.dateHeure.weekday);
                final date = '${p.dateHeure.day} ${_mois(p.dateHeure.month)}';
                return ForecastRow(
                  jour: jour,
                  date: date,
                  icone: Icon(_conditionIcon(p.condition), color: Colors.white, size: 20),
                  tempMin: p.temperatureRessentie,
                  tempMax: p.temperature,
                  probabilitePluie: p.probabilitePluie > 0 ? p.probabilitePluie : null,
                  vitesseVent: p.vitesseVent > 0 ? p.vitesseVent : null,
                  indiceUV: p.indiceUV > 0 ? p.indiceUV : null,
                  isToday: estAujourdhui,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _resumeCard(List<dynamic> previsions, double maxT, double minT) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withValues(alpha: 0.10),
            AppTheme.accentGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Résumé de la semaine',
                    style: AppTheme.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${previsions.length} jours de prévisions',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            children: [
              Text('${maxT.toStringAsFixed(0)}°',
                  style: AppTheme.poppins(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.accentOrange)),
              Text('Max',
                  style: TextStyle(fontSize: 9, color: AppTheme.textDim)),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text('${minT.toStringAsFixed(0)}°',
                  style: AppTheme.poppins(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.accentBlue)),
              Text('Min',
                  style: TextStyle(fontSize: 9, color: AppTheme.textDim)),
            ],
          ),
        ],
      ),
    );
  }
}
