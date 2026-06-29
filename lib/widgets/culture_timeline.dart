import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class CultureTimeline extends StatelessWidget {
  final int moisSemisDebut;
  final int moisSemisFin;
  final int moisRecolteDebut;
  final int moisRecolteFin;

  const CultureTimeline({
    super.key,
    required this.moisSemisDebut,
    required this.moisSemisFin,
    required this.moisRecolteDebut,
    required this.moisRecolteFin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('JANV ← → DÉC',
            style: TextStyle(fontSize: 9, color: AppTheme.textDim)),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withValues(alpha: 0.07),
          ),
          child: Stack(
            children: [
              _bar(screenWidth, moisSemisDebut, _monthSpan(moisSemisDebut, moisSemisFin),
                  AppTheme.accentBlue),
              _bar(screenWidth, moisRecolteDebut,
                  _monthSpan(moisRecolteDebut, moisRecolteFin),
                  AppTheme.accentOrange),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('🌱 Semis: ${_monthName(moisSemisDebut)}–${_monthName(moisSemisFin)}',
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            const Spacer(),
            Text('🌿 Récolte: ${_monthName(moisRecolteDebut)}–${_monthName(moisRecolteFin)}',
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _bar(double screenWidth, int startMonth, int span, Color color) {
    final left = (startMonth - 1) / 12.0;
    final width = span.clamp(0, 12) / 12.0;
    return Positioned(
      left: left * screenWidth * 0.5,
      top: 1,
      child: Container(
        height: 6,
        width: (screenWidth * 0.5 - 32) * width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  int _monthSpan(int start, int end) {
    if (end >= start) return end - start + 1;
    return (12 - start + 1) + end;
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return names[m - 1];
  }
}
