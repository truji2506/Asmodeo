import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../painters/painters.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

/// 03 · El Motor — la fragua (paso 1) y el Fragmento de la Creación (paso 2).
class MotorScreen extends StatefulWidget {
  const MotorScreen({super.key});
  @override
  State<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends State<MotorScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
    ..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: s.completo
          ? _Creacion(key: const ValueKey('creacion'), pulse: _pulse)
          : _Fragua(key: const ValueKey('fragua'), pulse: _pulse),
    );
  }
}

// ═════════════════════════ 03 · LA FRAGUA ═════════════════════════

const _centro = Offset(720, 380);
const _origen = {'carmesi': Offset(470, 210), 'turquesa': Offset(980, 210), 'esmeralda': Offset(960, 520)};

class _Fragua extends StatelessWidget {
  final AnimationController pulse;
  const _Fragua({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final faltan = 3 - s.recolectados.length;
    final listos = s.enFragua.length == 3;
    final dx = Lienzo.dxOf(context);
    return Stack(children: [
     shift(dx / 2, [
      CanvasPaint((c) => _pintar(c, s, pulse.value), repaint: pulse),
      // núcleo: destino del arrastre
      Positioned(
        left: _centro.dx - 100,
        top: _centro.dy - 100,
        width: 200,
        height: 200,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (d) => !s.enFragua.contains(d.data),
          onAcceptWithDetails: (d) => s.meterEnFragua(d.data),
          builder: (context, cand, _) => Tap(
            onTap: listos ? s.encender : null,
            tooltip: listos ? 'Encender el Motor' : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cand.isNotEmpty ? AC.carm : Colors.transparent, width: 3),
              ),
              child: Stack(alignment: Alignment.center, children: [
                for (final f in fragmentos)
                  if (s.enFragua.contains(f.id))
                    Transform.translate(
                      offset: dirDeg(f.angulo) * 34,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, k, child) => Transform.scale(scale: k, child: child),
                        child: FragIcon(f.forma, f.color, 15),
                      ),
                    ),
                if (listos)
                  Positioned(
                    bottom: 26,
                    child: Text('TOCA', style: AT.sans(11, color: Colors.white, weight: FontWeight.w700, spacing: 2)),
                  ),
              ]),
            ),
          ),
        ),
      ),
      // fragmentos a arrastrar
      for (final f in fragmentos) _FragmentoVolador(f),
     ]),
      // tarjeta instrucción
      card(40, 100, 330, 200),
      eyebrow(64, 136, listos ? 'El Motor · paso 2' : 'El Motor · paso 1'),
      txt(64, 176, listos ? 'Enciende el\nnúcleo' : 'Lleva los fragmentos\na la fragua', AT.serif(24, height: 1.33)),
      txt(
          64,
          254,
          faltan > 0
              ? 'Te ${faltan == 1 ? 'falta 1 fragmento' : 'faltan $faltan fragmentos'}. Vuelve al Viaje y fórjalos antes de encender el Motor.'
              : (listos
                  ? 'Los tres cristales encajaron. Toca el núcleo para fundirlos.'
                  : 'Arrastra cada cristal al núcleo. Cuando los tres encajen, la fragua los funde.'),
          AT.sans(13, color: AC.ink2, height: 1.5),
          w: 280),
      if (faltan > 0) button(64, 318, 200, 'Volver al Viaje', kind: BtnKind.ghost, h: 40, size: 14, onTap: () => s.ir(Pantalla.viaje)),
      // bandeja de estado
     shift(dx, [
      card(1070, 100, 330, 270),
      eyebrow(1094, 136, 'Fragmentos', color: AC.mute),
      for (final (i, f) in fragmentos.indexed)
        Positioned(
          left: 1090,
          top: 156.0 + i * 66,
          width: 290,
          height: 56,
          child: Container(
            decoration: BoxDecoration(color: AC.parch2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AC.line)),
            child: Row(children: [
              const SizedBox(width: 10),
              FragBadge(f, r: 18, got: s.recolectados.contains(f.id)),
              const SizedBox(width: 10),
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.nombre, style: AT.sans(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  !s.recolectados.contains(f.id)
                      ? 'Falta · ${f.zona}'
                      : (s.enFragua.contains(f.id) ? 'En el núcleo' : 'Rumbo a la fragua'),
                  style: AT.sans(12, color: s.recolectados.contains(f.id) ? f.color : AC.faint, weight: FontWeight.w600),
                ),
              ]),
            ]),
          ),
        ),
      marginNote(1080, 424, 'Calor insoportable.\nPrecisión de relojero.', 21, rot: 3),
      // pista
      Positioned(
        left: 1084,
        top: 500,
        width: 300,
        height: 44,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AC.ink, borderRadius: BorderRadius.circular(22)),
          child: Text(listos ? 'Toca el núcleo para encenderlo' : 'Arrastra · luego toca el núcleo',
              style: AT.sans(13, color: AC.paper, weight: FontWeight.w600)),
        ),
      ),
     ]),
    ]);
  }

  void _pintar(Canvas c, AsmodeoState s, double p) {
    final listos = s.enFragua.length == 3;
    final glowCol = listos ? const Color(0xFF9B78C2) : const Color(0xFFE08A3A);
    final gr = 300 * (1 + .04 * math.sin(p * 2 * math.pi));
    c.drawCircle(
        _centro,
        gr,
        Paint()
          ..shader = RadialGradient(colors: [glowCol.withValues(alpha: .45), glowCol.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: _centro, radius: gr)));
    // anillos girando
    c.save();
    c.translate(_centro.dx, _centro.dy);
    c.rotate(p * 2 * math.pi / 6);
    drawDashedCircle(c, Offset.zero, 200, strokeP(AC.ochre, 1.4, .5), dash: 3, gap: 7);
    c.rotate(-p * 2 * math.pi / 3);
    drawDashedCircle(c, Offset.zero, 150, strokeP(AC.ochre, 1.4, .7), dash: 3, gap: 7);
    c.restore();
    c.drawCircle(_centro, 98, strokeP(AC.ink, 1.6));
    c.drawCircle(
        _centro,
        90,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.2, -.24),
            radius: .65,
            colors: listos
                ? const [Color(0xFFB597D6), Color(0xFF7A5A9A), Color(0xFF4E3866)]
                : const [Color(0xFFE9E0CF), Color(0xFFDCD0BA), Color(0xFFCFC2A8)],
          ).createShader(Rect.fromCircle(center: _centro, radius: 90)));
    c.drawCircle(_centro, 90, strokeP(AC.ink, 2));
    for (var i = 0; i < 3; i++) {
      c.drawCircle(_centro, 60.0 - i * 14, strokeP(listos ? Colors.white : AC.ink2, 1.2, .6));
    }
    // yunque / fragua
    final yunque = polyPath(const [Offset(470, 860), Offset(540, 640), Offset(900, 640), Offset(970, 860)]);
    c.drawPath(yunque, fillP(const Color(0xFFCDB08A)));
    c.drawPath(yunque, strokeP(AC.ink2, 1.6));
    final barra = RRect.fromLTRBR(510, 610, 930, 644, const Radius.circular(6));
    c.drawRRect(barra, fillP(const Color(0xFFB89A6E)));
    c.drawRRect(barra, strokeP(AC.ink2, 1.6));
    c.drawPath(Path()..moveTo(600, 640)..quadraticBezierTo(720, 600, 840, 640), strokeP(AC.ochre, 2, .7));
    // llamas (titilan con el pulso)
    final fl = 1 + .12 * math.sin(p * 2 * math.pi * 3);
    for (final x0 in [640.0, 740.0]) {
      c.save();
      c.translate(x0, 608);
      c.scale(1, fl);
      final llama = Path()
        ..moveTo(0, 0)
        ..relativeQuadraticBezierTo(10, -40, 24, -10)
        ..relativeQuadraticBezierTo(8, -36, 26, -6)
        ..relativeQuadraticBezierTo(10, -30, 22, 4)
        ..close();
      c.drawPath(llama, fillP(const Color(0xFFE89A3C), .8));
      c.drawPath(llama, strokeP(AC.carm, 1.2, .8));
      c.restore();
    }
    drawText(c, 'LA FRAGUA', const Offset(720, 755), AT.serif(16, color: AC.ink2).copyWith(letterSpacing: 6), align: TextAlign.center);
    // trayectorias de los fragmentos pendientes
    for (final f in fragmentos) {
      if (s.enFragua.contains(f.id) || !s.recolectados.contains(f.id)) continue;
      final o = _origen[f.id]!;
      final a = math.atan2(_centro.dy - o.dy, _centro.dx - o.dx);
      final u = Offset(math.cos(a), math.sin(a));
      drawDashedLine(c, o + u * 54, _centro - u * 112, strokeP(f.color, 1.6), dash: 5, gap: 6);
      final n = Offset(math.sin(a), -math.cos(a));
      for (final k in [-14.0, 0.0, 14.0]) {
        final b = o - u * 60 + n * k;
        c.drawLine(b, b - u * 46, strokeP(AC.ink2, 1.6, .6));
      }
    }
  }
}

class _FragmentoVolador extends StatelessWidget {
  final Fragmento f;
  const _FragmentoVolador(this.f);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final o = _origen[f.id]!;
    final got = s.recolectados.contains(f.id);
    final dentro = s.enFragua.contains(f.id);
    Widget medallon({double op = 1, bool fantasma = false}) => Opacity(
          opacity: op,
          child: SizedBox(
            width: 92,
            height: 92,
            child: Stack(alignment: Alignment.center, children: [
              if (fantasma)
                CustomPaint(size: const Size(92, 92), painter: DashedCirclePainter(AC.faint))
              else
                Container(decoration: BoxDecoration(color: f.colorClaro.withValues(alpha: .6), shape: BoxShape.circle)),
              FragIcon(f.forma, fantasma ? AC.faint : f.color, 30, filled: !fantasma, dashed: fantasma, sw: 2),
            ]),
          ),
        );

    Widget child;
    if (dentro) {
      child = medallon(op: .25, fantasma: true);
    } else if (!got) {
      child = Tooltip(
        message: 'Falta forjar el ${f.nombre} en ${f.zona}',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          medallon(fantasma: true),
          Text('Falta · ${f.zona}', style: AT.sans(11, color: AC.faint, weight: FontWeight.w700)),
        ]),
      );
    } else {
      child = MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Draggable<String>(
          data: f.id,
          feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: medallon())),
          childWhenDragging: medallon(op: .3, fantasma: true),
          child: _Flotar(child: medallon()),
        ),
      );
    }
    return Positioned(left: o.dx - 46, top: o.dy - 46, child: child);
  }
}

/// Leve flotación para invitar al arrastre.
class _Flotar extends StatefulWidget {
  final Widget child;
  const _Flotar({required this.child});
  @override
  State<_Flotar> createState() => _FlotarState();
}

class _FlotarState extends State<_Flotar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(offset: Offset(0, -6 * Curves.easeInOut.transform(_c.value)), child: child),
        child: widget.child,
      );
}

// ═════════════════════════ 04 · FRAGMENTO DE LA CREACIÓN ═════════════════════════

const _mc = Offset(500, 480);
const _mk = 1.15;
const _notas = {
  'carmesi': Offset(64, 214),
  'turquesa': Offset(720, 200),
  'esmeralda': Offset(600, 730),
};

class _Creacion extends StatelessWidget {
  final AnimationController pulse;
  const _Creacion({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final estado = {
      for (final f in fragmentos) f.id: (s.lupa && s.lupaFrag == f.id) ? Cristal.rayosX : Cristal.puesto,
    };
    final dx = Lienzo.dxOf(context);
    return Stack(children: [
      // fondo nocturno
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AC.night, AC.night2]),
          ),
        ),
      ),
      CanvasPaint((c) {
        final rnd = math.Random(14);
        for (var i = 0; i < 60 + dx ~/ 16; i++) {
          final o = Offset(rnd.nextDouble() * (990 + dx), 90 + rnd.nextDouble() * 800);
          final r = .6 + rnd.nextDouble();
          final op = .15 + rnd.nextDouble() * .35;
          final tw = .5 + .5 * math.sin(pulse.value * 2 * math.pi + i);
          c.drawCircle(o, r, fillP(Colors.white, op * (.6 + .4 * tw)));
        }
      }, repaint: pulse),
     shift(dx / 2, [
      CanvasPaint((c) {
        c.drawCircle(_mc, 340, fillP(Colors.white, .03));
        c.drawCircle(_mc, 340, strokeP(const Color(0xFFB597D6), 1.2, .5));
        final beat = math.max(0.0, math.sin(pulse.value * 2 * math.pi));
        MotorPainter(center: _mc, k: _mk, estado: estado, dark: true, pulse: beat).paint(c, Size.zero);
        // líneas de anotación
        for (final f in fragmentos) {
          final tip = _mc + dirDeg(f.angulo) * 264;
          final b = _notas[f.id]!;
          final ey = b.dy < tip.dy ? b.dy + 52 : b.dy;
          drawDashedLine(c, tip, Offset(b.dx + 110, ey), strokeP(AC.nightMute, 1), dash: 3, gap: 3);
        }
        if (s.lupa) _pintarLupa(c, fragPorId(s.lupaFrag));
      }, repaint: pulse),
      // anotaciones + hotspots
      for (final f in fragmentos) ...[
        Positioned(
          left: _notas[f.id]!.dx,
          top: _notas[f.id]!.dy,
          width: 220,
          height: 52,
          child: Tap(
            onTap: () => s.setLupaFrag(f.id),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2130),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: s.lupa && s.lupaFrag == f.id ? f.color : const Color(0xFF5E4A70)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Artefacto de origen', style: AT.sans(10, color: AC.nightMute, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(f.artefacto, style: AT.sans(13, color: AC.nightText, weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
        Positioned(
          left: (_mc + dirDeg(f.angulo) * 264).dx - 14,
          top: (_mc + dirDeg(f.angulo) * 264).dy - 14,
          width: 28,
          height: 28,
          child: Tap(
            onTap: () => s.setLupaFrag(f.id),
            tooltip: 'Rayos X · ${f.nombre}',
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: f.color, width: 2)),
              child: Text('+', style: AT.sans(15, color: f.color, weight: FontWeight.w700)),
            ),
          ),
        ),
      ],
      if (s.lupa) _fichaRayosX(s, fragPorId(s.lupaFrag)),
      marginNote(560, 836, 'Ni una chispa de magia. Solo ingeniería.', 22, color: AC.lilac, rot: -2, w: 440),
     ]),
      eyebrow(64, 128, 'El Fragmento de la Creación', color: AC.lilac),
      txt(64, 166, 'El universo late al ritmo de su creador', AT.serif(22, color: AC.nightText)),
      ..._barraInferior(s),
      shift(dx, const [_PanelStats()]),
    ]);
  }

  /// Lente de rayos X sobre el cristal seleccionado: corte transversal.
  void _pintarLupa(Canvas c, Fragmento f) {
    final l = _mc + dirDeg(f.angulo) * 172;
    const lr = 86.0;
    c.drawCircle(l, lr, fillP(const Color(0xFFEAF1F6), .97));
    final c0 = l + const Offset(0, -4);
    final outer = polyPath(shapePts(f.forma, c0, 48));
    c.drawPath(outer, fillP(f.colorClaro));
    c.drawPath(outer, strokeP(f.colorOscuro, 1.6));
    c.drawPath(polyPath(shapePts(f.forma, c0, 34)), fillP(f.color, .35));
    c.drawCircle(c0, 13, strokeP(AC.viol, 2));
    drawText(c, 'Sección A–A′', l + const Offset(0, 58), AT.sans(11, color: AC.blue, weight: FontWeight.w700), align: TextAlign.center);
    c.drawCircle(l, lr, strokeP(AC.nightText, 4));
    c.drawLine(l + const Offset(lr * .7, lr * .7), l + const Offset(lr * 1.2, lr * 1.2), strokeP(AC.nightText, 10));
    // línea a la ficha
    drawDashedLine(c, const Offset(240, 520), l + const Offset(-40, lr - 12), strokeP(AC.nightMute, 1), dash: 3, gap: 3);
  }

  Widget _fichaRayosX(AsmodeoState s, Fragmento f) {
    final vals = radarGuardian[f.id]!;
    var top = 0;
    for (var i = 1; i < vals.length; i++) {
      if (vals[i] > vals[top]) top = i;
    }
    return Positioned(
      left: 40,
      top: 520,
      width: 250,
      height: 150,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
        decoration: BoxDecoration(color: AC.parch2, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Rayos X · ${f.nombre}', style: AT.sans(14, weight: FontWeight.w700))),
            Tap(onTap: () => s.setLupa(false), child: Text('✕', style: AT.sans(14, color: AC.mute, weight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          Text('Corteza densa · cuerpo translúcido', style: AT.sans(11, color: AC.ink2)),
          const SizedBox(height: 4),
          Text('Vena de energía → núcleo', style: AT.sans(11, color: AC.ink2)),
          const SizedBox(height: 10),
          Text('${ejesRadar[top]} del guardián: ${vals[top].round()}', style: AT.sans(12, color: f.color, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Extraído: ${f.artefacto.toLowerCase()} · ${horasExtraccion[f.id]} h', style: AT.sans(11, color: AC.mute)),
        ]),
      ),
    );
  }

  List<Widget> _barraInferior(AsmodeoState s) => [
        Positioned(
          left: 64,
          top: 796,
          width: 150,
          height: 40,
          child: Tap(
            onTap: () => s.setLupa(!s.lupa),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: s.lupa ? AC.parch2 : const Color(0xFF2A2130),
                borderRadius: BorderRadius.circular(20),
                border: s.lupa ? null : Border.all(color: const Color(0xFF5E4A70)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search, size: 18, color: s.lupa ? AC.ink : AC.nightText),
                const SizedBox(width: 6),
                Text('Lupa rayos X', style: AT.sans(13, color: s.lupa ? AC.ink : AC.nightText, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        Positioned(
          left: 226,
          top: 796,
          width: 230,
          height: 40,
          child: Tooltip(
            message: 'Latido del universo',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2130),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5E4A70)),
              ),
              child: Row(children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: pulse,
                    builder: (context, _) => CustomPaint(painter: EcgPainter(pulse.value, AC.lilac), size: const Size(140, 40)),
                  ),
                ),
                const SizedBox(width: 10),
                Text('40 lpm', style: AT.sans(12, color: AC.lilac, weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ];
}

class _PanelStats extends StatelessWidget {
  const _PanelStats();
  static const px = 1000.0, pw = 400.0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const tabs = ['Guardianes', 'Desgaste', 'Recursos', 'Daño'];
    return Stack(children: [
      card(px, 100, pw, 770, fill: AC.nightPanel, border: AC.nightLine, radius: 18),
      eyebrow(px + 24, 136, 'Datos de Asmodeo', color: AC.lilac),
      txt(px + 24, 172, 'Stats del Motor', AT.serif(22, color: AC.nightText)),
      Positioned(
        left: px + 24,
        top: 192,
        child: Row(children: [
          for (final (i, t) in tabs.indexed) ...[
            Tap(
              onTap: () => s.setStatsTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: s.statsTab == i ? AC.nightText : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: s.statsTab == i ? null : Border.all(color: const Color(0xFF5E4A70)),
                ),
                child: Text(t, style: AT.sans(12, color: s.statsTab == i ? AC.ink : const Color(0xFFCFC3D9), weight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ]),
      ),
      Positioned(
        left: px,
        top: 230,
        width: pw,
        height: 350,
        child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _contenido(s)),
      ),
      // KPIs
      for (final (i, (v, l)) in const [('60 h', 'extracción total'), ('100 %', 'desgaste final'), ('45 %', 'daño mecánico')].indexed)
        Positioned(
          left: px + 24 + i * 120.0,
          top: 596,
          width: 110,
          height: 84,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AC.nightLine),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v, style: AT.serif(22, color: AC.nightText)),
              const SizedBox(height: 6),
              Text(l, style: AT.sans(11, color: AC.nightMute, weight: FontWeight.w500)),
            ]),
          ),
        ),
      button(px + 24, 720, pw - 48, 'Llevar a tu mesa · AR',
          kind: BtnKind.accent, icon: Icons.view_in_ar, onTap: () => aviso(context, 'Próximamente: el Motor en tu mesa con realidad aumentada.')),
      button(px + 24, 780, pw - 48, 'Desensamblar y reiniciar', kind: BtnKind.outline, onTap: s.reiniciar),
    ]);
  }

  Widget _contenido(AsmodeoState s) {
    switch (s.statsTab) {
      case 0:
        return Stack(key: const ValueKey(0), children: [
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _RadarNoche(s.guardianesVisibles.toSet())))),
          Positioned(
            left: 24,
            top: 282,
            child: Row(children: [
              for (final g in fragmentos) ...[
                PillChip(
                  g.guardianCorto,
                  active: s.guardianesVisibles.contains(g.id),
                  color: g.color,
                  dot: g.color,
                  dark: true,
                  onTap: () => s.toggleGuardian(g.id),
                ),
                const SizedBox(width: 8),
              ],
            ]),
          ),
          Positioned(left: 24, top: 322, child: Text('Toca un guardián para mostrarlo u ocultarlo', style: AT.sans(11, color: const Color(0xFF9A8BAA)))),
        ]);
      case 1:
        return Stack(key: const ValueKey(1), children: [
          Positioned(left: 24, top: 18, child: Text('Desgaste del Motor por etapa', style: AT.sans(13, color: AC.nightText, weight: FontWeight.w700))),
          const Positioned(left: 16, top: 44, width: 360, height: 240, child: DesgasteChart(marca: 4, dark: true)),
          Positioned(
            left: 24,
            top: 300,
            width: 352,
            child: Text('Cada bioma cobró su precio: el Motor llega a la fragua al 100 % de desgaste.',
                style: AT.sans(12, color: AC.nightMute, height: 1.45)),
          ),
        ]);
      case 2:
        return _Dona(key: const ValueKey(2), titulo: 'Recursos tácticos', datos: recursos, nota: 'Materiales primero: Asmodeo construye antes de pelear.');
      default:
        return _Barras(key: const ValueKey(3));
    }
  }
}

class _RadarNoche extends CustomPainter {
  final Set<String> visibles;
  _RadarNoche(this.visibles);

  @override
  void paint(Canvas c, Size size) {
    const rc = Offset(200, 152); // (1200, 382) en el lienzo
    const rr = 100.0;
    radarGrid(c, rc, rr, AC.nightLine);
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      drawText(c, ejesRadar[i], Offset(rc.dx + (rr + 40) * math.cos(a), rc.dy + (rr + 20) * math.sin(a)),
          AT.sans(10, color: AC.nightMute, weight: FontWeight.w600),
          align: TextAlign.center);
    }
    for (final g in fragmentos) {
      if (!visibles.contains(g.id)) continue;
      final p = polyPath(radarPts(rc, rr, radarGuardian[g.id]!));
      c.drawPath(p, fillP(g.color, .18));
      c.drawPath(p, strokeP(g.color, 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarNoche o) => o.visibles.length != visibles.length || !o.visibles.containsAll(visibles);
}

class _Dona extends StatelessWidget {
  final String titulo;
  final List<(String, int, Color)> datos;
  final String nota;
  const _Dona({super.key, required this.titulo, required this.datos, required this.nota});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(left: 24, top: 18, child: Text(titulo, style: AT.sans(13, color: AC.nightText, weight: FontWeight.w700))),
      Positioned(
        left: 24,
        top: 50,
        width: 200,
        height: 200,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => CustomPaint(
            painter: _DonaPainter([for (final d in datos) d.$2], [for (final d in datos) d.$3], t),
          ),
        ),
      ),
      for (final (i, d) in datos.indexed)
        Positioned(
          left: 244,
          top: 90.0 + i * 44,
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: d.$3, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.$1, style: AT.sans(12, color: AC.nightMute, weight: FontWeight.w600)),
              Text('${d.$2} %', style: AT.serif(16, color: AC.nightText)),
            ]),
          ]),
        ),
      Positioned(left: 24, top: 300, width: 352, child: Text(nota, style: AT.sans(12, color: AC.nightMute, height: 1.45))),
    ]);
  }
}

class _DonaPainter extends CustomPainter {
  final List<num> vals;
  final List<Color> cols;
  final double t;
  _DonaPainter(this.vals, this.cols, this.t);
  @override
  void paint(Canvas c, Size s) =>
      donut(c, s.center(Offset.zero), s.width / 2 - 14, vals, cols, sw: 22, track: AC.nightLine, progress: t);
  @override
  bool shouldRepaint(covariant _DonaPainter o) => o.t != t;
}

class _Barras extends StatelessWidget {
  const _Barras({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(left: 24, top: 18, child: Text('Origen del daño crítico', style: AT.sans(13, color: AC.nightText, weight: FontWeight.w700))),
      for (final (i, d) in danos.indexed) ...[
        Positioned(left: 24, top: 60.0 + i * 70, child: Text(d.$1, style: AT.sans(12, color: AC.nightMute, weight: FontWeight.w600))),
        Positioned(
          left: 24,
          top: 82.0 + i * 70,
          width: 300,
          height: 16,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: d.$2 / 50),
            duration: Duration(milliseconds: 600 + i * 150),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => ProgressBar(t, color: d.$3, track: AC.nightLine),
          ),
        ),
        Positioned(left: 334, top: 78.0 + i * 70, child: Text('${d.$2} %', style: AT.serif(16, color: AC.nightText))),
      ],
      Positioned(
        left: 24,
        top: 300,
        width: 352,
        child: Text('Mecánico en las Llanuras, energético en los Pantanos, entrópico en las Tundras.',
            style: AT.sans(12, color: AC.nightMute, height: 1.45)),
      ),
    ]);
  }
}
