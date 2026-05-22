import 'package:flutter/material.dart';
import 'package:meteomada/models/alerte_cyclone.dart';

class AlerteBanner extends StatelessWidget {
  final AlerteCyclone alerte;
  final VoidCallback? onTap;

  const AlerteBanner({
    super.key,
    required this.alerte,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurNiveau(alerte.niveau);
    final libelle = _libelleNiveau(alerte.niveau);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: couleur.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: couleur, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: couleur, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alerte.nomCyclone} - $libelle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: couleur,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerte.consignes,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: couleur),
            ],
          ),
        ),
      ),
    );
  }

  Color _couleurNiveau(String niveau) {
    switch (niveau) {
      case 'Surveillance':
      case 'FinAlerte':
      case 'Dissipation':
        return Colors.grey;
      case 'DepressionTropicale':
      case 'AlerteJaune':
        return Colors.amber;
      case 'TempeteTropicale':
      case 'AlerteOrange':
        return Colors.orange;
      case 'CycloneTropical':
      case 'CycloneIntense':
      case 'AlerteRouge':
        return Colors.red;
      case 'PhasePostCyclone':
      case 'Bilan':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _libelleNiveau(String niveau) {
    switch (niveau) {
      case 'Surveillance':
        return 'Surveillance';
      case 'DepressionTropicale':
        return 'Dépression tropicale';
      case 'TempeteTropicale':
        return 'Tempête tropicale';
      case 'CycloneTropical':
        return 'Cyclone tropical';
      case 'CycloneIntense':
        return 'Cyclone intense';
      case 'AlerteJaune':
        return 'Alerte jaune';
      case 'AlerteOrange':
        return 'Alerte orange';
      case 'AlerteRouge':
        return 'Alerte rouge';
      case 'PhasePostCyclone':
        return 'Phase post-cyclone';
      case 'Bilan':
        return 'Bilan';
      case 'Dissipation':
        return 'Dissipation';
      case 'FinAlerte':
        return 'Fin d\'alerte';
      default:
        return niveau;
    }
  }
}
