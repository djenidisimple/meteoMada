import 'package:flutter/material.dart';
import 'package:meteomada/models/prevision.dart';

class PrevisionRow extends StatelessWidget {
  final Prevision prevision;
  final bool isDerniere;

  const PrevisionRow({
    super.key,
    required this.prevision,
    this.isDerniere = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = _formaterDate(prevision.dateHeure);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                dateStr,
                style: TextStyle(
                  fontWeight: isDerniere ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              _iconeMeteo(prevision.icone),
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                prevision.condition,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${prevision.temperature.toStringAsFixed(1)}°',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Icon(Icons.water_drop_rounded, size: 16, color: Colors.blue[300]),
            Text(
              '${prevision.humidite.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formaterDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Demain';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
