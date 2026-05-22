import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/forecast_row.dart';
import 'package:meteomada/providers/weather_provider.dart';

class ForecastScreen extends StatelessWidget {
  final String villeId;
  const ForecastScreen({super.key, required this.villeId});

  String _conditionEmoji(String condition) {
    if (condition.contains('dégagé')) return '☀️';
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return '⛅';
    if (condition.contains('Brumeux')) return '🌫️';
    if (condition.contains('Pluie') || condition.contains('Bruine')) return '🌧️';
    if (condition.contains('Averses')) return '🌦️';
    if (condition.contains('Orage')) return '⛈️';
    return '☁️';
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
          title: Text('Prévisions 7 jours',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final previsions = wp.previsions7Jours;
            if (previsions.isEmpty && wp.chargement) {
              return const Center(child: CircularProgressIndicator());
            }
            if (previsions.isEmpty) {
              return Center(
                child: Text('Aucune prévision disponible',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppTheme.textSecondary)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: previsions.length,
              itemBuilder: (_, i) {
                final p = previsions[i];
                final estAujourdhui = i == 0;
                final jour = estAujourdhui
                    ? "Aujourd'hui"
                    : _jourSemaine(p.dateHeure.weekday);
                final date =
                    '${p.dateHeure.day} ${_mois(p.dateHeure.month)}';
                return ForecastRow(
                  jour: jour,
                  date: date,
                  emoji: _conditionEmoji(p.condition),
                  tempMin: p.temperature - 3,
                  tempMax: p.temperature + 3,
                  probabilitePluie:
                      p.probabilitePluie > 0 ? p.probabilitePluie : null,
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
}
