import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../painters/painters.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

/// 02 · El Viaje — mapa con línea progresiva + panel del fragmento (Forja / Despiece).
class ViajeScreen extends StatelessWidget {
  const ViajeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final dx = Lienzo.dxOf(context);
    return Stack(children: [
      CanvasPaint((c) => paintScroll(c, Rect.fromLTWH(40, 100, 800 + dx, 760))),
     shift(dx / 2, [
      CanvasPaint((c) => _pintarMapa(c, s)),
      // etiqueta línea progresiva
      Positioned(
        left: 455 - 75, // centro del pergamino
        top: 128,
        width: 150,
        height: 26,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AC.paper,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AC.line),
          ),
          child: Text('Línea progresiva', style: AT.sans(12, color: AC.carm, weight: FontWeight.w700)),
        ),
      ),
      for (var i = 0; i < etapas.length; i++) _Nodo(i),
     ]),
     shift(dx, [
      const _Slider(),
      const Positioned(left: 980, top: 100, width: 420, height: 760, child: PaperCard()),
      Positioned.fill(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _Panel(key: ValueKey('${s.etapa}-${s.viajeTab}'), etapa: s.etapa),
        ),
      ),
     ]),
    ]);
  }

  void _pintarMapa(Canvas c, AsmodeoState s) {
    paintContinent(c, const Rect.fromLTWH(130, 210, 680, 560));
    // ruta: sólida hasta la etapa actual, punteada después
    for (var i = 0; i < etapas.length - 1; i++) {
      final a = etapas[i].pos, b = etapas[i + 1].pos;
      if (i < s.etapa) {
        c.drawLine(a, b, strokeP(AC.carm, 4));
      } else {
        drawDashedLine(c, a, b, strokeP(AC.carm, 2.4, .8), dash: 3, gap: 9);
      }
    }
  }
}

class _Nodo extends StatelessWidget {
  final int i;
  const _Nodo(this.i);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final e = etapas[i];
    final p = e.pos;
    final alcanzable = i <= s.etapaMaxima;
    final sel = s.etapa == i;
    final f = e.fragId == null ? null : fragPorId(e.fragId!);
    final got = f != null && s.recolectados.contains(f.id);

    Widget nodo;
    if (i == 0) {
      nodo = SizedBox.expand(child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(color: AC.ink, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
        ),
        Positioned(
          left: 78,
          top: 51,
          child: Text('Midgard · inicio', style: AT.sans(13, weight: FontWeight.w700)),
        ),
      ]));
    } else if (f == null) {
      // volcán
      nodo = SizedBox.expand(child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        if (sel) _Halo(AC.ochre),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: alcanzable ? const Color(0xFFF1D2AE) : const Color(0xFFEDE4D2),
            shape: BoxShape.circle,
            border: Border.all(color: alcanzable ? AC.ochre : AC.faint, width: 1.6),
          ),
          child: Icon(Icons.local_fire_department, size: 22, color: alcanzable ? AC.ochre : AC.faint),
        ),
        Positioned(
          top: 92,
          child: Text('Volcán · la fragua', style: AT.sans(12, color: alcanzable ? AC.ink : AC.mute, weight: FontWeight.w700)),
        ),
      ]));
    } else {
      nodo = SizedBox.expand(child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        if (sel) _Halo(f.color),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: got ? f.color : f.colorClaro,
            shape: BoxShape.circle,
            border: Border.all(color: f.color, width: 2),
          ),
          alignment: Alignment.center,
          child: FragIcon(f.forma, got ? Colors.white : f.color, 12),
        ),
        Positioned(
          top: 92,
          child: Container(
            width: 92,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AC.paper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AC.line),
            ),
            child: Text(e.nombre, style: AT.sans(12, weight: FontWeight.w700)),
          ),
        ),
      ]));
    }

    return Positioned(
      left: p.dx - 60,
      top: p.dy - 60,
      width: 120,
      height: 120,
      child: Opacity(
        opacity: alcanzable ? 1 : .45,
        child: Tap(
          onTap: alcanzable ? () => s.irEtapa(i) : () => aviso(context, 'Forja el fragmento anterior para seguir la ruta.'),
          tooltip: alcanzable ? e.nombre : 'Bloqueado',
          child: nodo,
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  final Color color;
  const _Halo(this.color);
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: .6, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, k, _) => Container(
          width: 80 * k,
          height: 80 * k,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .18),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: .7), width: 1.4),
          ),
        ),
      );
}

/// Control vertical de progreso (5 paradas) con perilla de engranaje.
class _Slider extends StatelessWidget {
  const _Slider();
  static const sx = 880.0, y0 = 130.0, y1 = 830.0;
  static const paso = (y1 - y0) / 4;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void mover(double localY) {
      final i = ((localY - 20) / paso).round().clamp(0, 4);
      if (i > s.etapaMaxima) {
        s.irEtapa(s.etapaMaxima);
      } else {
        s.irEtapa(i);
      }
    }

    return Stack(children: [
      CanvasPaint((c) {
        c.drawRRect(RRect.fromLTRBR(sx - 3, y0, sx + 3, y1, const Radius.circular(3)), fillP(const Color(0xFFE3D8C2)));
        final kn = y0 + s.etapa * paso;
        c.drawRRect(RRect.fromLTRBR(sx - 3, y0, sx + 3, kn, const Radius.circular(3)), fillP(AC.carm));
        for (var i = 0; i < 5; i++) {
          final y = y0 + i * paso;
          final on = i <= s.etapa;
          c.drawCircle(Offset(sx, y), 7, fillP(on ? AC.carm : AC.paper));
          c.drawCircle(Offset(sx, y), 7, strokeP(on ? AC.carm : (i <= s.etapaMaxima ? AC.ink2 : AC.faint), 1.6));
          drawText(c, etapas[i].nombre, Offset(sx + 30, y),
              AT.sans(12,
                  color: i <= s.etapaMaxima ? AC.ink : AC.faint,
                  weight: i == s.etapa ? FontWeight.w700 : FontWeight.w500));
        }
        drawText(c, 'Progreso', Offset(sx, y1 + 26), AT.sans(11, color: AC.mute, weight: FontWeight.w700), align: TextAlign.center);
      }),
      // perilla
      AnimatedPositioned(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        left: sx - 24,
        top: y0 + s.etapa * paso - 24,
        width: 48,
        height: 48,
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: s.etapa * math.pi / 3),
            duration: const Duration(milliseconds: 380),
            builder: (context, a, _) => Transform.rotate(angle: a, child: CustomPaint(painter: _Perilla())),
          ),
        ),
      ),
      // área de arrastre
      Positioned(
        left: sx - 30,
        top: y0 - 20,
        width: 120,
        height: y1 - y0 + 40,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => mover(d.localPosition.dy),
            onVerticalDragUpdate: (d) => mover(d.localPosition.dy),
          ),
        ),
      ),
    ]);
  }
}

class _Perilla extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final g = gearPath(ctr, 22, teeth: 14);
    c.drawPath(g, fillP(AC.paper));
    c.drawPath(g, strokeP(AC.ink, 1.6));
    c.drawCircle(ctr, 9, fillP(AC.carm));
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ───────────────────────── panel derecho ─────────────────────────

class _Panel extends StatefulWidget {
  final int etapa;
  const _Panel({super.key, required this.etapa});
  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  String? comparar;

  static const px = 980.0, pw = 420.0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final e = etapas[widget.etapa];
    if (e.fragId == null) return _panelSinFragmento(context, s, widget.etapa);
    final f = fragPorId(e.fragId!);
    final got = s.recolectados.contains(f.id);
    return Stack(children: [
      eyebrow(px + 24, 136, 'Fragmento del punto'),
      txt(px + 24, 174, 'Fragmento ${f.nombre} · ${f.zona}', AT.serif(19), w: 372, maxLines: 1),
      Positioned(left: px + pw - 188, top: 112, width: 164, height: 34, child: _Tabs(s.viajeTab, s.setViajeTab)),
      if (s.viajeTab == 0) ..._forja(s, f) else ..._despiece(f),
      ..._metricas(f),
      if (!got)
        button(px + 24, 792, pw - 48, 'Forjar y guardar el ${f.nombre}', kind: BtnKind.accent, onTap: () {
          s.forjar();
          aviso(context, 'Fragmento ${f.nombre} guardado · ${s.recolectados.length}/3');
        })
      else
        button(px + 24, 792, pw - 48, 'Siguiente punto →', onTap: s.siguienteEtapa, icon: Icons.check_circle),
    ]);
  }

  List<Widget> _forja(AsmodeoState s, Fragmento f) {
    final got = s.recolectados.contains(f.id);
    return [
      txt(px + 24, 214, 'El radar del guardián se forja como cristal', AT.sans(13, color: AC.mute)),
      Positioned(
        left: px + 24,
        top: 228,
        child: Row(children: [
          for (final g in fragmentos) ...[
            PillChip(
              g.guardianCorto,
              active: g.id == f.id,
              color: g.color,
              dot: g.color,
              onTap: g.id == f.id ? null : () => setState(() => comparar = comparar == g.id ? null : g.id),
            ),
            const SizedBox(width: 6),
          ],
        ]),
      ),
      if (comparar != null)
        txt(px + 24, 278, 'Comparando con: ${fragPorId(comparar!).guardian}',
            AT.sans(11, color: fragPorId(comparar!).color, weight: FontWeight.w600)),
      Positioned.fill(
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            key: ValueKey('${f.id}-$got'),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: got ? 900 : 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => CustomPaint(painter: _RadarForja(f, comparar, t, got)),
          ),
        ),
      ),
      marginNote(px + 262, 600, notasAsmodeo[f.id]!.replaceFirst('. ', '.\n'), 17, rot: -3, w: 150),
    ];
  }

  List<Widget> _despiece(Fragmento f) {
    const offs = [36.0, 186.0, 334.0, 404.0];
    const labs = ['Punta piramidal', 'Cuerpo hexagonal', 'Anillo-engranaje', 'Base facetada'];
    const top = 206.0, k = .88;
    return [
      Positioned.fill(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(f.id),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (context, t, _) {
            double y(double o) => top + o * k * (.55 + .45 * t);
            return Stack(children: [
              CanvasPaint((c) {
                c.save();
                c.translate(px + 150, top);
                c.scale(k);
                c.translate(-(px + 150), -top);
                paintExploded(c, px + 150, top, f, t: t);
                c.restore();
              }),
              for (var i = 0; i < 4; i++) ...[
                Positioned(left: px + 200, top: y(offs[i]), width: 36, height: 1, child: const ColoredBox(color: AC.faint)),
                Positioned(
                  left: px + 237,
                  top: y(offs[i]) - 11,
                  width: 22,
                  height: 22,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AC.paper, shape: BoxShape.circle, border: Border.all(color: f.color, width: 1.4)),
                    child: Text('${i + 1}', style: AT.sans(11, color: f.color, weight: FontWeight.w700)),
                  ),
                ),
                txt(px + 266, y(offs[i]) + 5, labs[i], AT.sans(13, weight: FontWeight.w600)),
              ],
              txt(px + 236, y(232) + 4, 'vena de energía', AT.sans(11, color: AC.viol, weight: FontWeight.w600)),
            ]);
          },
        ),
      ),
      marginNote(px + 270, 330, 'Ni un solo\nconjuro. Física.', 20, rot: -3, w: 140),
    ];
  }

  List<Widget> _metricas(Fragmento f) {
    const y0 = 668.0;
    final idx = fragmentos.indexOf(f);
    final (dano, pct) = danoDominante[f.id]!;
    final desg = desgastePorEtapa[widget.etapa];
    return [
      Positioned(left: px + 24, top: y0, width: pw - 48, height: 1, child: const ColoredBox(color: AC.line)),
      txt(px + 24, y0 + 30, 'Extracción', AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
      txt(px + 24, y0 + 58, '${horasExtraccion[f.id]} h', AT.serif(18)),
      txt(px + 24, y0 + 78, '${idx + 1}º bioma', AT.sans(11, color: AC.mute)),
      txt(px + 150, y0 + 30, 'Daño dominante', AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
      txt(px + 150, y0 + 58, dano, AT.serif(18)),
      txt(px + 150, y0 + 78, '$pct % del total', AT.sans(11, color: AC.mute)),
      txt(px + 290, y0 + 30, 'Desgaste', AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
      txt(px + 290, y0 + 58, '$desg %', AT.serif(18, color: AC.carm)),
      Positioned(left: px + 290, top: y0 + 70, width: 100, height: 8, child: ProgressBar(desg / 100)),
    ];
  }

  Widget _panelSinFragmento(BuildContext context, AsmodeoState s, int etapa) {
    final inicio = etapa == 0;
    final listo = s.recolectados.length == 3;
    return Stack(children: [
      eyebrow(px + 24, 136, inicio ? 'Punto de partida' : 'Destino final'),
      txt(px + 24, 174, inicio ? 'Midgard · inicio' : 'Volcán · la fragua', AT.serif(22)),
      txt(
          px + 24,
          214,
          inicio
              ? 'Asmodeo sale con el plano, una mochila de herramientas y ninguna fe en la magia. Mueve la línea progresiva para seguir su ruta.'
              : 'Un volcán inactivo: la fragua natural que el Motor necesitaba. Aquí se funden los tres fragmentos.',
          AT.sans(14, color: AC.ink2, height: 1.5),
          w: pw - 48),
      txt(px + 24, 320, 'Desgaste del Motor durante el viaje', AT.sans(13, weight: FontWeight.w700)),
      Positioned(left: px + 16, top: 336, width: pw - 40, height: 220, child: DesgasteChart(marca: etapa)),
      for (final (i, f) in fragmentos.indexed) ...[
        Positioned(
          left: px + 24 + i * 124.0,
          top: 588,
          width: 116,
          height: 64,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            decoration: BoxDecoration(
              color: AC.parch2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AC.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                FragBadge(f, r: 8, got: s.recolectados.contains(f.id)),
                const SizedBox(width: 6),
                Text(f.zona, style: AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              Text('${horasExtraccion[f.id]} h', style: AT.serif(17)),
            ]),
          ),
        ),
      ],
      txt(px + 24, 690, 'Extracción total: 60 h', AT.sans(12, color: AC.mute, weight: FontWeight.w600)),
      marginNote(px + 230, 726, inicio ? '60 horas.\nCero hechizos.' : (listo ? 'Hora de\nforjar.' : 'Me falta\nalgo...'), 20,
          rot: -3, w: 160),
      if (inicio)
        button(px + 24, 792, pw - 48, 'Partir hacia las Llanuras →', kind: BtnKind.accent, onTap: s.siguienteEtapa)
      else
        button(px + 24, 792, pw - 48, listo ? 'Ir a El Motor →' : 'Faltan fragmentos',
            kind: listo ? BtnKind.accent : BtnKind.disabled, onTap: listo ? () => s.ir(Pantalla.motor) : null),
    ]);
  }
}

class _Tabs extends StatelessWidget {
  final int active;
  final void Function(int) onChange;
  const _Tabs(this.active, this.onChange);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AC.parch2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AC.line),
      ),
      child: Row(children: [
        for (final (i, t) in const ['Forja', 'Despiece'].indexed)
          Expanded(
            child: Tap(
              onTap: () => onChange(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: i == active ? AC.ink : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                child: Text(t, style: AT.sans(13, color: i == active ? AC.paper : AC.ink2, weight: FontWeight.w600)),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Radar del guardián con extrusión de cristal (Forja).
class _RadarForja extends CustomPainter {
  final Fragmento f;
  final String? comparar;
  final double t;
  final bool got;
  _RadarForja(this.f, this.comparar, this.t, this.got);

  @override
  void paint(Canvas c, Size size) {
    const rc = Offset(980 + 190, 432);
    const rr = 102.0;
    radarGrid(c, rc, rr, AC.line);
    final vals = radarGuardian[f.id]!;
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final e = Offset(rc.dx + (rr + 58) * math.cos(a), rc.dy + (rr + 26) * math.sin(a));
      drawText(c, ejesRadar[i], e + const Offset(0, -3), AT.sans(11, color: AC.mute, weight: FontWeight.w600), align: TextAlign.center);
      final v = vals[i].round();
      drawText(c, '$v', e + const Offset(0, 12), AT.sans(12, color: v > 80 ? f.color : AC.ink, weight: FontWeight.w700),
          align: TextAlign.center);
    }
    for (final g in fragmentos.where((g) => g.id != f.id)) {
      final p = polyPath(radarPts(rc, rr, radarGuardian[g.id]!));
      final on = comparar == g.id;
      if (on) c.drawPath(p, fillP(g.color, .12));
      c.drawPath(dashPath(p, 4, 4), strokeP(g.color, on ? 2 : 1.2, on ? .9 : .35));
    }
    final rp = radarPts(rc, rr, vals.map((v) => v * t).toList());
    final lift = (got ? 1.0 : .7) * t;
    final ext = rp.map((p) => p + Offset(20 * lift, -13 * lift)).toList();
    c.drawPath(polyPath(ext), fillP(f.colorClaro, .9));
    c.drawPath(polyPath(ext), strokeP(f.colorOscuro, 1.2));
    for (var i = 0; i < rp.length; i++) {
      c.drawLine(rp[i], ext[i], strokeP(f.colorOscuro, 1.1));
    }
    c.drawPath(polyPath(rp), fillP(f.color, .78));
    c.drawPath(polyPath(rp), strokeP(AC.ink, 2));
    c.drawLine(rp[0] + const Offset(4, 18), rp[1] + const Offset(-28, 8), strokeP(Colors.white, 2.4, .6));
    if (got) {
      drawText(c, '✓ FORJADO', rc + const Offset(0, 150), AT.sans(11, color: f.color, weight: FontWeight.w700, spacing: 1.4),
          align: TextAlign.center);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarForja o) => o.t != t || o.comparar != comparar || o.got != got;
}
