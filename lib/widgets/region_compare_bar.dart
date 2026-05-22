import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meteomada/theme/app_theme.dart';

class RegionCompareBar extends StatelessWidget {
  final String nom;
  final String region;
  final String condition;
  final double valeur;
  final double maxValeur;
  final String metrique;

  const RegionCompareBar({
    super.key,
    required this.nom,
    required this.region,
    required this.condition,
    required this.valeur,
    required this.maxValeur,
    required this.metrique,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValeur > 0 ? valeur / maxValeur : 0.0;
    final cardColor = _couleurCarte(valeur, metrique);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom,
                        style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(region,
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textDim)),
                  ],
                ),
              ),
              Text('${valeur.toStringAsFixed(0)}°',
                  style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _valeurCouleur(valeur, metrique))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.white.withOpacity(0.08),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: _gradient(metrique),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(condition,
                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              const Spacer(),
              Text('💧 ${valeur.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 10, color: AppTheme.textDim)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _couleurCarte(double valeur, String metrique) {
    if (metrique == 'temperature') {
      if (valeur > 33) return AppTheme.warningCard;
      if (valeur > 28) return AppTheme.activeCard;
      if (valeur > 24) return AppTheme.marineCard;
      return AppTheme.watchCard;
    }
    return AppTheme.glassCard;
  }

  Color _valeurCouleur(double valeur, String metrique) {
    if (metrique == 'temperature') {
      if (valeur > 33) return AppTheme.accentOrange;
      if (valeur > 28) return AppTheme.accentBlue;
      if (valeur > 24) return AppTheme.accentGreen;
      return AppTheme.accentYellow;
    }
    return AppTheme.accentBlue;
  }

  Gradient _gradient(String metrique) {
    switch (metrique) {
      case 'temperature':
        return const LinearGradient(
            colors: [AppTheme.accentOrange, AppTheme.accentYellow]);
      case 'humidite':
        return const LinearGradient(
            colors: [AppTheme.accentBlue, AppTheme.accentGreen]);
      default:
        return const LinearGradient(
            colors: [AppTheme.accentBlue, AppTheme.accentBlueLight]);
    }
  }
}
