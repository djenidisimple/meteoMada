import 'package:flutter/material.dart';
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
    _initialiser();
  }

  Future<void> _initialiser() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go('/home');
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
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                    ),
                    child: const Center(
                        child: Text('🌤', style: TextStyle(fontSize: 48))),
                  ),
                  const SizedBox(height: 24),
                  Text('Toerana',
                      style: AppTheme.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: Colors.white)),
                  Text('MÉTÉO · MADAGASCAR',
                      style: AppTheme.poppins(
                          fontSize: 11,
                          letterSpacing: 0.18,
                          color: AppTheme.textDim)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Découvrez la météo de toutes les localités',
                      style: AppTheme.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
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
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
