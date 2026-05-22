import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/temp_chart.dart';
import 'package:meteomada/widgets/custom_toggle.dart';
import 'package:meteomada/providers/weather_provider.dart';

class HourlyScreen extends StatefulWidget {
  final String villeId;
  const HourlyScreen({super.key, required this.villeId});

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  int _selectedDay = 0;

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
          title: Text('Prévisions horaires',
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        body: Consumer<WeatherProvider>(
          builder: (_, wp, __) {
            final p = wp.previsionActuelle;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomToggle(
                    options: ['Aujourd\'hui', 'Demain', 'J+2'],
                    selectedIndex: _selectedDay,
                    onChanged: (i) => setState(() => _selectedDay = i),
                  ),
                  const SizedBox(height: 20),
                  Text('Température',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  TempChart(
                    points: [
                      TempChartPoint('6h', p?.temperature ?? 20 - 3),
                      TempChartPoint('9h', p?.temperature ?? 22),
                      TempChartPoint('12h', p?.temperature ?? 26),
                      TempChartPoint('14h', p?.temperature ?? 31),
                      TempChartPoint('17h', p?.temperature ?? 28),
                      TempChartPoint('20h', p?.temperature ?? 24),
                      TempChartPoint('0h', p?.temperature ?? 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(8, (i) {
                    final now = DateTime.now();
                    final h = (now.hour + i * 3) % 24;
                    final heure = '${h.toString().padLeft(2, '0')}h';
                    final isActive = i == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: isActive
                          ? AppTheme.activeCard
                          : AppTheme.glassCard,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(heure,
                                style: GoogleFonts.syne(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Text(i % 3 == 0 ? '⛅' : i % 3 == 1 ? '☀️' : '☁️',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    i == 0
                                        ? 'Partiellement nuageux'
                                        : i % 2 == 0
                                            ? 'Ensoleillé'
                                            : 'Nuageux',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: Colors.white)),
                                Text('💧 ${50 + i * 5}% · 💨 ${10 + i} km/h',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Text('${(p?.temperature ?? 27) + (i * 1.5 - 2)}°',
                              style: GoogleFonts.syne(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
