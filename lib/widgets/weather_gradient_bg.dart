import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class WeatherGradientBg extends StatelessWidget {
  final Widget child;
  final bool blobs;

  const WeatherGradientBg({
    super.key,
    required this.child,
    this.blobs = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: child,
    );
  }
}

class MarineGradientBg extends StatelessWidget {
  final Widget child;

  const MarineGradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.marineGradient),
      child: child,
    );
  }
}
