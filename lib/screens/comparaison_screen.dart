import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/region_compare_bar.dart';

class ComparaisonScreen extends StatefulWidget {
  const ComparaisonScreen({super.key});

  @override
  State<ComparaisonScreen> createState() => _ComparaisonScreenState();
}

class _ComparaisonScreenState extends State<ComparaisonScreen> {
  int _selectedMetric = 0;

  final _metrics = ['🌡 Température', '💧 Humidité', '🌧 Pluie'];

  final _villes = [
    ('Antananarivo', 'Analamanga', 'Partiellement nuageux', 27, 55, 30),
    ('Toamasina', 'Atsinanana', 'Averses', 31, 88, 75),
    ('Mahajanga', 'Boeny', 'Ensoleillé', 36, 62, 15),
    ('Toliara', 'Atsimo-Andrefana', 'Dégagé', 34, 45, 10),
    ('Antsiranana', 'Diana', 'Nuageux', 33, 72, 40),
    ('Fianarantsoa', 'Haute Matsiatra', 'Pluie légère', 22, 65, 55),
    ('Fort Dauphin', 'Anosy', 'Venteux', 24, 78, 60),
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
          title: Text('Comparaison',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Climats des régions',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Aujourd\'hui',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(_metrics.length, (i) {
                  final isActive = i == _selectedMetric;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMetric = i),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: i > 0 ? 4 : 0, right: i < _metrics.length - 1 ? 4 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: isActive
                            ? AppTheme.activeCard
                            : AppTheme.glassCard,
                        child: Text(_metrics[i],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight:
                                    isActive ? FontWeight.w600 : FontWeight.w400,
                                color: isActive
                                    ? AppTheme.accentBlue
                                    : AppTheme.textSecondary)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              ..._buildSortedVilles(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSortedVilles() {
    final metrique = _metrics[_selectedMetric];
    final key = metrique.contains('Temp') ? 'temp' : metrique.contains('Hum') ? 'hum' : 'pluie';

    final sorted = List<_VilleData>.from(_villes.map((v) => _VilleData(
      nom: v.$1,
      region: v.$2,
      condition: v.$3,
      temp: v.$4,
      hum: v.$5,
      pluie: v.$6,
    )));

    double maxVal;
    switch (key) {
      case 'temp':
        sorted.sort((a, b) => b.temp.compareTo(a.temp));
        maxVal = sorted.first.temp.toDouble();
        break;
      case 'hum':
        sorted.sort((a, b) => b.hum.compareTo(a.hum));
        maxVal = sorted.first.hum.toDouble();
        break;
      default:
        sorted.sort((a, b) => b.pluie.compareTo(a.pluie));
        maxVal = sorted.first.pluie.toDouble();
    }

    return sorted.map((v) {
      double valeur;
      switch (key) {
        case 'temp': valeur = v.temp.toDouble(); break;
        case 'hum': valeur = v.hum.toDouble(); break;
        default: valeur = v.pluie.toDouble();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RegionCompareBar(
          nom: v.nom,
          region: v.region,
          condition: v.condition,
          valeur: valeur,
          maxValeur: maxVal,
          metrique: key,
        ),
      );
    }).toList();
  }
}

class _VilleData {
  final String nom, region, condition;
  final int temp, hum, pluie;
  _VilleData({
    required this.nom,
    required this.region,
    required this.condition,
    required this.temp,
    required this.hum,
    required this.pluie,
  });
}
