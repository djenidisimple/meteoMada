import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/favoris_provider.dart';

class DetailScreen extends StatelessWidget {
  final String villeId;
  const DetailScreen({super.key, required this.villeId});

  Color _uvColor(double uv) {
    if (uv <= 2) return AppTheme.accentGreen;
    if (uv <= 5) return AppTheme.accentYellow;
    if (uv <= 7) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  String _uvLabel(double uv) {
    if (uv <= 2) return 'Faible';
    if (uv <= 5) return 'Modéré';
    if (uv <= 7) return 'Élevé';
    return 'Extrême';
  }

  String _ventLabel(double vitesse) {
    if (vitesse < 5) return 'Calme';
    if (vitesse < 15) return 'Brise légère';
    if (vitesse < 30) return 'Brise modérée';
    if (vitesse < 50) return 'Vent fort';
    return 'Tempête';
  }

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
          title: Consumer<WeatherProvider>(
            builder: (_, wp, __) {
              final v = wp.villeActuelle;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v?.nom ?? 'Antananarivo',
                            style: AppTheme.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text('Aujourd\'hui, ${DateTime.now().day} ${_mois(DateTime.now().month)}',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            Consumer2<WeatherProvider, FavorisProvider>(
              builder: (_, wp, fp, __) {
                final v = wp.villeActuelle;
                final estFavori = v != null && fp.favoris.any((f) => f.ville.id == v.id);
                return IconButton(
                  icon: Icon(
                    estFavori ? Icons.star_rounded : Icons.star_border_rounded,
                    color: estFavori ? AppTheme.accentYellow : AppTheme.textSecondary,
                  ),
                  onPressed: () async {
                    if (v == null) return;
                    if (estFavori) {
                      final f = fp.favoris.firstWhere((f) => f.ville.id == v.id);
                      fp.supprimer(f.favori.id);
                    } else {
                      fp.ajouter(v.id);
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final p = wp.previsionActuelle;
            final v = wp.villeActuelle;
            final horaires = wp.previsionsHoraires;
            if (p == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoGrid(p, v),
                  const SizedBox(height: 16),
                  if (horaires.isNotEmpty) _hourlyPreview(context, horaires, v),
                  const SizedBox(height: 16),
                  _sunCard(context),
                  const SizedBox(height: 16),
                  _ventCard(p),
                  const SizedBox(height: 16),
                  _indicesCard(p),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoGrid(dynamic p, dynamic v) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _infoTile(Icons.thermostat, '${p.temperature.toStringAsFixed(1)}°C', 'Température', AppTheme.accentBlue),
        _infoTile(Icons.water_drop, '${p.humidite.toStringAsFixed(0)}%', 'Humidité', AppTheme.accentGreen),
        _infoTile(Icons.air, '${p.vitesseVent.toStringAsFixed(0)} km/h', 'Vent · ${p.directionVent}', AppTheme.accentOrange),
        _infoTile(Icons.wb_sunny, '${p.indiceUV.toStringAsFixed(1)}', 'UV · ${_uvLabel(p.indiceUV)}', _uvColor(p.indiceUV)),
      ],
    );
  }

  Widget _infoTile(IconData icon, String valeur, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(valeur,
                style: AppTheme.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          Text(label,
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _hourlyPreview(BuildContext context, List<dynamic> horaires, dynamic v) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Prochaines heures',
                  style: AppTheme.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              GestureDetector(
                onTap: () => context.push('/home/hourly/${v?.id ?? 'antananarivo'}'),
                child: Text('Détail →',
                    style: AppTheme.poppins(fontSize: 10, color: AppTheme.accentBlue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: horaires.length.clamp(0, 8),
              itemBuilder: (_, i) {
                final h = horaires[i];
                return Container(
                  width: 56,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('${h.dateHeure.hour}h',
                          style: AppTheme.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Icon(_conditionIcon(h.condition), size: 18, color: Colors.white),
                      const SizedBox(height: 4),
                      Text('${h.temperature.toStringAsFixed(0)}°',
                          style: AppTheme.poppins(
                              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_twilight, color: AppTheme.accentYellow, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('06:15',
                        style: AppTheme.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Lever du soleil',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.06)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('17:30',
                        style: AppTheme.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Coucher du soleil',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sunny, color: AppTheme.accentOrange, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ventCard(dynamic p) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.air, color: AppTheme.accentOrange, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.vitesseVent.toStringAsFixed(0)} km/h',
                    style: AppTheme.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${_ventLabel(p.vitesseVent)} · Direction ${p.directionVent}',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.20)),
            ),
            child: Text(p.directionVent,
                style: AppTheme.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentOrangeLight)),
          ),
        ],
      ),
    );
  }

  Widget _indicesCard(dynamic p) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, size: 20, color: _uvColor(p.indiceUV)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Indice UV : ${p.indiceUV.toStringAsFixed(1)}',
                        style: AppTheme.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(_uvLabel(p.indiceUV),
                        style: TextStyle(fontSize: 11, color: _uvColor(p.indiceUV))),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (p.indiceUV / 11).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(_uvColor(p.indiceUV)),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.nightlight_round, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lune gibbeuse décroissante',
                        style: AppTheme.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Illumination 78% · Lever 22:14',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _conditionIcon(String condition) {
    if (condition.contains('dégagé')) return Icons.wb_sunny;
    if (condition.contains('nuageux') || condition.contains('Partiellement')) return Icons.wb_cloudy;
    if (condition.contains('Brumeux')) return Icons.cloud;
    if (condition.contains('Pluie') || condition.contains('Bruine')) return Icons.water_drop;
    if (condition.contains('Averses')) return Icons.umbrella;
    if (condition.contains('Orage')) return Icons.flash_on;
    return Icons.cloud_queue;
  }

  String _mois(int m) {
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return mois[m - 1];
  }
}
