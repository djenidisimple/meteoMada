import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ..._blobs(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.white.withOpacity(0.09),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.18), width: 0.5),
                    ),
                    child: const Center(
                        child: Text('🌤', style: TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 22),
                  Text('Toerana',
                      style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: Colors.white)),
                  Text('MÉTÉO · MADAGASCAR',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          letterSpacing: 0.18,
                          color: AppTheme.textDim)),
                  const SizedBox(height: 20),
                  Container(
                    width: 60,
                    height: 1,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 190,
                    child: Text(
                      "Prévisions précises\npour toute l'île Rouge",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.7,
                          color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [1.0, 0.4, 0.2].map((o) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentBlue.withOpacity(o),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 22,
              left: 0,
              right: 0,
              child: Text(
                'v1.0 · DGM Madagascar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppTheme.textDim),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _blobs() {
    return [
      _blob(280, AppTheme.accentBlue, top: -90, left: -60),
      _blob(220, AppTheme.accentGreen, bottom: 40, right: -70),
      _blob(160, AppTheme.accentOrange, bottom: 120, left: -40),
    ];
  }

  Widget _blob(double size, Color color,
      {double? top, double? left, double? bottom, double? right, double opacity = 0.07}) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}
