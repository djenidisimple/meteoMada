import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/repositories/ville_repository.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';
import 'package:meteomada/repositories/prevision_repository.dart';

class ComparaisonScreen extends StatefulWidget {
  const ComparaisonScreen({super.key});

  @override
  State<ComparaisonScreen> createState() => _ComparaisonScreenState();
}

class _ComparaisonScreenState extends State<ComparaisonScreen> {
  int _selectedMetric = 0;
  List<_VilleData> _donnees = [];
  bool _chargement = true;

  final _metrics = ['🌡 Température', '💧 Humidité', '🌧 Pluie'];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final villeRepo = VilleRepository();
    final prevRepo = PrevisionRepository();
    final villes = await villeRepo.getAllVilles();
    final liste = <_VilleData>[];
    for (final v in villes.take(7)) {
      final p = await prevRepo.getDernierePrevision(v.id);
      liste.add(_VilleData(v: v, p: p));
    }
    if (mounted) setState(() { _donnees = liste; _chargement = false; });
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
          title: Text('Comparaison',
              style: AppTheme.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: _chargement
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Climats des régions',
                        style: AppTheme.poppins(
                            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Aujourd\'hui',
                        style: AppTheme.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    _toggleMetrics(),
                    const SizedBox(height: 16),
                    ..._donnees.map((d) => _barreRegion(d)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _toggleMetrics() {
    return Row(
      children: List.generate(_metrics.length, (i) {
        final isActive = i == _selectedMetric;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMetric = i),
            child: Container(
              margin: EdgeInsets.only(right: i < _metrics.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.30), width: 0.8),
                    )
                  : BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Text(_metrics[i],
                  textAlign: TextAlign.center,
                  style: AppTheme.poppins(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
            ),
          ),
        );
      }),
    );
  }

  Widget _barreRegion(_VilleData d) {
    final valeur = _valeur(d);
    final maxVal = _donnees.fold<double>(0, (m, x) => _valeur(x) > m ? _valeur(x) : m);
    final ratio = maxVal > 0 ? valeur / maxVal : 0.0;
    final color = _selectedMetric == 0 ? AppTheme.accentOrange
        : _selectedMetric == 1 ? AppTheme.accentBlue
        : AppTheme.accentGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.v.nom,
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('${valeur.toStringAsFixed(1)}${_selectedMetric == 0 ? '°C' : _selectedMetric == 1 ? '%' : '%'}',
                  style: AppTheme.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  double _valeur(_VilleData d) {
    if (d.p == null) return 0;
    switch (_selectedMetric) {
      case 0: return d.p!.temperature;
      case 1: return d.p!.humidite;
      case 2: return d.p!.probabilitePluie;
      default: return 0;
    }
  }
}

class _VilleData {
  final Ville v;
  final Prevision? p;
  _VilleData({required this.v, this.p});
}
