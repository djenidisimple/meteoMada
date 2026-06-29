import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';

class HourlyScreen extends StatefulWidget {
  final String villeId;
  const HourlyScreen({super.key, required this.villeId});

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  int _selectedDay = 0;

  IconData _conditionIcon(String condition) {
    if (condition.contains('dégagé')) return Icons.wb_sunny;
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return Icons.wb_cloudy;
    if (condition.contains('Brumeux')) return Icons.cloud;
    if (condition.contains('Pluie') || condition.contains('Bruine')) return Icons.water_drop;
    if (condition.contains('Averses')) return Icons.umbrella;
    if (condition.contains('Orage')) return Icons.flash_on;
    return Icons.cloud_queue;
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
          title: Text('Prévisions horaires',
              style: AppTheme.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final horaires = wp.previsionsHoraires;
            final p = wp.previsionActuelle;
            if (wp.chargement && p == null) {
              return const LoadingView(message: "Chargement des prévisions...");
            }

            final data = horaires.isNotEmpty ? horaires : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _toggleJours(),
                  const SizedBox(height: 20),
                  if (data != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Température',
                            style: AppTheme.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _tempChart(data),
                    const SizedBox(height: 20),
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
                        Text('Détail par heure',
                            style: AppTheme.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...data.map((h) => _heureTile(h, h == data.first)),
                  ] else ...[
                    ...List.generate(8, (i) {
                      final now = DateTime.now();
                      final hh = (now.hour + i * 3) % 24;
                      final heure = '${hh.toString().padLeft(2, '0')}h';
                      return _heureTileMock(heure, i);
                    }),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _toggleJours() {
    final options = ['Aujourd\'hui', 'Demain', 'J+2'];
    return Row(
      children: List.generate(options.length, (i) {
        final isActive = i == _selectedDay;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: Container(
              margin: EdgeInsets.only(right: i < options.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: isActive
                  ? BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.30), width: 0.8),
                    )
                  : BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Text(options[i],
                  textAlign: TextAlign.center,
                  style: AppTheme.poppins(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
            ),
          ),
        );
      }),
    );
  }

  Widget _tempChart(List<dynamic> data) {
    final maxTemp = data.fold<double>(0, (m, h) => h.temperature > m ? h.temperature : m);
    final minTemp = data.fold<double>(100, (m, h) => h.temperature < m ? h.temperature : m);
    final range = (maxTemp - minTemp).clamp(1, 50);

    return SizedBox(
      height: 120,
      child: Row(
        children: List.generate(data.length.clamp(0, 12), (i) {
          final h = data[i];
          final ratio = ((h.temperature - minTemp) / range);
          final barHeight = ratio * 80 + 10;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${h.temperature.toStringAsFixed(0)}°',
                    style: AppTheme.poppins(
                        fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.accentBlue.withValues(alpha: 0.30),
                        AppTheme.accentOrange.withValues(alpha: 0.60),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${h.dateHeure.hour}h',
                    style: AppTheme.poppins(fontSize: 8, color: AppTheme.textDim)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _heureTile(dynamic h, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: isActive ? AppTheme.activeCard : AppTheme.glassCard,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text('${h.dateHeure.hour}h',
                style: AppTheme.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Icon(_conditionIcon(h.condition), size: 22, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.condition,
                    style: AppTheme.poppins(fontSize: 13, color: Colors.white)),
                Text('💧 ${h.humidite.toStringAsFixed(0)}% · 💨 ${h.vitesseVent.toStringAsFixed(0)} km/h',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text('${h.temperature.toStringAsFixed(0)}°',
              style: AppTheme.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _heureTileMock(String heure, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: i == 0 ? AppTheme.activeCard : AppTheme.glassCard,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(heure,
                style: AppTheme.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Icon(
              i % 3 == 0 ? Icons.wb_cloudy : i % 3 == 1 ? Icons.wb_sunny : Icons.cloud,
              size: 22, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i == 0 ? 'Partiellement nuageux' : i % 2 == 0 ? 'Ensoleillé' : 'Nuageux',
                    style: AppTheme.poppins(fontSize: 13, color: Colors.white)),
                Text('💧 ${50 + i * 5}% · 💨 ${10 + i} km/h',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text('${27 + (i * 1.5 - 2)}°',
              style: AppTheme.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
