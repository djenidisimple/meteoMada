import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? tintColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 24,
    this.tintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = tintColor;
    final decoration = tc != null
        ? AppTheme.glassTinted(radius: borderRadius, tint: tc)
        : AppTheme.glass(radius: borderRadius);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: padding ?? const EdgeInsets.all(16),
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
