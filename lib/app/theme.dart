import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de color de la guía de estilo (Figma · 00 Guía de estilo).
class AC {
  static const parch = Color(0xFFEFE4CC);
  static const parch2 = Color(0xFFF6EEDC);
  static const paper = Color(0xFFFBF6EA);
  static const line = Color(0xFFD9CBAE);
  static const ink = Color(0xFF2B2520);
  static const ink2 = Color(0xFF4A3B2E);
  static const mute = Color(0xFF6B5D4E);
  static const faint = Color(0xFF9C8E7A);
  static const carm = Color(0xFFC0392B);
  static const carmD = Color(0xFFA8432F);
  static const carmL = Color(0xFFF2C4BC);
  static const turq = Color(0xFF1FA3B3);
  static const turqD = Color(0xFF3B8D93);
  static const turqL = Color(0xFFBFE3E6);
  static const esme = Color(0xFF2E9E5B);
  static const esmeD = Color(0xFF4C8A5C);
  static const esmeL = Color(0xFFC3E3CD);
  static const viol = Color(0xFF6E4F8A);
  static const violL = Color(0xFFD9CCE6);
  static const ochre = Color(0xFFC98A3A);
  static const blue = Color(0xFF2F5D8A);
  static const night = Color(0xFF1C1620);
  static const night2 = Color(0xFF2E2238);
  static const nightPanel = Color(0xFF241C2A);
  static const nightLine = Color(0xFF4A3B58);
  static const nightText = Color(0xFFF6EEDC);
  static const nightMute = Color(0xFFB9AAC8);
  static const lilac = Color(0xFFC9A8F0);
}

/// Estilos tipográficos: Libre Baskerville (títulos), Inter (UI), Caveat (notas de Asmodeo).
class AT {
  static TextStyle serif(double size, {Color color = AC.ink, FontWeight weight = FontWeight.w700, FontStyle? style, double? height}) =>
      GoogleFonts.libreBaskerville(fontSize: size, color: color, fontWeight: weight, fontStyle: style, height: height);

  static TextStyle sans(double size, {Color color = AC.ink, FontWeight weight = FontWeight.w400, double? height, double? spacing}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, height: height, letterSpacing: spacing);

  static TextStyle hand(double size, {Color color = AC.blue}) =>
      GoogleFonts.caveat(fontSize: size, color: color, fontWeight: FontWeight.w700, height: 1.05);

  static TextStyle eyebrow({Color color = AC.carm}) =>
      GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w700, letterSpacing: 1.6);
}

ThemeData asmodeoTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AC.parch,
    colorScheme: ColorScheme.fromSeed(seedColor: AC.carm, primary: AC.ink, secondary: AC.carm, surface: AC.paper),
    textTheme: GoogleFonts.interTextTheme(),
  );
}
