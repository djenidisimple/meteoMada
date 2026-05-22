import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/culture_timeline.dart';
import 'package:meteomada/providers/calendrier_provider.dart';
import 'package:meteomada/models/calendrier_cultural.dart';
import 'package:meteomada/widgets/loading_view.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  @override
  void initState() {
    super.initState();
    final cp = context.read<CalendrierProvider>();
    cp.initialiser();
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
          title: Text('Calendrier Cultural',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: Consumer<CalendrierProvider>(
          builder: (_, cp, __) {
            if (cp.chargement) {
              return const LoadingView(message: "Chargement du calendrier...");
            }
            if (cp.regions.isEmpty && cp.donnees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌾', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('Aucune donnée disponible',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendrier Cultural',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Conseils météo par culture · Madagascar',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  if (cp.regions.isNotEmpty)
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: cp.regions.map((r) {
                          final isActive = r == cp.regionSelectionnee;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => cp.chargerCalendrier(r),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: isActive
                                    ? AppTheme.activeCard
                                    : AppTheme.glassCard,
                                child: Text(r,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isActive
                                            ? AppTheme.accentBlue
                                            : AppTheme.textSecondary)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (cp.filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text('Sélectionnez une région',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ),
                    )
                  else
                    ...cp.filtered.map((c) => _cultureCard(c)),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cultureCard(CalendrierCultural c) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final isActive = c.moisSemisDebut <= currentMonth && currentMonth <= c.moisSemisFin;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text(c.typeCultureEmoji,
                          style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.typeCultureLabel,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: isActive
                      ? AppTheme.marineCard
                      : AppTheme.watchCard,
                  child: Text(isActive ? 'Saison active' : 'À venir',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppTheme.accentGreenLight
                              : AppTheme.accentYellow)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CultureTimeline(
              moisSemisDebut: c.moisSemisDebut,
              moisSemisFin: c.moisSemisFin,
              moisRecolteDebut: c.moisRecolteDebut,
              moisRecolteFin: c.moisRecolteFin,
            ),
            if (c.conseilsMeteo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: AppTheme.accentGreen.withOpacity(0.18), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c.conseilsMeteo,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              height: 1.5,
                              color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
