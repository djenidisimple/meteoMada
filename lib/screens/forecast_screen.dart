import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/forecast_row.dart';

class ForecastScreen extends StatelessWidget {
  final String villeId;
  const ForecastScreen({super.key, required this.villeId});

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
          title: Text('Prévisions 7 jours',
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: 7,
          itemBuilder: (_, i) {
            final jours = [
              'Aujourd\'hui', 'Demain', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
            ];
            final dates = [
              '24 Mai', '25 Mai', '26 Mai', '27 Mai',
              '28 Mai', '29 Mai', '30 Mai'
            ];
            final emojis = [
              '⛅', '☀️', '🌧️', '⛅', '☀️', '☁️', '🌦️'
            ];
            return ForecastRow(
              jour: jours[i],
              date: dates[i],
              emoji: emojis[i],
              tempMin: 20 + (i * 0.3),
              tempMax: 28 + (i * 0.7),
              probabilitePluie: i == 2 ? 75 : i == 6 ? 45 : null,
              vitesseVent: i == 0 ? 12 : null,
              indiceUV: i == 1 ? 7 : i == 4 ? 6 : null,
              isToday: i == 0,
            );
          },
        ),
      ),
    );
  }
}
