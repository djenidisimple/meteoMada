import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class CycloneLevelBadge extends StatelessWidget {
  final String niveau;

  const CycloneLevelBadge({super.key, required this.niveau});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorForNiveau(niveau);
    final label = AppTheme.labelForNiveau(niveau);
    final emoji = _emoji(niveau);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  String _emoji(String niveau) {
    switch (niveau) {
      case 'alerte_rouge':
        return '🔴';
      case 'alerte_orange':
        return '🟠';
      case 'alerte_jaune':
      case 'tempete':
        return '🟡';
      case 'depression':
        return '🔵';
      default:
        return '🔵';
    }
  }
}
