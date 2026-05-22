import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/services/location_service.dart';
import 'package:meteomada/providers/weather_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              height: 230,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.accentBlue.withOpacity(0.15)),
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.accentBlue.withOpacity(0.20)),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentBlue.withOpacity(0.07),
                        border: Border.all(
                            color: AppTheme.accentBlue.withOpacity(0.28)),
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppTheme.accentBlue.withOpacity(0.14),
                        border: Border.all(
                            color: AppTheme.accentBlue.withOpacity(0.30)),
                      ),
                      child: const Center(
                          child: Text('📍', style: TextStyle(fontSize: 30))),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Activez votre\nlocalisation',
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Pour vous offrir les prévisions les plus précises, nous avons besoin de connaître votre position.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.7,
                    color: AppTheme.textSecondary),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final loc = LocationService();
                      final granted = await loc.demanderPermission();
                      if (granted) {
                        final pos = await loc.obtenirPosition();
                        if (pos != null && context.mounted) {
                          context.read<WeatherProvider>().chargerPourPosition(
                                pos['lat']!, pos['lon']!);
                        }
                      }
                      if (context.mounted) context.go('/home');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppTheme.accentBlue, AppTheme.accentBlueLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '📡 Autoriser la localisation',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.14), width: 0.5),
                    ),
                    child: InkWell(
                      onTap: () => context.go('/home'),
                      child: Text(
                        'Saisir une ville manuellement',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
