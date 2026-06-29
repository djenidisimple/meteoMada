import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/favori.dart';

class CityFavoriCard extends StatelessWidget {
  final Ville ville;
  final Favori? favori;
  final double temperature;
  final String condition;
  final bool isDefault;
  final Widget? trailing;

  const CityFavoriCard({
    super.key,
    required this.ville,
    this.favori,
    required this.temperature,
    required this.condition,
    this.isDefault = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _villeGradient(ville.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradient[1].withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(ville.nom,
                              style: AppTheme.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(width: 6),
                          if (isDefault)
                            _badge('📍 Ma ville', AppTheme.accentBlue)
                          else if (ville.estCotiere)
                            _badge('🏝 Côtière', AppTheme.accentGreen),
                        ],
                      ),
                      if (favori?.surnom != null)
                        Text('🏷 ${favori!.surnom}',
                            style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.accentBlueLight)),
                      const SizedBox(height: 2),
                      Text(condition,
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(temperature.toStringAsFixed(0),
                            style: AppTheme.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('°',
                            style: AppTheme.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        if (trailing != null) ...[
                          const SizedBox(width: 4),
                          trailing!,
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('Min 22° · Max 32°',
                      style: TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary)),
                  const Spacer(),
                  if (ville.estCotiere)
                    Text('🌊 Marine disponible',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary))
                  else
                    Text(
                        'Ajouté le ${favori?.dateAjout.day ?? ''}/${favori?.dateAjout.month ?? ''}',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.5),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }

  List<Color> _villeGradient(String id) {
    switch (id) {
      case 'TNR':
        return [const Color(0xFF0D3B7A), const Color(0xFF1162A0)];
      case 'TOA':
        return [const Color(0xFF0A4A35), const Color(0xFF137A57)];
      case 'MJV':
        return [const Color(0xFF5B1A00), const Color(0xFF943420)];
      case 'TMM':
        return [const Color(0xFF1A2E4B), const Color(0xFF2A4A7A)];
      default:
        return [AppTheme.backgroundCard, AppTheme.accentBlue.withValues(alpha: 0.4)];
    }
  }
}
