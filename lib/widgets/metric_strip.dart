import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            _metric(
                context, '💧', '${humidite.toStringAsFixed(0)}%', 'Humidité'),
            _divider(),
            _metric(context, '💨', '${vitesseVent.toStringAsFixed(0)} km/h',
                'Vent'),
            _divider(),
            _metric(context, '👁️', '${visibilite.toStringAsFixed(0)} km',
                'Visibilité'),
            _divider(),
            _metric(context, '☀️', indiceUV.toStringAsFixed(0), 'UV'),
          ],
        ),
      ),
    );
  }

  Widget _metric(
      BuildContext context, String emoji, String valeur, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(valeur,
              style: GoogleFonts.syne(
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
      color: Colors.white.withOpacity(0.08),
    );
  }
}
