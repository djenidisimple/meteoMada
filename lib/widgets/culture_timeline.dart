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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 10, color: AppTheme.textDim),
            const SizedBox(width: 4),
            Text('Cycle cultural',
                style: AppTheme.poppins(fontSize: 10, color: AppTheme.textDim)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    _bar(totalWidth, moisSemisDebut,
                        _monthSpan(moisSemisDebut, moisSemisFin),
                        AppTheme.accentBlue),
                    _bar(totalWidth, moisRecolteDebut,
                        _monthSpan(moisRecolteDebut, moisRecolteFin),
                        AppTheme.accentOrange),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.grass_outlined, size: 12, color: AppTheme.accentBlue),
            const SizedBox(width: 4),
            Text(
              'Semis: ${_monthName(moisSemisDebut)}–${_monthName(moisSemisFin)}',
              style: AppTheme.poppins(fontSize: 10, color: AppTheme.textSecondary),
            ),
            const Spacer(),
            Icon(Icons.eco_outlined, size: 12, color: AppTheme.accentOrange),
            const SizedBox(width: 4),
            Text(
              'Récolte: ${_monthName(moisRecolteDebut)}–${_monthName(moisRecolteFin)}',
              style: AppTheme.poppins(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bar(double totalWidth, int startMonth, int span, Color color) {
    final left = (startMonth - 1) / 12.0;
    final width = span.clamp(0, 12) / 12.0;
    return Positioned(
      left: left * totalWidth,
      top: 1,
      child: Container(
        height: 8,
        width: totalWidth * width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0.4)],
          ),
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
