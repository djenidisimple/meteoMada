import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/cyclone_level_badge.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/models/alerte_cyclone.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentRed.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Consumer<AlerteProvider>(
                builder: (_, ap, __) {
                  final actives = ap.actives;
                  final historique = ap.historique;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Alertes cyclones',
                                style: AppTheme.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/plus/historique'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: AppTheme.glassCard,
                                child: Text('Historique',
                                    style: AppTheme.poppins(
                                        fontSize: 11,
                                        color: AppTheme.accentBlue)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (ap.chargement)
                          const Center(child: CircularProgressIndicator())
                        else if (actives.isEmpty && historique.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Text('✅', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 16),
                                  Text('Aucune alerte active',
                                      style: AppTheme.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text('La saison cyclonique va de novembre à avril',
                                      style: AppTheme.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          if (actives.isNotEmpty)
                            ...actives.map((a) => _mainAlertCard(a)),
                          if (historique.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('Historique',
                                style: AppTheme.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            ...historique.map((a) => _historiqueCard(a)),
                          ],
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainAlertCard(AlerteCyclone a) {
    final color = a.niveauColor;
    final decoration = _cardForNiveau(a.niveau);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: decoration,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: 0.20), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text('🌀', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ALERTE CYCLONIQUE',
                        style: AppTheme.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1)),
                    CycloneLevelBadge(niveau: a.niveau),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.nomCyclone,
                    style: AppTheme.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(_description,
                    style: AppTheme.poppins(
                        fontSize: 12, height: 1.7, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 3,
                  children: [
                    _alertMetric('💨', 'Vent max', '120 km/h'),
                    _alertMetric('🔽', 'Pression', '980 hPa'),
                    _alertMetric('📍', 'Zones', '${a.regions.length} régions'),
                    _alertMetric('⚠️', 'Impact', 'Élevé'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textDim),
                    const SizedBox(width: 4),
                    Text(
                      '${a.dateEmission.day}/${a.dateEmission.month}/${a.dateEmission.year}',
                      style: TextStyle(fontSize: 10, color: AppTheme.textDim),
                    ),
                    if (a.dateFinPrevue != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 10, color: AppTheme.textDim),
                      const SizedBox(width: 4),
                      Text(
                        '${a.dateFinPrevue!.day}/${a.dateFinPrevue!.month}/${a.dateFinPrevue!.year}',
                        style: TextStyle(fontSize: 10, color: AppTheme.textDim),
                      ),
                    ],
                  ],
                ),
                if (a.regions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: a.regions.map((r) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: AppTheme.glassCard,
                        child: Text(r,
                            style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ],
                if (a.consignes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consignes de sécurité',
                            style: AppTheme.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        ..._parseConsignes(a.consignes).map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.emoji, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(c.text,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historiqueCard(AlerteCyclone a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🌀', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(a.nomCyclone,
                      style: AppTheme.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                CycloneLevelBadge(niveau: a.niveau),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${a.dateEmission.day}/${a.dateEmission.month}/${a.dateEmission.year} · Terminé',
              style: TextStyle(fontSize: 10, color: AppTheme.textDim),
            ),
            if (a.regions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 3,
                children: a.regions.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r,
                        style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _alertMetric(String emoji, String label, String valeur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valeur,
                  style: AppTheme.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text(label,
                  style: TextStyle(fontSize: 8, color: AppTheme.textDim)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardForNiveau(String niveau) {
    switch (niveau) {
      case 'alerte_rouge':
        return AppTheme.dangerCard;
      case 'alerte_orange':
        return AppTheme.warningCard;
      case 'alerte_jaune':
      case 'tempete':
        return AppTheme.watchCard;
      default:
        return AppTheme.activeCard;
    }
  }

  List<_Consigne> _parseConsignes(String consignes) {
    if (consignes.isEmpty) return [];
    final parts = consignes.split(RegExp(r'[•\n]')).where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return [_Consigne('ℹ️', consignes)];
    return parts.map((p) => _Consigne('ℹ️', p.trim())).toList();
  }

  String get _description =>
      'Situation cyclonique nécessitant une vigilance accrue dans les zones concernées.';
}

class _Consigne {
  final String emoji;
  final String text;
  _Consigne(this.emoji, this.text);
}
