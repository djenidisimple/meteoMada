import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class WaveBarChart extends StatelessWidget {
  final double hauteurVagues;
  final int barCount;

  const WaveBarChart({
    super.key,
    required this.hauteurVagues,
    this.barCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(barCount, (i) {
        final height = _waveHeight(i, barCount, hauteurVagues);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Column(
              children: [
                Container(
                  height: 40 * height,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                    color: AppTheme.accentGreen
                        .withValues(alpha: 0.30 + height * 0.30),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  double _waveHeight(int index, int count, double base) {
    final phase = (index / count) * 3.14 * 2;
    final normalized = (1 + sin(phase)) / 2;
    return 0.3 + normalized * 0.7;
  }
}
