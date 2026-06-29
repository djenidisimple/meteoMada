import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/utils/weather_helper.dart';

class ForecastRow extends StatelessWidget {
  final String jour;
  final String date;
  final String condition;
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
    required this.condition,
    required this.tempMin,
    required this.tempMax,
    this.probabilitePluie,
    this.vitesseVent,
    this.indiceUV,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = WeatherHelper.conditionIcon(condition);
    final iconCol = WeatherHelper.conditionColor(condition);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: isToday
          ? AppTheme.glassActive(radius: 16, accent: AppTheme.accentBlue)
          : AppTheme.glass(radius: 16),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              jour,
              style: AppTheme.poppins(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconCol.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconCol),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              condition,
              style: AppTheme.poppins(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${tempMin.toStringAsFixed(0)}°',
            style: AppTheme.poppins(
              fontSize: 11,
              color: AppTheme.textDim,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${tempMax.toStringAsFixed(0)}°',
              style: AppTheme.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
