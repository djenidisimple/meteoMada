import 'package:flutter/material.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color surfaceColor;
  final double blur;
  final double distance;
  final bool inset;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 20,
    this.surfaceColor = Colors.white,
    this.blur = 12,
    this.distance = 6,
    this.inset = false,
    this.onTap,
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
            duration: const Duration(milliseconds: 200),
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: inset
                  ? [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(distance, distance),
                        blurRadius: blur,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-distance, -distance),
                        blurRadius: blur,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(distance, distance),
                        blurRadius: blur,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-distance, -distance),
                        blurRadius: blur,
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color surfaceColor;
  final double blur;
  final double distance;
  final bool inset;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.surfaceColor = Colors.white,
    this.blur = 12,
    this.distance = 6,
    this.inset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: inset
            ? [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(distance, distance),
                  blurRadius: blur,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-distance, -distance),
                  blurRadius: blur,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(distance, distance),
                  blurRadius: blur,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-distance, -distance),
                  blurRadius: blur,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
