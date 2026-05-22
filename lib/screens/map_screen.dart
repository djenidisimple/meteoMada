import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDeep,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _MadagascarMapPainter(),
              ),
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _layerChip('Pluie', true),
                    const SizedBox(width: 6),
                    _layerChip('Temp.', false),
                    const SizedBox(width: 6),
                    _layerChip('Vent', false),
                  ],
                ),
              ),
              Positioned(
                bottom: 56,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: _blurFilter(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Antananarivo',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                Text('Partiellement nuageux · 27°C',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/home/detail/antananarivo'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppTheme.accentBlue.withOpacity(0.35), width: 0.5),
                              ),
                              child: Text('Détails',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accentBlue)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageFilter _blurFilter() {
    return ImageFilter.blur(sigmaX: 8, sigmaY: 8);
  }

  Widget _layerChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: isActive
          ? BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.40), width: 0.8),
            )
          : AppTheme.glassCard,
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
    );
  }
}

class _MadagascarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.08)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 24) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final scale = size.height / 520;
    final ox = (size.width - 220 * scale) / 2;
    final oy = size.height * 0.08;

    final islandPath = Path()
      ..moveTo(ox + 138 * scale, oy + 80 * scale)
      ..cubicTo(ox + 160 * scale, oy + 82 * scale, ox + 186 * scale, oy + 102 * scale,
          ox + 196 * scale, oy + 130 * scale)
      ..cubicTo(ox + 210 * scale, oy + 165 * scale, ox + 212 * scale, oy + 210 * scale,
          ox + 208 * scale, oy + 255 * scale)
      ..cubicTo(ox + 204 * scale, oy + 295 * scale, ox + 196 * scale, oy + 330 * scale,
          ox + 184 * scale, oy + 365 * scale)
      ..cubicTo(ox + 172 * scale, oy + 398 * scale, ox + 156 * scale, oy + 424 * scale,
          ox + 140 * scale, oy + 438 * scale)
      ..cubicTo(ox + 124 * scale, oy + 450 * scale, ox + 106 * scale, oy + 448 * scale,
          ox + 92 * scale, oy + 438 * scale)
      ..cubicTo(ox + 76 * scale, oy + 426 * scale, ox + 62 * scale, oy + 404 * scale,
          ox + 54 * scale, oy + 374 * scale)
      ..cubicTo(ox + 44 * scale, oy + 340 * scale, ox + 42 * scale, oy + 298 * scale,
          ox + 46 * scale, oy + 258 * scale)
      ..cubicTo(ox + 50 * scale, oy + 218 * scale, ox + 60 * scale, oy + 178 * scale,
          ox + 76 * scale, oy + 148 * scale)
      ..cubicTo(ox + 92 * scale, oy + 118 * scale, ox + 116 * scale, oy + 78 * scale,
          ox + 138 * scale, oy + 80 * scale)
      ..close();

    final islandPaint = Paint()
      ..color = const Color(0xFF0F3770).withOpacity(0.70)
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, islandPaint);

    final strokePaint = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(islandPath, strokePaint);

    final rainOval = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(
        center: Offset(ox + 172 * scale, oy + 260 * scale),
        width: 70 * scale,
        height: 110 * scale), rainOval);
    final rainStroke = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(Rect.fromCenter(
        center: Offset(ox + 172 * scale, oy + 260 * scale),
        width: 70 * scale,
        height: 110 * scale), rainStroke);

    final pins = [
      ('Antsiranana', 0.51, 0.16, '33°C', '☀️', false),
      ('Mahajanga', 0.26, 0.35, '36°C', '🌤', false),
      ('Antananarivo', 0.56, 0.48, '27°C', '⛅', true),
      ('Toamasina', 0.73, 0.44, '31°C', '🌧', false),
      ('Fianarantsoa', 0.54, 0.58, '22°C', '🌦', false),
      ('Toliara', 0.33, 0.66, '34°C', '☀️', false),
      ('Fort Dauphin', 0.65, 0.69, '24°C', '🌬', false),
    ];

    for (final pin in pins) {
      final px = ox + pin.$2 * 220 * scale;
      final py = oy + pin.$3 * 480 * scale;
      final isActive = pin.$6;

      final circlePaint = Paint()
        ..color = isActive
            ? AppTheme.accentBlue.withOpacity(0.15)
            : AppTheme.cardBg
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), isActive ? 22 * scale : 18 * scale, circlePaint);

      if (isActive) {
        final borderPaint = Paint()
          ..color = AppTheme.accentBlue.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset(px, py), 22 * scale, borderPaint);
      }

      final tp = TextPainter(
        text: TextSpan(
          text: pin.$4.split('°')[0],
          style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 10 * scale : 8 * scale,
              fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py + (isActive ? 14 : 11) * scale));

      final ep = TextPainter(
        text: TextSpan(
          text: pin.$5,
          style: TextStyle(fontSize: isActive ? 15 * scale : 13 * scale),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ep.paint(canvas, Offset(px - ep.width / 2, py - (isActive ? 20 : 16) * scale));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
