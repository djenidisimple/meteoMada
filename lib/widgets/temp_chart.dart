import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:meteomada/theme/app_theme.dart';

class TempChart extends StatelessWidget {
  final List<TempChartPoint> points;

  const TempChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.glassCard,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _TempChartPainter(points),
      ),
    );
  }
}

class TempChartPoint {
  final String label;
  final double temp;
  const TempChartPoint(this.label, this.temp);
}

class _TempChartPainter extends CustomPainter {
  final List<TempChartPoint> points;

  _TempChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final h = size.height;
    final w = size.width;
    final minTemp = points.map((p) => p.temp).reduce(math.min);
    final maxTemp = points.map((p) => p.temp).reduce(math.max);
    final range = (maxTemp - minTemp).clamp(1, 100);
    final stepX = w / (points.length - 1);

    final path = Path();
    final pointsOffset = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = h - ((points[i].temp - minTemp) / range) * (h - 16) - 8;
      pointsOffset.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill below line
    final fillPath = Path.from(path);
    fillPath.lineTo(pointsOffset.last.dx, h);
    fillPath.lineTo(pointsOffset.first.dx, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.accentBlue, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppTheme.accentBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Find max point
    double maxVal = points.map((p) => p.temp).reduce(math.max);
    int maxIdx = points.indexWhere((p) => p.temp == maxVal);

    for (int i = 0; i < pointsOffset.length; i++) {
      if (i == maxIdx) {
        canvas.drawCircle(pointsOffset[i], 4, Paint()..color = AppTheme.accentBlue);
        canvas.drawCircle(pointsOffset[i], 6, Paint()
          ..color = AppTheme.accentBlue.withOpacity(0.3));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TempChartPainter old) => false;
}
