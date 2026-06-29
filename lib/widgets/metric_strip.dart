import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';

class MetricStrip extends StatelessWidget {
  final double humidite;
  final double vitesseVent;
  final double visibilite;
  final double indiceUV;

  const MetricStrip({
    super.key,
    required this.humidite,
    required this.vitesseVent,
    this.visibilite = 10,
    required this.indiceUV,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            _metric(context, Icons.water_drop, '${humidite.toStringAsFixed(0)}%', 'Humidité',
                AppTheme.accentBlue),
            _divider(),
            _metric(context, Icons.air, '${vitesseVent.toStringAsFixed(0)} km/h', 'Vent',
                AppTheme.accentGreen),
            _divider(),
            _metric(context, Icons.visibility, '${visibilite.toStringAsFixed(0)} km', 'Visibilité',
                AppTheme.accentYellow),
            _divider(),
            _metric(context, Icons.wb_sunny, indiceUV.toStringAsFixed(0), 'UV',
                AppTheme.accentOrange),
          ],
        ),
      ),
    );
  }

  Widget _metric(
      BuildContext context, IconData icon, String valeur, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(valeur,
              style: AppTheme.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.textDim,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 28,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
