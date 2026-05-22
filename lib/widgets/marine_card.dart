import 'package:flutter/material.dart';
import 'package:meteomada/models/condition_marine.dart';

class MarineCard extends StatelessWidget {
  final ConditionMarine condition;

  const MarineCard({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.waves_rounded, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Conditions marines',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            _buildLigne(context, 'Hauteur des vagues',
                '${condition.hauteurVagues.toStringAsFixed(1)} m', Icons.height),
            _buildLigne(context, 'Température eau',
                '${condition.temperatureEau.toStringAsFixed(1)}°C', Icons.thermostat),
            _buildLigne(context, 'État de la marée', condition.etatMaree,
                Icons.trending_up),
            _buildLigne(context, 'Vent marin', condition.ventMarin, Icons.air),
            _buildLigne(context, 'Houle',
                '${condition.houle.toStringAsFixed(1)} m', Icons.swap_vert),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIndicator(
                  Icons.warning_amber,
                  'Baignade',
                  condition.baignadeDangereuse ? 'Dangereuse' : 'Possible',
                  condition.baignadeDangereuse ? Colors.red : Colors.green,
                ),
                _buildIndicator(
                  Icons.directions_boat,
                  'Pêche',
                  condition.pechePossible ? 'Possible' : 'Déconseillée',
                  condition.pechePossible ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLigne(
      BuildContext context, String label, String valeur, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
      IconData icon, String label, String etat, Color couleur) {
    return Column(
      children: [
        Icon(icon, color: couleur, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          etat,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: couleur,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
