import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/cyclone_level_badge.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/models/alerte_cyclone.dart';

class HistoriqueAlertesScreen extends StatefulWidget {
  const HistoriqueAlertesScreen({super.key});

  @override
  State<HistoriqueAlertesScreen> createState() => _HistoriqueAlertesScreenState();
}

class _HistoriqueAlertesScreenState extends State<HistoriqueAlertesScreen> {
  String? _regionFiltre;

  final _regions = [
    'Toutes', 'Atsinanana', 'Analanjirofo', 'Diana', 'Boeny', 'Anosy',
    'Analamanga', 'Sava', 'Atsimo-Andrefana', 'Vakinankaratra', 'Menabe', 'Sofia'
  ];

  @override
  Widget build(BuildContext context) {
    return WeatherGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text('Alertes cyclones',
              style: AppTheme.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          actions: [
            Consumer<AlerteProvider>(
              builder: (_, ap, __) {
                if (ap.countActives == 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.35)),
                    ),
                    child: Text('${ap.countActives} active(s)',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentRed)),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<AlerteProvider>(
          builder: (_, ap, __) {
            final toutes = ap.toutes;
            final actives = toutes.where((a) => a.estActive).toList();
            final historique = toutes.where((a) => !a.estActive).toList()
              ..sort((a, b) => b.dateEmission.compareTo(a.dateEmission));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _regions.map((r) {
                        final isActive = (r == 'Toutes' && _regionFiltre == null) ||
                            r == _regionFiltre;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _regionFiltre = r == 'Toutes' ? null : r;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: isActive
                                  ? BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                                    )
                                  : AppTheme.glassCard,
                              child: Text(r,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isActive ? Colors.white : AppTheme.textSecondary)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (actives.isNotEmpty) ...[
                    Text('Active maintenant',
                        style: AppTheme.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 10),
                    ...actives.map((a) => _alerteHistoriqueCard(a, true)),
                    const SizedBox(height: 20),
                  ],
                  Text('Historique',
                      style: AppTheme.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 10),
                  if (historique.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text('Aucune alerte passée',
                            style: AppTheme.poppins(
                                fontSize: 13, color: AppTheme.textSecondary)),
                      ),
                    )
                  else
                    ...historique.map((a) => _alerteHistoriqueCard(a, false)),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _alerteHistoriqueCard(AlerteCyclone a, bool estActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🌀', style: TextStyle(fontSize: estActive ? 16 : 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(a.nomCyclone,
                      style: AppTheme.poppins(
                          fontSize: estActive ? 14 : 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                CycloneLevelBadge(niveau: a.niveau),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_moisAnnee(a.dateEmission)} · ${estActive ? "En cours" : "Terminé"}',
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

  String _moisAnnee(DateTime d) {
    const mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${mois[d.month - 1]} ${d.year}';
  }
}
