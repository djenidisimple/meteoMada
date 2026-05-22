import 'package:flutter/material.dart';
import 'package:meteomada/models/prevision.dart';

class MeteoCard extends StatelessWidget {
  final Prevision prevision;
  final String villeNom;
  final VoidCallback? onRefresh;

  const MeteoCard({
    super.key,
    required this.prevision,
    required this.villeNom,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    villeNom,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconeMeteo(prevision.icone),
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                Text(
                  '${prevision.temperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prevision.condition,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo(
                    Icons.water_drop, '${prevision.humidite.toStringAsFixed(0)}%'),
                _buildInfo(
                    Icons.air, '${prevision.vitesseVent.toStringAsFixed(1)} m/s'),
                _buildInfo(
                    Icons.wb_sunny, 'UV ${prevision.indiceUV.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  IconData _iconeMeteo(String icone) {
    switch (icone) {
      case '01d':
      case '01n':
        return Icons.sunny;
      case '02d':
      case '02n':
        return Icons.cloud;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud_queue;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.water_drop;
      case '11d':
      case '11n':
        return Icons.thunderstorm;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.cloud;
    }
  }
}
