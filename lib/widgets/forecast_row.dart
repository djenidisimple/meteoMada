import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meteomada/theme/app_theme.dart';

class ForecastRow extends StatelessWidget {
  final String jour;
  final String date;
  final String emoji;
  final double tempMin;
  final double tempMax;
  final double? probabilitePluie;
  final double? vitesseVent;
  final double? indiceUV;
  final bool isToday;

  const ForecastRow({
    super.key,
    required this.jour,
    required this.date,
    required this.emoji,
    required this.tempMin,
    required this.tempMax,
    this.probabilitePluie,
    this.vitesseVent,
    this.indiceUV,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final pan = tempMax - tempMin;
    final minPct = pan > 0 ? (tempMin - (tempMin - 2)) / (pan + 4) : 0.3;
    final maxPct = pan > 0 ? (tempMax - (tempMin - 2)) / (pan + 4) : 0.7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isToday ? 14 : 10),
      decoration: isToday ? AppTheme.activeCard : AppTheme.glassCard,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(jour,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                            color: Colors.white)),
                    Text(date,
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textDim)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: maxPct - minPct + 0.15,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [AppTheme.accentBlue, AppTheme.accentOrange],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${tempMin.toStringAsFixed(0)}°',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(width: 4),
                    Text('${tempMax.toStringAsFixed(0)}°',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          if (isToday && (probabilitePluie != null || vitesseVent != null || indiceUV != null))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (probabilitePluie != null)
                    _chip('💧 ${probabilitePluie!.toStringAsFixed(0)}%'),
                  if (vitesseVent != null)
                    _chip('💨 ${vitesseVent!.toStringAsFixed(0)} km/h'),
                  if (indiceUV != null) _chip('☀️ ${indiceUV!.toStringAsFixed(0)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    );
  }
}
