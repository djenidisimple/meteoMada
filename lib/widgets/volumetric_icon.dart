import 'dart:math' as math;
import 'package:flutter/material.dart';

class VolumetricCloud extends StatelessWidget {
  final double size;
  final Color baseColor;
  final Color highlightColor;

  const VolumetricCloud({
    super.key,
    this.size = 120,
    this.baseColor = const Color(0xFFD0C4F0),
    this.highlightColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: _CloudPainter(baseColor: baseColor, highlightColor: highlightColor),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final Color baseColor;
  final Color highlightColor;

  _CloudPainter({required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()..style = PaintingStyle.fill;

    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [highlightColor, baseColor],
    );

    final path = Path();

    final centerX = w / 2;
    final centerY = h * 0.55;

    path.addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: w * 0.28));
    path.addOval(Rect.fromCircle(center: Offset(centerX - w * 0.22, centerY + h * 0.05), radius: w * 0.22));
    path.addOval(Rect.fromCircle(center: Offset(centerX + w * 0.25, centerY + h * 0.08), radius: w * 0.2));
    path.addOval(Rect.fromCircle(center: Offset(centerX - w * 0.12, centerY - h * 0.12), radius: w * 0.18));
    path.addOval(Rect.fromCircle(center: Offset(centerX + w * 0.12, centerY - h * 0.08), radius: w * 0.16));

    final bottomRect = Rect.fromLTRB(centerX - w * 0.32, centerY + h * 0.15, centerX + w * 0.35, centerY + h * 0.4);
    path.addRRect(RRect.fromRectAndRadius(bottomRect, const Radius.circular(20)));

    canvas.save();
    canvas.clipPath(Path.combine(
      PathOperation.union,
      path,
      Path(),
    ));
    final rect = Offset.zero & size;
    paint.shader = gradient.createShader(rect);
    canvas.drawOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: w * 0.5), paint);
    canvas.restore();

    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = baseColor.withValues(alpha: 0.3);
    canvas.drawPath(
      path.shift(const Offset(0, 6)),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor || oldDelegate.highlightColor != highlightColor;
}

class VolumetricSun extends StatelessWidget {
  final double size;
  final Color baseColor;
  final Color highlightColor;

  const VolumetricSun({
    super.key,
    this.size = 120,
    this.baseColor = const Color(0xFFFDB813),
    this.highlightColor = const Color(0xFFFFF3CD),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunPainter(baseColor: baseColor, highlightColor: highlightColor),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  final Color baseColor;
  final Color highlightColor;

  _SunPainter({required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.25;

    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: 0.5);

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final inner = Offset(
        center.dx + math.cos(angle) * (radius + 8),
        center.dy + math.sin(angle) * (radius + 8),
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius + 28),
        center.dy + math.sin(angle) * (radius + 28),
      );
      canvas.drawCircle(inner, 4, rayPaint);
      canvas.drawCircle(outer, 3, rayPaint);
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = baseColor.withValues(alpha: 0.3)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(inner, outer, line);
    }

    final sunGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: [highlightColor, baseColor, baseColor.withValues(alpha: 0.8)],
    );
    final sunPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = sunGradient.createShader(Rect.fromCircle(center: center, radius: radius + 4));

    canvas.drawCircle(center, radius + 4, sunPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..color = baseColor.withValues(alpha: 0.35);
    canvas.drawCircle(center, radius + 12, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SunPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor || oldDelegate.highlightColor != highlightColor;
}

class VolumetricMoon extends StatelessWidget {
  final double size;

  const VolumetricMoon({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoonPainter(),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.22;

    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: [
        const Color(0xFFF5F0FF),
        const Color(0xFFC8B8E8),
        const Color(0xFFA898D0),
      ],
    );
    final moonPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, moonPaint);

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx + radius * 0.4, center.dy - radius * 0.2), radius: radius * 0.85));
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF8B7BB0).withValues(alpha: 0.35);
    canvas.drawPath(shadowPath, shadowPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = const Color(0xFFC8B8E8).withValues(alpha: 0.3);
    canvas.drawCircle(center, radius + 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) => false;
}
