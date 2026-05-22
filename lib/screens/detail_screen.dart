import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/providers/weather_provider.dart';

class DetailScreen extends StatelessWidget {
  final String villeId;

  const DetailScreen({super.key, required this.villeId});

  Color _uvColor(double uv) {
    if (uv <= 2) return AppTheme.accentGreen;
    if (uv <= 5) return AppTheme.accentYellow;
    if (uv <= 7) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  String _uvLabel(double uv) {
    if (uv <= 2) return 'Faible';
    if (uv <= 5) return 'Modéré';
    if (uv <= 7) return 'Élevé';
    return 'Extrême';
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
          title: Consumer<WeatherProvider>(
            builder: (_, wp, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wp.villeActuelle?.nom ?? 'Antananarivo',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(
                      'Aujourd\'hui, ${DateTime.now().day} ${_mois(DateTime.now().month)}',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              );
            },
          ),
          actions: [
            Text('⛅', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final p = wp.previsionActuelle;
            if (p == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌡', style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text('${p.temperature.toStringAsFixed(1)}°C',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('Température',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('💧', style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text('${p.humidite.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('Humidité',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('💨', style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text('${p.vitesseVent.toStringAsFixed(0)} km/h',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('Vent · ${p.directionVent}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🔽', style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text('1015 hPa',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text('Pression',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      _uvCard(p.indiceUV),
                      _airQualityCard(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.accentYellow.withOpacity(0.28),
                                width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Text('🌅', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text('06:15',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text('Lever',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.accentOrange.withOpacity(0.28),
                                width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Text('🌇', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text('17:30',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text('Coucher',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Text('🌙', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lune gibbeuse décroissante',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            Text('Illumination 78% · Lever 22:14',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _uvCard(double uv) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.accentBlue.withOpacity(0.35), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text('☀️', style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text(_uvLabel(uv),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _uvColor(uv))),
            ],
          ),
          const SizedBox(height: 4),
          Text(uv.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text('UV',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (uv / 11).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(_uvColor(uv)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _airQualityCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.marineCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌬', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text('Bonne',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text('Qualité air',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text('Indice: 42',
              style: TextStyle(fontSize: 9, color: AppTheme.textDim)),
        ],
      ),
    );
  }

  String _mois(int m) {
    const mois = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return mois[m - 1];
  }
}
