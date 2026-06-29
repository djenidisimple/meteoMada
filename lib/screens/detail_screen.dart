import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/favoris_provider.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/utils/weather_helper.dart';

class DetailScreen extends StatelessWidget {
  final String villeId;
  const DetailScreen({super.key, required this.villeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 38,
              height: 38,
              decoration: AppTheme.glass(radius: 12),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          title: Consumer<WeatherProvider>(
            builder: (_, wp, __) {
              final v = wp.villeActuelle;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v?.nom ?? 'Antananarivo',
                    style: AppTheme.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Text(
                    "Aujourd'hui, ${DateTime.now().day} ${WeatherHelper.moisComplet(DateTime.now().month)}",
                    style: AppTheme.poppins(
                        fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              );
            },
          ),
          actions: [
            Consumer2<WeatherProvider, FavorisProvider>(
              builder: (_, wp, fp, __) {
                final v = wp.villeActuelle;
                final estFavori =
                    v != null && fp.favoris.any((f) => f.ville.id == v.id);
                return IconButton(
                  icon: Container(
                    width: 38,
                    height: 38,
                    decoration: AppTheme.glass(
                      radius: 12,
                      bgColor: estFavori
                          ? AppTheme.accentYellow.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Icon(
                      estFavori
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: estFavori
                          ? AppTheme.accentYellow
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  onPressed: () async {
                    if (v == null) return;
                    if (estFavori) {
                      final f =
                          fp.favoris.firstWhere((f) => f.ville.id == v.id);
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
                  _mainInfoCard(p, v),
                  const SizedBox(height: 16),
                  if (horaires.isNotEmpty)
                    _hourlyPreview(context, horaires, v),
                  const SizedBox(height: 16),
                  _sunCard(p),
                  const SizedBox(height: 16),
                  _detailsGrid(p),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _mainInfoCard(Prevision p, Ville? v) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: WeatherHelper.conditionColor(p.condition)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  WeatherHelper.conditionIcon(p.condition),
                  size: 32,
                  color: WeatherHelper.conditionColor(p.condition),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.temperature.toStringAsFixed(0),
                          style: AppTheme.displayMedium,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '°C',
                            style: AppTheme.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: WeatherHelper.conditionColor(p.condition),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    p.condition,
                    style: AppTheme.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: [
              _miniMetric(
                  Icons.thermostat_outlined,
                  '${p.temperature.toStringAsFixed(1)}°C',
                  'Température',
                  AppTheme.accentBlue),
              _miniMetric(
                  Icons.water_drop_outlined,
                  '${p.humidite.toStringAsFixed(0)}%',
                  'Humidité',
                  AppTheme.accentGreen),
              _miniMetric(
                  Icons.air_outlined,
                  '${p.vitesseVent.toStringAsFixed(0)} km/h',
                  'Vent · ${p.directionVent}',
                  AppTheme.accentOrange),
              _miniMetric(
                Icons.wb_sunny_outlined,
                p.indiceUV.toStringAsFixed(1),
                'UV · ${WeatherHelper.uvLabel(p.indiceUV)}',
                WeatherHelper.uvColor(p.indiceUV),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(IconData icon, String valeur, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              valeur,
              style: AppTheme.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppTheme.poppins(fontSize: 8, color: AppTheme.textDim),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _hourlyPreview(
      BuildContext context, List<Prevision> horaires, Ville? v) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prochaines heures',
                style: AppTheme.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: () =>
                    context.push('/home/hourly/${v?.id ?? 'antananarivo'}'),
                child: Text(
                  'Détail →',
                  style: AppTheme.poppins(
                      fontSize: 11, color: AppTheme.accentBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 86,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: horaires.length.clamp(0, 8),
              itemBuilder: (_, i) {
                final h = horaires[i];
                return Container(
                  width: 54,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${h.dateHeure.hour}h',
                        style: AppTheme.poppins(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        WeatherHelper.conditionIcon(h.condition),
                        size: 18,
                        color: WeatherHelper.conditionColor(h.condition),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${h.temperature.toStringAsFixed(0)}°',
                        style: AppTheme.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _sunCard(Prevision p) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.wb_twilight_rounded,
                      color: AppTheme.accentYellow, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.leverSoleil.isNotEmpty ? p.leverSoleil : '06:15',
                      style: AppTheme.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Lever du soleil',
                      style: AppTheme.poppins(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
              width: 1,
              height: 36,
              color: Colors.white.withValues(alpha: 0.06)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p.coucherSoleil.isNotEmpty ? p.coucherSoleil : '17:30',
                      style: AppTheme.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Coucher du soleil',
                      style: AppTheme.poppins(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.sunny,
                      color: AppTheme.accentOrange, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsGrid(Prevision p) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined,
                  size: 20, color: WeatherHelper.uvColor(p.indiceUV)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indice UV : ${p.indiceUV.toStringAsFixed(1)}',
                      style: AppTheme.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      WeatherHelper.uvLabel(p.indiceUV),
                      style: AppTheme.poppins(
                        fontSize: 11,
                        color: WeatherHelper.uvColor(p.indiceUV),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (p.indiceUV / 11).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(
                        WeatherHelper.uvColor(p.indiceUV)),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.air_outlined,
                  size: 20, color: AppTheme.accentOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.vitesseVent.toStringAsFixed(0)} km/h',
                      style: AppTheme.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${WeatherHelper.ventLabel(p.vitesseVent)} · ${p.directionVent}',
                      style: AppTheme.poppins(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.2)),
                ),
                child: Text(
                  p.directionVent,
                  style: AppTheme.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentOrangeLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
