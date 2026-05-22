import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── PALETTE ────────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFF040C18);
  static const Color backgroundDark = Color(0xFF07101E);
  static const Color backgroundCard = Color(0xFF0D1B4B);
  static const Color gradientStart = Color(0xFF0D1B4B);
  static const Color gradientMid1 = Color(0xFF1A3A6E);
  static const Color gradientMid2 = Color(0xFF0E4D6E);
  static const Color gradientEnd = Color(0xFF0C6B6B);
  static const Color accentBlue = Color(0xFF4FA3E0);
  static const Color accentGreen = Color(0xFF1BE7A0);
  static const Color accentOrange = Color(0xFFF97B40);
  static const Color accentRed = Color(0xFFE24B4A);
  static const Color accentYellow = Color(0xFFF9C75A);
  static const Color accentBlueLight = Color(0xFFA8D9F5);
  static const Color accentGreenLight = Color(0xFF6EE5C0);
  static const Color accentOrangeLight = Color(0xFFFFAD7A);
  static const Color accentYellowLight = Color(0xFFFDE4A6);

  // ─── NIVEAUX CYCLONE ────────────────────────────────────
  static const Color surveillanceColor = Color(0xFF4FA3E0);
  static const Color depressionColor = Color(0xFF7DC8F0);
  static const Color tempeteColor = Color(0xFFF9C75A);
  static const Color cycloneColor = Color(0xFFF97B40);
  static const Color alerteJauneColor = Color(0xFFF9C75A);
  static const Color alerteOrangeColor = Color(0xFFF97B40);
  static const Color alerteRougeColor = Color(0xFFE24B4A);
  static const Color postCycloneColor = Color(0xFF6EE5C0);

  // ─── TYPOGRAPHIE ────────────────────────────────────────
  static TextStyle display(BuildContext context) =>
      GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white);
  static TextStyle title(BuildContext context) =>
      GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle body(BuildContext context) =>
      GoogleFonts.dmSans(fontWeight: FontWeight.w400, color: textSecondary);
  static TextStyle label(BuildContext context) =>
      GoogleFonts.dmSans(fontWeight: FontWeight.w500, color: Colors.white);
  static TextStyle temp(BuildContext context) => GoogleFonts.syne(
      fontSize: 72, fontWeight: FontWeight.w800, letterSpacing: -4, color: Colors.white);

  static Color get textPrimary => Colors.white;
  static Color get textSecondary => Colors.white.withOpacity(0.55);
  static Color get textDim => Colors.white.withOpacity(0.30);
  static Color get cardBg => Colors.white.withOpacity(0.07);
  static Color get cardBorder => Colors.white.withOpacity(0.12);

  // ─── DÉCORATIONS ────────────────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 0.5),
      );

  static BoxDecoration get activeCard => BoxDecoration(
        color: accentBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBlue.withOpacity(0.35), width: 0.8),
      );

  static BoxDecoration get marineCard => BoxDecoration(
        color: accentGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentGreen.withOpacity(0.28), width: 0.8),
      );

  static BoxDecoration get dangerCard => BoxDecoration(
        color: accentRed.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentRed.withOpacity(0.35), width: 0.8),
      );

  static BoxDecoration get warningCard => BoxDecoration(
        color: accentOrange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentOrange.withOpacity(0.28), width: 0.5),
      );

  static BoxDecoration get watchCard => BoxDecoration(
        color: accentYellow.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentYellow.withOpacity(0.28), width: 0.5),
      );

  static const Gradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.38, 0.65, 1.0],
    colors: [Color(0xFF0D1B4B), Color(0xFF1A3A6E), Color(0xFF0E4D6E), Color(0xFF0C6B6B)],
  );

  static const Gradient marineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.40, 0.65, 1.0],
    colors: [Color(0xFF051830), Color(0xFF0A3055), Color(0xFF0A4A6A), Color(0xFF065C68)],
  );

  // ─── STATIC HELPERS ──────────────────────────────────────
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
