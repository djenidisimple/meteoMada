import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── PALETTE PRINCIPALE ──────────────────────────────────
  static const Color backgroundDeep = Color(0xFF0A0A0A);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color backgroundSurface = Color(0xFF1A1A1A);
  static const Color backgroundCard = Color(0x1AFFFFFF);
  static const Color backgroundCardHover = Color(0x2AFFFFFF);

  // ─── NOUVEAU DÉGRADÉ SOMBRE PREMIUM ─────────────────────
  static const Color homeDarkTop = Color(0xFF1D2026);
  static const Color homeDarkBottom = Color(0xFF0F1013);

  // ─── SUN FLARE ──────────────────────────────────────────
  static const Color sunFlareColor = Color(0xFFE57C23);

  // ─── ACCENTS NÉON ────────────────────────────────────────
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentBlueLight = Color(0xFF81D4FA);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentGreenLight = Color(0xFFA5D6A7);
  static const Color accentOrange = Color(0xFFFF8A65);
  static const Color accentOrangeLight = Color(0xFFFFAB91);
  static const Color accentRed = Color(0xFFE57373);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color accentYellowLight = Color(0xFFFFF176);
  static const Color accentPurple = Color(0xFFCE93D8);
  static const Color accentCyan = Color(0xFF4DD0E1);

  // ─── NIVEAUX CYCLONE ────────────────────────────────────
  static const Color surveillanceColor = Color(0xFF4FC3F7);
  static const Color depressionColor = Color(0xFF81D4FA);
  static const Color tempeteColor = Color(0xFFFFD54F);
  static const Color cycloneColor = Color(0xFFFF8A65);
  static const Color alerteJauneColor = Color(0xFFFFD54F);
  static const Color alerteOrangeColor = Color(0xFFFF8A65);
  static const Color alerteRougeColor = Color(0xFFE57373);
  static const Color postCycloneColor = Color(0xFFA5D6A7);

  // ─── TEXTE ───────────────────────────────────────────────
  static Color get textPrimary => Colors.white;
  static Color get textSecondary => Colors.white.withValues(alpha: 0.65);
  static Color get textDim => Colors.white.withValues(alpha: 0.35);

  // ─── BACKWARD COMPAT (utilisé par certains widgets) ──────
  static Color get cardBg => backgroundCard;
  static Color get cardBorder => Colors.white.withValues(alpha: 0.08);

  // ─── TYPOGRAPHIE ─────────────────────────────────────────
  static const String _fontFamily = 'Poppins';

  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      overflow: overflow,
    );
  }

  static TextStyle get displayLarge => poppins(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        letterSpacing: -4,
        color: Colors.white,
      );

  static TextStyle get displayMedium => poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: Colors.white,
      );

  static TextStyle get headingLarge => poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get headingMedium => poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get headingSmall => poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get bodyLarge => poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get bodySmall => poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textDim,
      );

  // ─── DÉCORATIONS GLASSMORPHISM ───────────────────────────
  static BoxDecoration glass({
    double radius = 24,
    Color? borderColor,
    double borderWidth = 0.5,
    Color? bgColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: bgColor ?? backgroundCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.08),
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  static BoxDecoration glassActive({
    double radius = 24,
    Color accent = accentBlue,
  }) {
    return BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: accent.withValues(alpha: 0.25),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration glassTinted({
    double radius = 24,
    Color tint = accentBlue,
  }) {
    return BoxDecoration(
      color: tint.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: tint.withValues(alpha: 0.12),
        width: 0.5,
      ),
    );
  }

  // ─── DÉCORATIONS SPÉCIFIQUES ─────────────────────────────
  static const Gradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 0.7, 1.0],
    colors: [
      Color(0xFF0F0F0F),
      Color(0xFF141414),
      Color(0xFF1A1A1A),
      Color(0xFF0A0A0A),
    ],
  );

  static const Gradient homeScreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      homeDarkTop,
      homeDarkBottom,
    ],
  );

  static Decoration sunFlareDecoration({double size = 240}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          sunFlareColor.withValues(alpha: 0.15),
          sunFlareColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  static const Gradient marineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.35, 0.65, 1.0],
    colors: [
      Color(0xFF051830),
      Color(0xFF0A2240),
      Color(0xFF0D3050),
      Color(0xFF061A28),
    ],
  );

  static BoxDecoration get glassCard => glass(radius: 16);
  static BoxDecoration get activeCard => glassActive(radius: 16);
  static BoxDecoration get marineCard =>
      glassTinted(radius: 16, tint: accentGreen);
  static BoxDecoration get dangerCard =>
      glassActive(radius: 18, accent: accentRed);
  static BoxDecoration get warningCard =>
      glassTinted(radius: 14, tint: accentOrange);
  static BoxDecoration get watchCard =>
      glassTinted(radius: 14, tint: accentYellow);

  // ─── BLUR EFFECT ─────────────────────────────────────────
  static BoxDecoration blur({
    double radius = 24,
    double sigma = 20,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 0.5,
      ),
    );
  }

  // ─── HELPERS STATIQUES CYCLONE ───────────────────────────
  static Color colorForNiveau(String niveau) {
    switch (niveau) {
      case 'alerte_rouge':
      case 'cyclone_intense':
        return alerteRougeColor;
      case 'alerte_orange':
      case 'cyclone_tropical':
        return alerteOrangeColor;
      case 'alerte_jaune':
      case 'tempete':
        return alerteJauneColor;
      case 'depression':
        return depressionColor;
      case 'post_cyclone':
      case 'bilan':
      case 'dissipation':
        return postCycloneColor;
      default:
        return surveillanceColor;
    }
  }

  static String labelForNiveau(String niveau) {
    switch (niveau) {
      case 'surveillance':
        return 'Surveillance';
      case 'depression':
        return 'Dépression';
      case 'tempete':
        return 'Tempête';
      case 'cyclone_tropical':
        return 'Cyclone tropical';
      case 'cyclone_intense':
        return 'Cyclone intense';
      case 'alerte_jaune':
        return 'Alerte jaune';
      case 'alerte_orange':
        return 'Alerte orange';
      case 'alerte_rouge':
        return 'Alerte rouge';
      case 'post_cyclone':
        return 'Post-cyclone';
      case 'bilan':
        return 'Bilan';
      case 'dissipation':
        return 'Dissipation';
      default:
        return niveau;
    }
  }
}
