import 'package:flutter/material.dart';
import '../data.dart';
import '../painters/painters.dart';
import '../theme.dart';

/// Curva de desgaste del Motor por etapa (T1→T5). [marca] resalta una etapa.
class DesgasteChart extends StatelessWidget {
  final int? marca;
  final bool dark;
  final double progress;
  const DesgasteChart({super.key, this.marca, this.dark = false, this.progress = 1});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(painter: _DesgastePainter(marca, dark, t), size: Size.infinite),
      );
}

class _DesgastePainter extends CustomPainter {
  final int? marca;
  final bool dark;
  final double t;
  _DesgastePainter(this.marca, this.dark, this.t);

  @override
  void paint(Canvas c, Size s) {
    final grid = dark ? AC.nightLine : AC.line;
    final txtCol = dark ? AC.nightMute : AC.mute;
    final lineCol = dark ? AC.lilac : AC.carm;
    const left = 36.0, bottom = 28.0, top = 14.0, right = 12.0;
    final w = s.width - left - right, h = s.height - top - bottom;
    Offset pt(int i, num v) => Offset(left + i * w / 4, top + h * (1 - v / 100));
    for (final v in [0, 50, 100]) {
      final y = top + h * (1 - v / 100);
      c.drawLine(Offset(left, y), Offset(left + w, y), strokeP(grid, 1));
      drawText(c, '$v %', Offset(left - 6, y), AT.sans(10, color: txtCol, weight: FontWeight.w600), align: TextAlign.right);
    }
    final pts = [for (var i = 0; i < 5; i++) pt(i, desgastePorEtapa[i] * t)];
    final area = polyPath([Offset(left, top + h), ...pts, Offset(left + w, top + h)]);
    c.drawPath(area, fillP(lineCol, dark ? .16 : .10));
    c.drawPath(polyPath(pts, close: false), strokeP(lineCol, 2.4));
    for (var i = 0; i < 5; i++) {
      final on = marca == i;
      c.drawCircle(pts[i], on ? 6 : 3.5, fillP(on ? lineCol : (dark ? AC.nightPanel : AC.paper)));
      c.drawCircle(pts[i], on ? 6 : 3.5, strokeP(lineCol, 1.6));
      drawText(c, etapas[i].nombre, Offset(pts[i].dx, top + h + 16),
          AT.sans(10, color: on ? (dark ? AC.nightText : AC.ink) : txtCol, weight: on ? FontWeight.w700 : FontWeight.w500),
          align: TextAlign.center);
      if (on) {
        drawText(c, '${desgastePorEtapa[i]} %', pts[i] + const Offset(0, -16),
            AT.sans(12, color: dark ? AC.nightText : AC.ink, weight: FontWeight.w700),
            align: TextAlign.center);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DesgastePainter o) => o.marca != marca || o.t != t || o.dark != dark;
}
