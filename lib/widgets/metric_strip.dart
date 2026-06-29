import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class MetricStrip extends StatelessWidget {
  final double humidite;
  final double vitesseVent;
  final double probabilitePluie;
  final double indiceUV;

  const MetricStrip({
    super.key,
    required this.humidite,
    required this.vitesseVent,
    this.probabilitePluie = 0,
    required this.indiceUV,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric(
            Icons.air_outlined,
            '${vitesseVent.toStringAsFixed(0)}km/hr',
            'Vent',
          ),
          _metric(
            CupertinoIcons.drop,
            '${humidite.toStringAsFixed(0).padLeft(2, '0')}%',
            'Humidité',
          ),
          _metric(
            CupertinoIcons.sun_max,
            '${indiceUV.toStringAsFixed(0)}hr',
            'Ensoleil.',
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String valeur, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.55)),
        const SizedBox(height: 6),
        Text(
          valeur,
          style: AppTheme.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
