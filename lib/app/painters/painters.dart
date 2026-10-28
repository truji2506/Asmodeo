import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

// ───────────────────────── utilidades de dibujo ─────────────────────────

Paint fillP(Color c, [double op = 1]) => Paint()
  ..color = c.withValues(alpha: c.a * op)
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

Paint strokeP(Color c, double w, [double op = 1]) => Paint()
  ..color = c.withValues(alpha: c.a * op)
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

Path polyPath(List<Offset> pts, {bool close = true}) {
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final o in pts.skip(1)) {
    p.lineTo(o.dx, o.dy);
  }
  if (close) p.close();
  return p;
}

Path dashPath(Path src, double dash, double gap) {
  final out = Path();
  for (final m in src.computeMetrics()) {
    double d = 0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

void drawDashedLine(Canvas c, Offset a, Offset b, Paint p, {double dash = 4, double gap = 4}) {
  c.drawPath(dashPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy), dash, gap), p);
}

void drawDashedCircle(Canvas c, Offset center, double r, Paint p, {double dash = 3, double gap = 3}) {
  c.drawPath(dashPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)), dash, gap), p);
}

/// Texto centrado verticalmente en [at]; [align] decide el anclaje horizontal.
void drawText(Canvas c, String t, Offset at, TextStyle s, {TextAlign align = TextAlign.left}) {
  final tp = TextPainter(text: TextSpan(text: t, style: s), textDirection: TextDirection.ltr, textAlign: align)..layout();
  double dx = at.dx;
  if (align == TextAlign.center) dx -= tp.width / 2;
  if (align == TextAlign.right) dx -= tp.width;
  tp.paint(c, Offset(dx, at.dy - tp.height / 2));
}

List<Offset> shapePts(FragShape k, Offset c, double r) {
  switch (k) {
    case FragShape.tri:
      return [Offset(c.dx, c.dy - r), Offset(c.dx + r * .92, c.dy + r * .62), Offset(c.dx - r * .92, c.dy + r * .62)];
    case FragShape.sq:
      final q = r * .78;
      return [Offset(c.dx - q, c.dy - q), Offset(c.dx + q, c.dy - q), Offset(c.dx + q, c.dy + q), Offset(c.dx - q, c.dy + q)];
    case FragShape.hex:
      return List.generate(6, (i) {
        final a = math.pi / 3 * i + math.pi / 6;
        return Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      });
  }
}

Offset dirDeg(double deg) => Offset(math.cos(deg * math.pi / 180), math.sin(deg * math.pi / 180));

double _jit(math.Random r, double a) => (r.nextDouble() * 2 - 1) * a;

/// Trazo "a mano": dos pasadas con leve temblor, como la infografía.
void sketch(Canvas c, List<Offset> pts, Color col, double sw, math.Random rnd, {double a = .7, bool close = true}) {
  for (var i = 0; i < 2; i++) {
    final q = pts.map((o) => o + Offset(_jit(rnd, a), _jit(rnd, a))).toList();
    c.drawPath(polyPath(q, close: close), strokeP(col, sw * (.8 + rnd.nextDouble() * .25), .85));
  }
}

Path gearPath(Offset c, double r, {int teeth = 16, double depth = .16}) {
  final n = teeth * 4;
  final pts = <Offset>[];
  for (var i = 0; i < n; i++) {
    final a = i / n * 2 * math.pi;
    final rr = (i % 4 == 1 || i % 4 == 2) ? r : r * (1 - depth);
    pts.add(Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a)));
  }
  return polyPath(pts);
}

List<Offset> radarPts(Offset c, double r, List<double> vals) {
  final n = vals.length;
  return List.generate(n, (i) {
    final a = -math.pi / 2 + i * 2 * math.pi / n;
    return Offset(c.dx + r * vals[i] / 100 * math.cos(a), c.dy + r * vals[i] / 100 * math.sin(a));
  });
}

void radarGrid(Canvas c, Offset center, double r, Color line) {
  for (final k in [1.0, .75, .5, .25]) {
    c.drawPath(polyPath(radarPts(center, r * k, List.filled(5, 100))), strokeP(line, 1));
  }
  for (final p in radarPts(center, r, List.filled(5, 100))) {
    c.drawLine(center, p, strokeP(line, 1));
  }
}

void donut(Canvas c, Offset center, double r, List<num> vals, List<Color> cols,
    {double sw = 18, double gap = .04, Color track = const Color(0xFFE8DDC6), double progress = 1}) {
  c.drawCircle(center, r, strokeP(track, sw));
  final tot = vals.fold<num>(0, (a, b) => a + b);
  var a = -math.pi / 2;
  final rect = Rect.fromCircle(center: center, radius: r);
  for (var i = 0; i < vals.length; i++) {
    final sweep = 2 * math.pi * vals[i] / tot * progress;
    c.drawArc(rect, a + gap / 2, math.max(0, sweep - gap), false, strokeP(cols[i], sw)..strokeCap = StrokeCap.butt);
    a += sweep;
  }
}

// ───────────────────────── cristal y motor ─────────────────────────

enum Cristal { vacio, puesto, rayosX }

/// Prisma hexagonal con punta, apuntando a [angDeg] desde [base].
void paintCrystal(Canvas c, Offset base, double length, double width, double angDeg, Color col, Color colD,
    {bool ghost = false, bool xray = false, int seed = 1}) {
  final u = dirDeg(angDeg);
  final p = Offset(-u.dy, u.dx);
  Offset pt(double t, double s) => base + u * t + p * s;
  final tip = length, body = length * .74, b = length * .1, hw = width / 2;
  final faces = <(List<Offset>, double)>[
    ([pt(b, -hw), pt(body, -hw), pt(body, -hw * .35), pt(b, -hw * .35)], .55),
    ([pt(b, -hw * .35), pt(body, -hw * .35), pt(body, hw * .35), pt(b, hw * .35)], .28),
    ([pt(b, hw * .35), pt(body, hw * .35), pt(body, hw), pt(b, hw)], .75),
    ([pt(body, -hw), pt(tip, 0), pt(body, -hw * .35)], .45),
    ([pt(body, -hw * .35), pt(tip, 0), pt(body, hw * .35)], .2),
    ([pt(body, hw * .35), pt(tip, 0), pt(body, hw)], .65),
    ([pt(b, -hw), pt(0, 0), pt(b, -hw * .35)], .5),
    ([pt(b, -hw * .35), pt(0, 0), pt(b, hw * .35)], .25),
    ([pt(b, hw * .35), pt(0, 0), pt(b, hw)], .7),
  ];
  final rnd = math.Random(seed);
  for (final (pts, o) in faces) {
    if (ghost) {
      c.drawPath(dashPath(polyPath(pts), 5, 5), strokeP(AC.faint, 1.2, .8));
    } else {
      c.drawPath(polyPath(pts), fillP(col, o * (xray ? .55 : 1)));
      sketch(c, pts, xray ? colD : AC.ink, xray ? 1.1 : 1.3, rnd);
    }
  }
  if (!ghost) {
    c.drawLine(pt(b + 8, -hw * .1), pt(body - 10, -hw * .1), strokeP(Colors.white, 2.4, .7));
    if (xray) c.drawLine(pt(b, 0), pt(tip - 6, 0), strokeP(AC.viol, 2.2, .9));
  }
}

/// El Motor: núcleo con tres cristales. [pulse] 0..1 anima el brillo.
class MotorPainter extends CustomPainter {
  final Offset center;
  final double k;
  final Map<String, Cristal> estado;
  final bool dark;
  final bool glow;
  final double pulse;
  MotorPainter({required this.center, required this.k, required this.estado, this.dark = false, this.glow = true, this.pulse = 0});

  @override
  void paint(Canvas c, Size size) {
    final complete = estado.values.every((v) => v != Cristal.vacio);
    final cx = center;
    if (glow) {
      final col = complete ? const Color(0xFF9B78C2) : const Color(0xFFE08A3A);
      final r = 300 * k * (1 + .05 * pulse);
      c.drawCircle(
        cx,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            col.withValues(alpha: complete ? .55 : .22),
            col.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: cx, radius: r)),
      );
    }
    final ringCol = complete ? AC.viol : AC.faint;
    c.drawCircle(cx, 250 * k, fillP(ringCol, dark ? .18 : .07));
    drawDashedCircle(c, cx, 250 * k, strokeP(ringCol, 1, .6), dash: 2, gap: 6);
    final rc = 62 * k;
    var seed = 3;
    for (final f in fragmentos) {
      final st = estado[f.id] ?? Cristal.vacio;
      final base = cx + dirDeg(f.angulo) * (rc - 8 * k);
      paintCrystal(c, base, 175 * k, 56 * k, f.angulo, f.color, f.colorOscuro,
          ghost: st == Cristal.vacio, xray: st == Cristal.rayosX, seed: seed++);
    }
    final ink = dark ? const Color(0xFFF3EADB) : AC.ink;
    for (var i = 0; i < 24; i++) {
      final a = i / 24 * 2 * math.pi;
      final r1 = rc + 6 * k, r2 = rc + (i.isEven ? 16 : 11) * k;
      c.drawLine(cx + Offset(math.cos(a), math.sin(a)) * r1, cx + Offset(math.cos(a), math.sin(a)) * r2, strokeP(ink, 1.3));
    }
    c.drawCircle(cx, rc + 4 * k, strokeP(ink, 1.4));
    final coreRect = Rect.fromCircle(center: cx, radius: rc);
    c.drawCircle(
      cx,
      rc,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.2, -.24),
          radius: .65,
          colors: complete
              ? const [Color(0xFFB597D6), Color(0xFF7A5A9A), Color(0xFF4E3866)]
              : const [Color(0xFFE9E0CF), Color(0xFFDCD0BA), Color(0xFFCFC2A8)],
          stops: const [0, .6, 1],
        ).createShader(coreRect),
    );
    c.drawCircle(cx, rc, strokeP(ink, 1.8));
    c.drawCircle(cx, rc * .45, strokeP(complete ? Colors.white : AC.faint, 1.2, .6));
    if (complete) {
      c.drawCircle(cx + Offset(-rc * .3, -rc * .32), rc * .14, fillP(Colors.white, .55));
      c.drawCircle(cx, rc * (.55 + .12 * pulse), strokeP(AC.lilac, 1.4, .5 * (1 - pulse)));
    }
  }

  @override
  bool shouldRepaint(covariant MotorPainter o) => true;
}

// ───────────────────────── mapa ─────────────────────────

/// Pergamino desenrollado con rodillo a la izquierda.
void paintScroll(Canvas c, Rect r) {
  final x = r.left, y = r.top, w = r.width, h = r.height;
  c.drawRRect(RRect.fromLTRBR(x + 30, y + 6, x + w, y + h + 6, const Radius.circular(6)), fillP(const Color(0xFF3A2C1E), .10));
  final sheet = RRect.fromLTRBR(x + 30, y, x + w, y + h, const Radius.circular(4));
  c.drawRRect(sheet, fillP(const Color(0xFFF4EBD6)));
  c.drawRRect(sheet, strokeP(AC.ink2, 1.2));
  final grid = strokeP(AC.line, .7, .6);
  for (var i = 1; i < 8; i++) {
    final gx = x + 30 + i * (w - 30) / 8;
    c.drawLine(Offset(gx, y + 2), Offset(gx, y + h - 2), grid);
  }
  for (var i = 1; i < 6; i++) {
    c.drawLine(Offset(x + 32, y + i * h / 6), Offset(x + w - 2, y + i * h / 6), grid);
  }
  final roller = RRect.fromLTRBR(x, y - 12, x + 44, y + h + 12, const Radius.circular(22));
  c.drawRRect(roller, fillP(const Color(0xFFC9AE82)));
  c.drawRRect(roller, strokeP(AC.ink2, 1.4));
  c.drawRRect(RRect.fromLTRBR(x + 10, y - 4, x + 18, y + h + 4, const Radius.circular(4)), fillP(Colors.white, .25));
  c.drawLine(Offset(x + 34, y - 8), Offset(x + 34, y + h + 8), strokeP(AC.ink2, 1, .4));
}

/// Silueta de Midgard (mismo algoritmo y semilla que el wireframe).
/// Posición relativa (0..1 dentro del rectángulo del continente) de cada lugar:
/// Llanuras, Pantanos, Tundras y Volcán. Mesa y Viaje usan las mismas.
/// El 5º territorio es Midgard (punto de partida), separado de los Pantanos por una frontera.
const sitiosRel = [Offset(.222, .769), Offset(.463, .462), Offset(.722, .769), Offset(.722, .346), Offset(.235, .214)];
const tintesRegion = [Color(0xFFC3E3CD), Color(0xFFF2C4BC), Color(0xFFCFE8EC), Color(0xFFF1D2AE), Color(0xFFEADFC6)];

/// Frontera Midgard | Pantanos (relativa al continente).
const _fronteraMidgard = (Offset(.239, .504), Offset(.526, .20));

Offset sitioEn(Rect r, int i) => Offset(r.left + sitiosRel[i].dx * r.width, r.top + sitiosRel[i].dy * r.height);

/// Recorta un polígono al semiplano más cercano a [a] que a [b] (bisectriz).
List<Offset> _clipHalf(List<Offset> poly, Offset a, Offset b) {
  double fn(Offset p) => 2 * (p.dx * (b.dx - a.dx) + p.dy * (b.dy - a.dy)) + (a.dx * a.dx + a.dy * a.dy) - (b.dx * b.dx + b.dy * b.dy);
  final out = <Offset>[];
  for (var i = 0; i < poly.length; i++) {
    final p = poly[i], q = poly[(i + 1) % poly.length];
    final fp = fn(p), fq = fn(q);
    if (fp <= 0) out.add(p);
    if ((fp <= 0) != (fq <= 0)) {
      final t = fp / (fp - fq);
      out.add(Offset(p.dx + (q.dx - p.dx) * t, p.dy + (q.dy - p.dy) * t));
    }
  }
  return out;
}

/// Recorta un polígono al lado de la recta a→b donde está [lado].
List<Offset> _clipLado(List<Offset> poly, Offset a, Offset b, Offset lado) {
  double fn(Offset p) => (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
  final signo = fn(lado) >= 0 ? 1.0 : -1.0;
  final out = <Offset>[];
  for (var i = 0; i < poly.length; i++) {
    final p = poly[i], q = poly[(i + 1) % poly.length];
    final fp = fn(p) * signo, fq = fn(q) * signo;
    if (fp >= 0) out.add(p);
    if ((fp >= 0) != (fq >= 0)) {
      final t = fp / (fp - fq);
      out.add(Offset(p.dx + (q.dx - p.dx) * t, p.dy + (q.dy - p.dy) * t));
    }
  }
  return out;
}

/// Territorios de cada lugar dentro del rectángulo del continente:
/// 0 Llanuras, 1 Pantanos, 2 Tundras, 3 Volcán (Voronoi) y 4 Midgard (cortado de los Pantanos).
List<List<Offset>> regiones(Rect r) {
  final box = r.inflate(40);
  final sites = [for (var i = 0; i < 4; i++) sitioEn(r, i)];
  final regs = [
    for (var i = 0; i < sites.length; i++)
      sites.indexed.where((e) => e.$1 != i).fold<List<Offset>>(
        [box.topLeft, box.topRight, box.bottomRight, box.bottomLeft],
        (poly, e) => _clipHalf(poly, sites[i], e.$2),
      ),
  ];
  Offset abs(Offset rel) => Offset(r.left + rel.dx * r.width, r.top + rel.dy * r.height);
  final a = abs(_fronteraMidgard.$1), b = abs(_fronteraMidgard.$2);
  final pantanos = regs[1];
  regs[1] = _clipLado(pantanos, a, b, sites[1]);
  regs.add(_clipLado(pantanos, a, b, sitioEn(r, 4)));
  return regs;
}

/// Frontera "a mano": subdivide cada borde y lo ondula según la posición,
/// así dos territorios vecinos comparten exactamente la misma línea.
List<Offset> _ondular(List<Offset> poly) {
  final out = <Offset>[];
  for (var i = 0; i < poly.length; i++) {
    final p = poly[i], q = poly[(i + 1) % poly.length];
    final n = math.max(1, ((q - p).distance / 12).round());
    for (var k = 0; k < n; k++) {
      final o = Offset.lerp(p, q, k / n)!;
      out.add(k == 0 ? o : o + Offset(math.sin(o.dx * .21 + o.dy * .17) * 2.6, math.cos(o.dx * .19 - o.dy * .23) * 2.6));
    }
  }
  return out;
}

/// Reparte elementos dentro de un territorio sin tapar el punto ni su etiqueta.
class _Esparcidor {
  final Path area, continente;
  final Rect zona;
  final Offset site;
  final double k;
  _Esparcidor(this.area, this.continente, this.zona, this.site, this.k);

  List<Offset> puntos(math.Random rnd, int n, {double sep = 18, double margen = 8}) {
    final out = <Offset>[];
    var intentos = 0;
    while (out.length < n && intentos < n * 60) {
      intentos++;
      final o = Offset(zona.left + rnd.nextDouble() * zona.width, zona.top + rnd.nextDouble() * zona.height);
      if (!area.contains(o) || !continente.contains(o)) continue;
      // margen hacia el borde del continente y del territorio
      var cerca = false;
      for (final d in const [Offset(1, 0), Offset(-1, 0), Offset(0, 1), Offset(0, -1)]) {
        final q = o + d * margen * k;
        if (!area.contains(q) || !continente.contains(q)) cerca = true;
      }
      if (cerca) continue;
      // deja libre el punto del lugar y su etiqueta
      if ((o - site).distance < 40 * k) continue;
      if ((o.dx - site.dx).abs() < 52 * k && o.dy > site.dy && o.dy < site.dy + 64 * k) continue;
      if (out.any((q) => (q - o).distance < sep * k)) continue;
      out.add(o);
    }
    return out;
  }
}

void _fondo(Canvas c, Rect zona, Offset site, double k, List<Color> cols) {
  c.drawRect(
    zona.inflate(4),
    Paint()
      ..shader = RadialGradient(colors: cols, stops: const [0, .6, 1]).createShader(Rect.fromCircle(center: site, radius: 170 * k)),
  );
}

/// Llanuras: colinas, árboles redondos, hierba y flores.
void _paintLlanurasZona(Canvas c, Rect zona, Offset site, double k, _Esparcidor e) {
  final rnd = math.Random(11);
  _fondo(c, zona, site, k, const [Color(0xFFB7DBC1), Color(0xFFC6E3CD), Color(0xFFD3EAD8)]);
  // colinas
  for (final o in e.puntos(rnd, 6, sep: 46, margen: 20)) {
    final w = (28 + rnd.nextDouble() * 22) * k;
    final hill = Path()
      ..moveTo(o.dx - w, o.dy)
      ..quadraticBezierTo(o.dx, o.dy - w * .55, o.dx + w, o.dy);
    c.drawPath(hill, fillP(const Color(0xFF9FCDAE), .55));
    c.drawPath(hill, strokeP(AC.ink2, 1, .55));
  }
  // hierba
  for (final o in e.puntos(rnd, 34, sep: 12, margen: 6)) {
    for (var j = -1; j <= 1; j++) {
      c.drawLine(o + Offset(j * 2.2 * k, 0), o + Offset(j * 3.6 * k, -5.5 * k - rnd.nextDouble() * 2 * k), strokeP(const Color(0xFF3F6B4C), .9, .7));
    }
  }
  // árboles
  for (final o in e.puntos(rnd, 7, sep: 26, margen: 12)) {
    final h = (12 + rnd.nextDouble() * 5) * k;
    c.drawOval(Rect.fromCenter(center: o + Offset(h * .3, 1), width: h * 1.1, height: h * .25), fillP(AC.ink, .15));
    c.drawLine(o, o - Offset(0, h * .55), strokeP(AC.ink, 1.6));
    final copa = o - Offset(0, h * .85);
    c.drawCircle(copa, h * .42, fillP(const Color(0xFF7DB592)));
    c.drawCircle(copa + Offset(h * .14, h * .1), h * .26, fillP(const Color(0xFF5E9C74), .7));
    c.drawCircle(copa, h * .42, strokeP(AC.ink, 1.1));
  }
  // flores
  const flores = [Color(0xFFC98A3A), Color(0xFFFBF6EA), AC.carm, Color(0xFFF2C4BC)];
  for (final o in e.puntos(rnd, 26, sep: 9, margen: 5)) {
    c.drawCircle(o, 1.4 * k, fillP(flores[rnd.nextInt(flores.length)]));
  }
}

/// Pantanos: charcas con ondas, juncos, árboles muertos, burbujas y niebla.
void _paintPantanosZona(Canvas c, Rect zona, Offset site, double k, _Esparcidor e) {
  final rnd = math.Random(22);
  _fondo(c, zona, site, k, const [Color(0xFFE2C2B4), Color(0xFFEBCDC1), Color(0xFFF0D5CB)]);
  // charcas
  for (final o in e.puntos(rnd, 6, sep: 54, margen: 22)) {
    final w = (16 + rnd.nextDouble() * 14) * k, h = (6 + rnd.nextDouble() * 4) * k;
    final charca = Rect.fromCenter(center: o, width: w * 2, height: h * 2);
    c.drawOval(charca, fillP(const Color(0xFF9FAE93), .9));
    c.drawOval(charca, strokeP(AC.ink2, 1, .8));
    for (var j = 0; j < 2; j++) {
      final y = o.dy - h * .3 + j * h * .6;
      c.drawLine(Offset(o.dx - w * .5 + j * 4 * k, y), Offset(o.dx + w * .3 + j * 4 * k, y), strokeP(const Color(0xFFE8EEDF), 1, .8));
    }
  }
  // árboles muertos
  for (final o in e.puntos(rnd, 4, sep: 50, margen: 14)) {
    final h = (18 + rnd.nextDouble() * 8) * k;
    c.drawLine(o, o - Offset(1.5 * k, h), strokeP(AC.ink, 1.6));
    for (var j = 0; j < 3; j++) {
      final y = o.dy - h * (.45 + j * .17);
      final dir = j.isEven ? 1.0 : -1.0;
      c.drawLine(Offset(o.dx - k, y), Offset(o.dx + dir * h * .32, y - h * .14), strokeP(AC.ink, 1));
    }
  }
  // juncos con espadaña
  for (final o in e.puntos(rnd, 12, sep: 18, margen: 7)) {
    for (var j = 0; j < 3; j++) {
      final top = o + Offset((j - 1) * 2.4 * k + (rnd.nextDouble() - .5) * 2 * k, -(9 + rnd.nextDouble() * 4) * k);
      c.drawLine(o + Offset((j - 1) * 1.6 * k, 0), top, strokeP(const Color(0xFF4A3B2E), .9, .85));
      if (j == 1) c.drawOval(Rect.fromCenter(center: top + Offset(0, 2 * k), width: 2.6 * k, height: 5.5 * k), fillP(const Color(0xFF6B4A34)));
    }
  }
  // burbujas
  for (final o in e.puntos(rnd, 16, sep: 10, margen: 5)) {
    c.drawCircle(o, (1 + rnd.nextDouble() * 1.6) * k, strokeP(AC.ink2, .8, .55));
  }
  // niebla
  for (final o in e.puntos(rnd, 3, sep: 60, margen: 10)) {
    c.drawOval(Rect.fromCenter(center: o, width: 70 * k, height: 8 * k), fillP(const Color(0xFFFBF6EA), .5));
  }
}

/// Tundras: picos nevados, bloques de hielo, grietas y nieve.
void _paintTundrasZona(Canvas c, Rect zona, Offset site, double k, _Esparcidor e) {
  final rnd = math.Random(33);
  _fondo(c, zona, site, k, const [Color(0xFFC4E2E7), Color(0xFFD6ECEF), Color(0xFFE6F3F4)]);
  // picos nevados
  for (final o in e.puntos(rnd, 5, sep: 46, margen: 22)) {
    final w = (16 + rnd.nextDouble() * 8) * k, h = (20 + rnd.nextDouble() * 8) * k;
    final pico = polyPath([o + Offset(-w, 0), o + Offset(0, -h), o + Offset(w, 0)]);
    c.drawPath(pico, fillP(const Color(0xFF9FCCD2)));
    c.drawPath(polyPath([o + Offset(0, -h), o + Offset(w, 0), o + Offset(w * .15, 0)]), fillP(const Color(0xFF6FA8B0), .6));
    final nieve = polyPath([
      o + Offset(-w * .36, -h * .64), o + Offset(0, -h), o + Offset(w * .36, -h * .64),
      o + Offset(w * .14, -h * .56), o + Offset(0, -h * .66), o + Offset(-w * .16, -h * .56),
    ]);
    c.drawPath(nieve, fillP(Colors.white));
    c.drawPath(pico, strokeP(AC.ink2, 1.1));
  }
  // bloques de hielo
  for (final o in e.puntos(rnd, 5, sep: 34, margen: 14)) {
    final w = (10 + rnd.nextDouble() * 6) * k, h = 7 * k, d = 4 * k;
    final frente = Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h);
    c.drawRect(frente, fillP(const Color(0xFFD6EEF0)));
    c.drawPath(polyPath([frente.topLeft, frente.topLeft + Offset(d, -d), frente.topRight + Offset(d, -d), frente.topRight]), fillP(Colors.white));
    c.drawPath(polyPath([frente.topRight, frente.topRight + Offset(d, -d), frente.bottomRight + Offset(d, -d), frente.bottomRight]), fillP(const Color(0xFF9FCCD2)));
    c.drawRect(frente, strokeP(AC.ink2, .9));
  }
  // grietas
  for (final o in e.puntos(rnd, 5, sep: 30, margen: 10)) {
    final g = Path()..moveTo(o.dx, o.dy);
    var q = o;
    for (var j = 0; j < 4; j++) {
      q += Offset((3 + rnd.nextDouble() * 4) * k, (rnd.nextDouble() - .5) * 6 * k);
      g.lineTo(q.dx, q.dy);
    }
    c.drawPath(g, strokeP(const Color(0xFF3B8D93), .9, .6));
  }
  // nieve
  for (final o in e.puntos(rnd, 70, sep: 6, margen: 3)) {
    c.drawCircle(o, (.8 + rnd.nextDouble() * .9) * k, fillP(Colors.white, .95));
  }
}

/// Midgard: el pueblo de partida — casas, campos arados y un camino.
void _paintMidgardZona(Canvas c, Rect zona, Offset site, double k, _Esparcidor e) {
  final rnd = math.Random(55);
  _fondo(c, zona, site, k, const [Color(0xFFE6D6B6), Color(0xFFEADFC6), Color(0xFFEFE6D0)]);
  // campos arados
  for (final o in e.puntos(rnd, 4, sep: 40, margen: 16)) {
    final w = (14 + rnd.nextDouble() * 8) * k, h = (8 + rnd.nextDouble() * 4) * k;
    final campo = polyPath([o + Offset(-w, 0), o + Offset(-w * .7, -h), o + Offset(w, -h), o + Offset(w * .7, 0)]);
    c.drawPath(campo, fillP(const Color(0xFFD8C29A)));
    c.save();
    c.clipPath(campo);
    for (var x = -w; x < w; x += 3.2 * k) {
      c.drawLine(o + Offset(x, 0), o + Offset(x + h * .5, -h), strokeP(const Color(0xFF8A6A45), .8, .6));
    }
    c.restore();
    c.drawPath(campo, strokeP(AC.ink2, .9));
  }
  // casas con techo carmesí
  for (final o in e.puntos(rnd, 6, sep: 22, margen: 10)) {
    final w = (7 + rnd.nextDouble() * 3) * k, h = 6 * k;
    final muro = Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h);
    c.drawRect(muro, fillP(const Color(0xFFFBF6EA)));
    final techo = polyPath([muro.topLeft + Offset(-1.5 * k, 0), Offset(o.dx, o.dy - h - 5.5 * k), muro.topRight + Offset(1.5 * k, 0)]);
    c.drawPath(techo, fillP(AC.carmD));
    c.drawPath(techo, strokeP(AC.ink, .9));
    c.drawRect(muro, strokeP(AC.ink, .9));
    c.drawRect(Rect.fromLTWH(o.dx - 1 * k, o.dy - 3.2 * k, 2 * k, 3.2 * k), fillP(AC.ink2));
  }
  // arbustos
  for (final o in e.puntos(rnd, 10, sep: 12, margen: 6)) {
    c.drawCircle(o, 2.4 * k, fillP(const Color(0xFF9FCDAE)));
    c.drawCircle(o, 2.4 * k, strokeP(AC.ink2, .7, .7));
  }
}

/// Ilustración del territorio volcánico: suelo de ceniza, cono con cráter
/// incandescente, ríos de lava, humo y rocas. [k] escala según el mapa.
void _paintVolcanZona(Canvas c, Rect zona, Offset site, double k) {
  final rnd = math.Random(41);
  // suelo de ceniza más oscuro hacia el cono
  c.drawRect(
    zona,
    Paint()
      ..shader = RadialGradient(colors: const [Color(0xFFD9A77A), Color(0xFFE6C29C), Color(0xFFEFD3B0)], stops: const [0, .55, 1])
          .createShader(Rect.fromCircle(center: site, radius: 150 * k)),
  );
  // vetas de lava enfriada en el suelo
  for (var i = 0; i < 7; i++) {
    final a = rnd.nextDouble() * math.pi * 2;
    final o = site + Offset(math.cos(a), math.sin(a) * .6) * (70 + rnd.nextDouble() * 60) * k;
    final p = Path()..moveTo(o.dx, o.dy);
    var q = o;
    for (var j = 0; j < 4; j++) {
      q += Offset((rnd.nextDouble() - .5) * 22 * k, (rnd.nextDouble() - .2) * 14 * k);
      p.lineTo(q.dx, q.dy);
    }
    c.drawPath(p, strokeP(const Color(0xFF8A5A3A), 1, .45));
  }
  // ceniza punteada
  for (var i = 0; i < 160; i++) {
    final o = Offset(zona.left + rnd.nextDouble() * zona.width, zona.top + rnd.nextDouble() * zona.height);
    c.drawCircle(o, .6 + rnd.nextDouble() * .9, fillP(const Color(0xFF5A4636), .25 + rnd.nextDouble() * .25));
  }
  // rocas
  for (var i = 0; i < 9; i++) {
    final o = Offset(zona.left + rnd.nextDouble() * zona.width, zona.top + rnd.nextDouble() * zona.height);
    if ((o - site).distance < 80 * k) continue;
    final rr = (4 + rnd.nextDouble() * 5) * k;
    final roca = polyPath([o + Offset(-rr, rr * .5), o + Offset(-rr * .4, -rr * .6), o + Offset(rr * .5, -rr * .7), o + Offset(rr, rr * .5)]);
    c.drawPath(roca, fillP(const Color(0xFF8A6A45)));
    c.drawPath(roca, strokeP(AC.ink2, .9));
  }
  // cono del volcán (el cráter queda sobre el punto del lugar)
  final top = site.dy - 46 * k, base = site.dy + 58 * k;
  final cx = site.dx;
  final cono = polyPath([
    Offset(cx - 92 * k, base),
    Offset(cx - 58 * k, site.dy + 8 * k),
    Offset(cx - 34 * k, site.dy - 24 * k),
    Offset(cx - 14 * k, top),
    Offset(cx + 15 * k, top + 2 * k),
    Offset(cx + 30 * k, site.dy - 20 * k),
    Offset(cx + 62 * k, site.dy + 14 * k),
    Offset(cx + 96 * k, base),
  ]);
  c.drawShadow(cono, const Color(0xFF3A2A18), 4, false);
  c.drawPath(
    cono,
    Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFC9A27A), Color(0xFFA88763)])
          .createShader(Rect.fromLTRB(cx - 92 * k, top, cx + 96 * k, base)),
  );
  // ladera en sombra con rayado
  final sombra = polyPath([
    Offset(cx + 2 * k, top + 1 * k),
    Offset(cx + 15 * k, top + 2 * k),
    Offset(cx + 30 * k, site.dy - 20 * k),
    Offset(cx + 62 * k, site.dy + 14 * k),
    Offset(cx + 96 * k, base),
    Offset(cx + 20 * k, base),
  ]);
  c.drawPath(sombra, fillP(const Color(0xFF6B4A34), .3));
  c.save();
  c.clipPath(sombra);
  for (var x = cx - 40 * k; x < cx + 120 * k; x += 6 * k) {
    c.drawLine(Offset(x, top), Offset(x - 40 * k, base), strokeP(AC.ink, .7, .3));
  }
  c.restore();
  c.drawPath(cono, strokeP(AC.ink, 1.6));
  // cráter incandescente
  final crater = Offset(cx, top + 2 * k);
  c.drawCircle(
    crater,
    34 * k,
    Paint()
      ..shader = RadialGradient(colors: [const Color(0xFFF39C12).withValues(alpha: .7), const Color(0xFFF39C12).withValues(alpha: 0)])
          .createShader(Rect.fromCircle(center: crater, radius: 34 * k)),
  );
  final boca = Rect.fromCenter(center: crater, width: 30 * k, height: 7 * k);
  c.drawOval(boca, fillP(const Color(0xFFF6C46A)));
  c.drawOval(boca, strokeP(AC.ink, 1.2));
  // ríos de lava
  for (final dir in [-1.0, 1.0]) {
    final p = Path()
      ..moveTo(cx + dir * 6 * k, top + 4 * k)
      ..cubicTo(cx + dir * 12 * k, site.dy - 10 * k, cx + dir * 30 * k, site.dy + 18 * k, cx + dir * 44 * k, base - 4 * k);
    c.drawPath(p, strokeP(const Color(0xFFE08A3A), 6 * k, .35));
    c.drawPath(p, strokeP(AC.carm, 2.6 * k, .85));
    c.drawPath(p, strokeP(const Color(0xFFF6C46A), .9 * k, .95));
  }
  // humo
  for (final (dx, dy, rr) in [(2.0, -16.0, 11.0), (-6.0, -32.0, 13.0), (8.0, -48.0, 12.0), (20.0, -60.0, 9.0), (32.0, -68.0, 7.0)]) {
    final o = crater + Offset(dx, dy) * k;
    final nube = Rect.fromCenter(center: o, width: rr * 2.3 * k, height: rr * 1.6 * k);
    c.drawOval(nube, fillP(const Color(0xFFF1E6D2), .9));
    c.drawOval(nube, strokeP(AC.ink2, .9, .6));
  }
  // chispas
  for (var i = 0; i < 14; i++) {
    final o = crater + Offset((rnd.nextDouble() - .5) * 70 * k, -rnd.nextDouble() * 60 * k);
    c.drawCircle(o, (.8 + rnd.nextDouble()) * k, fillP(i.isEven ? const Color(0xFFF39C12) : AC.carm, .85));
  }
}

void paintContinent(Canvas c, Rect r) {
  final rnd = math.Random(9);
  const n = 70;
  final pts = <Offset>[];
  for (var i = 0; i < n; i++) {
    final a = i / n * 2 * math.pi;
    final rx = r.width / 2 * (0.86 + 0.09 * math.sin(3 * a + .6) + 0.05 * math.sin(7 * a) + _jit(rnd, .015));
    final ry = r.height / 2 * (0.80 + 0.14 * math.cos(2 * a + .3) + 0.05 * math.sin(5 * a) + _jit(rnd, .02));
    pts.add(Offset(r.center.dx + rx * math.cos(a), r.center.dy + ry * math.sin(a)));
  }
  final p = polyPath(pts);
  c.drawPath(p, fillP(const Color(0xFFE9DEC4)));
  // territorios: cada lugar con su color y fronteras punteadas
  c.save();
  c.clipPath(p);
  final regs = regiones(r).map(_ondular).toList();
  for (var i = 0; i < regs.length; i++) {
    c.drawPath(polyPath(regs[i]), fillP(tintesRegion[i], .75));
  }
  // cada territorio con su arte: llanura, pantano, tundra y volcán
  final k = r.width / 540;
  for (var i = 0; i < regs.length; i++) {
    final area = polyPath(regs[i]);
    final zona = area.getBounds();
    final site = sitioEn(r, i);
    c.save();
    c.clipPath(area);
    final sitios = _Esparcidor(area, p, zona, site, k);
    switch (i) {
      case 0:
        _paintLlanurasZona(c, zona, site, k, sitios);
      case 1:
        _paintPantanosZona(c, zona, site, k, sitios);
      case 2:
        _paintTundrasZona(c, zona, site, k, sitios);
      case 3:
        _paintVolcanZona(c, zona, site, k);
      default:
        _paintMidgardZona(c, zona, site, k, sitios);
    }
    c.restore();
  }
  for (final reg in regs) {
    final rp = polyPath(reg);
    c.drawPath(rp, strokeP(const Color(0xFFFBF6EA), 4, .7));
    c.drawPath(dashPath(rp, 7, 5), strokeP(AC.ink2, 1.3, .75));
  }
  c.restore();
  c.drawPath(p, strokeP(AC.ink2, 1.6));
  c.drawPath(dashPath(p, 1, 5), strokeP(AC.ink2, .8, .35));
}

void paintVolcano(Canvas c, Offset o, {double k = 1}) {
  final p = Path()
    ..moveTo(o.dx - 26 * k, o.dy + 18 * k)
    ..relativeLineTo(18 * k, -34 * k)
    ..relativeLineTo(16 * k, 0)
    ..relativeLineTo(18 * k, 34 * k)
    ..close();
  c.drawPath(p, fillP(const Color(0xFFE6CBA8)));
  c.drawPath(p, strokeP(AC.ink2, 1.4));
  final smoke = Path()
    ..moveTo(o.dx - 6 * k, o.dy - 18 * k)
    ..relativeQuadraticBezierTo(-6 * k, -10 * k, 2 * k, -18 * k);
  c.drawPath(smoke, strokeP(AC.faint, 1.2));
}

class PlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(10));
    c.drawRRect(r, fillP(const Color(0xFFE9DEC6)));
    c.drawRRect(r, strokeP(AC.line, 1));
    c.drawLine(const Offset(8, 8), Offset(s.width - 8, s.height - 8), strokeP(AC.line, 1));
    c.drawLine(Offset(s.width - 8, 8), Offset(8, s.height - 8), strokeP(AC.line, 1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  DashedCirclePainter(this.color);
  @override
  void paint(Canvas c, Size s) =>
      drawDashedCircle(c, s.center(Offset.zero), s.width / 2 - .5, strokeP(color, 1));
  @override
  bool shouldRepaint(covariant DashedCirclePainter o) => o.color != color;
}

// ───────────────────────── despiece del cristal ─────────────────────────

/// Despiece vertical: punta, cuerpo con vena de energía, anillo-engranaje y base.
void paintExploded(Canvas c, double cx, double top, Fragmento f, {double t = 1}) {
  // t: 0 = piezas juntas, 1 = piezas separadas (animación)
  double sep(double y) => top + y * (.55 + .45 * t);
  drawDashedLine(c, Offset(cx, top - 10), Offset(cx, sep(470)), strokeP(AC.faint, 1), dash: 4, gap: 6);
  const w = 74.0;
  // punta
  var y = sep(0);
  final punta = [Offset(cx, y), Offset(cx + w / 2, y + 70), Offset(cx - w / 2, y + 70)];
  c.drawPath(polyPath(punta), fillP(f.colorClaro));
  c.drawPath(polyPath([Offset(cx, y), Offset(cx + w / 2, y + 70), Offset(cx + 6, y + 70)]), fillP(f.color, .55));
  c.drawPath(polyPath(punta), strokeP(AC.ink, 1.6));
  // cuerpo
  y = sep(100);
  final body = Rect.fromLTWH(cx - w / 2, y, w, 190);
  c.drawRect(body, fillP(f.colorClaro));
  c.drawRect(Rect.fromLTWH(cx + 8, y, w / 2 - 8, 190), fillP(f.color, .55));
  c.drawRect(Rect.fromLTWH(cx - w / 2, y, 18, 190), fillP(Colors.white, .25));
  c.drawRect(body, strokeP(AC.ink, 1.6));
  c.drawLine(Offset(cx - 8, y + 10), Offset(cx - 8, y + 180), strokeP(AC.ink, 1, .4));
  c.drawLine(Offset(cx + 8, y + 10), Offset(cx + 8, y + 180), strokeP(AC.ink, 1, .4));
  c.drawLine(Offset(cx, y + 8), Offset(cx, y + 182), strokeP(AC.viol, 2.2));
  // anillo-engranaje
  y = sep(330);
  final ring = Rect.fromCenter(center: Offset(cx, y), width: 116, height: 24);
  c.drawOval(ring, fillP(f.colorClaro));
  c.drawOval(ring, strokeP(f.colorOscuro, 1.6));
  for (var k = 0; k < 14; k++) {
    final a = k / 14 * 2 * math.pi;
    c.drawLine(Offset(cx + 58 * math.cos(a), y + 12 * math.sin(a)), Offset(cx + 66 * math.cos(a), y + 14 * math.sin(a)),
        strokeP(f.colorOscuro, 1.4));
  }
  // base facetada
  y = sep(380);
  final base = [Offset(cx - w / 2, y), Offset(cx + w / 2, y), Offset(cx, y + 70)];
  c.drawPath(polyPath(base), fillP(f.colorClaro));
  c.drawPath(polyPath([Offset(cx + 4, y), Offset(cx + w / 2, y), Offset(cx, y + 70)]), fillP(f.color, .55));
  c.drawPath(polyPath(base), strokeP(AC.ink, 1.6));
}

// ───────────────────────── electrocardiograma ─────────────────────────

class EcgPainter extends CustomPainter {
  final double phase; // 0..1
  final Color color;
  EcgPainter(this.phase, this.color);

  @override
  void paint(Canvas c, Size s) {
    const step = 6.0;
    final n = (s.width / step).floor();
    final shift = (phase * 14).floor();
    final pts = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final k = (i + shift) % 14;
      final dy = k == 7 ? -13.0 : (k == 8 ? 5.0 : (k == 6 ? -3.0 : 0.0));
      pts.add(Offset(i * step, s.height / 2 + dy));
    }
    c.drawPath(polyPath(pts, close: false), strokeP(color, 2));
  }

  @override
  bool shouldRepaint(covariant EcgPainter o) => o.phase != phase;
}
