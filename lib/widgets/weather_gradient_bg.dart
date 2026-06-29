import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class WeatherGradientBg extends StatelessWidget {
  final Widget child;
  final List<Widget>? blobs;

  const WeatherGradientBg({super.key, required this.child, this.blobs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Stack(
        children: [
          if (blobs != null) ...blobs!,
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class MarineGradientBg extends StatelessWidget {
  final Widget child;
  final List<Widget>? blobs;

  const MarineGradientBg({super.key, required this.child, this.blobs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.marineGradient),
      child: Stack(
        children: [
          if (blobs != null) ...blobs!,
          SafeArea(child: child),
        ],
      ),
    );
  }
}

Widget buildBlob(double size, Color color, double top, double left,
    {double opacity = 0.07}) {
  return Positioned(
    top: top,
    left: left,
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
