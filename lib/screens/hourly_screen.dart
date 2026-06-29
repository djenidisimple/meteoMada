import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/utils/weather_helper.dart';

class HourlyScreen extends StatefulWidget {
  final String villeId;
  const HourlyScreen({super.key, required this.villeId});

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  int _selectedDay = 0;

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
          title: Text(
            'Prévisions horaires',
            style: AppTheme.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final horaires = wp.previsionsHoraires;
            final p = wp.previsionActuelle;
            if (wp.chargement && p == null) {
              return const LoadingView(
                  message: "Chargement des prévisions...");
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
                    _sectionTitle('Température', AppTheme.accentOrange),
                    const SizedBox(height: 6),
                    _tempChart(data),
                    const SizedBox(height: 20),
                    _sectionTitle('Détail par heure', AppTheme.accentBlue),
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

  Widget _sectionTitle(String titre, Color accent) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          titre,
          style: AppTheme.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ],
    );
  }

  Widget _toggleJours() {
    final options = ["Aujourd'hui", 'Demain', 'J+2'];
    return Row(
      children: List.generate(options.length, (i) {
        final isActive = i == _selectedDay;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: Container(
              margin: EdgeInsets.only(
                  right: i < options.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: isActive
                  ? AppTheme.glassActive(
                      radius: 14, accent: AppTheme.accentBlue)
                  : AppTheme.glass(radius: 14),
              child: Text(
                options[i],
                textAlign: TextAlign.center,
                style: AppTheme.poppins(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppTheme.accentBlue
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _tempChart(List<Prevision> data) {
    final maxTemp = data.fold<double>(
        0, (m, h) => h.temperature > m ? h.temperature : m);
    final minTemp = data.fold<double>(
        100, (m, h) => h.temperature < m ? h.temperature : m);
    final range = (maxTemp - minTemp).clamp(1, 50);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glass(radius: 20),
      child: SizedBox(
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
                  Text(
                    '${h.temperature.toStringAsFixed(0)}°',
                    style: AppTheme.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.accentBlue,
                          AppTheme.accentOrange,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${h.dateHeure.hour}h',
                    style: AppTheme.poppins(
                        fontSize: 8, color: AppTheme.textDim),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _heureTile(Prevision h, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: isActive
          ? AppTheme.glassActive(
              radius: 18, accent: AppTheme.accentBlue)
          : AppTheme.glass(radius: 18),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${h.dateHeure.hour}h',
              style: AppTheme.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            WeatherHelper.conditionIcon(h.condition),
            size: 22,
            color: WeatherHelper.conditionColor(h.condition),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.condition,
                  style: AppTheme.poppins(
                      fontSize: 13, color: Colors.white),
                ),
                Text(
                  '💧 ${h.humidite.toStringAsFixed(0)}% · 💨 ${h.vitesseVent.toStringAsFixed(0)} km/h',
                  style: AppTheme.poppins(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${h.temperature.toStringAsFixed(0)}°',
            style: AppTheme.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _heureTileMock(String heure, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: i == 0
          ? AppTheme.glassActive(
              radius: 18, accent: AppTheme.accentBlue)
          : AppTheme.glass(radius: 18),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              heure,
              style: AppTheme.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            i % 3 == 0
                ? Icons.wb_cloudy
                : i % 3 == 1
                    ? Icons.wb_sunny
                    : Icons.cloud,
            size: 22,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i == 0
                      ? 'Partiellement nuageux'
                      : i % 2 == 0
                          ? 'Ensoleillé'
                          : 'Nuageux',
                  style: AppTheme.poppins(
                      fontSize: 13, color: Colors.white),
                ),
                Text(
                  '💧 ${50 + i * 5}% · 💨 ${10 + i} km/h',
                  style: AppTheme.poppins(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${27 + (i * 1.5 - 2)}°',
            style: AppTheme.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
