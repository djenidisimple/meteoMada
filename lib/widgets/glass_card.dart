import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool inset;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.inset = false,
    this.onTap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
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
            decoration: decoration ??
                BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}
