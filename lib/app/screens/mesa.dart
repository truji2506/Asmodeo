import 'package:flutter/material.dart';
import '../data.dart';
import '../painters/painters.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 01 · La Mesa — plano enrollado (1A) y desenrollado (1B).
class MesaScreen extends StatelessWidget {
  const MesaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Stack(children: [
      ..._tarjetasIzquierda(s),
      Positioned.fill(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, .02), end: Offset.zero).animate(a),
              child: child,
            ),
          ),
          child: s.planoAbierto
              ? const _PlanoAbierto(key: ValueKey('abierto'))
              : const _PlanoCerrado(key: ValueKey('cerrado')),
        ),
      ),
    ]);
  }

  List<Widget> _tarjetasIzquierda(AsmodeoState s) => [
        card(40, 100, 320, 330),
        eyebrow(64, 136, 'Lámina interactiva'),
        txt(64, 178, 'El Motor de\nla Creación', AT.serif(32, height: 1.25)),
        txt(64, 254,
            'Un inventor que solo cree en lo que puede medir. Tres cristales forjados por deidades. Despliega el plano y recorre Midgard.',
            AT.sans(14, color: AC.ink2, height: 1.55),
            w: 270),
        button(64, 356, 272, s.planoAbierto ? 'Enrollar el plano' : 'Desenrollar el plano',
            onTap: () => s.abrirPlano(!s.planoAbierto)),
        card(40, 450, 320, 410),
        eyebrow(64, 486, 'Personaje principal', color: AC.mute),
        txt(64, 522, 'Asmodeo', AT.serif(28)),
        const Positioned(
          left: 64,
          top: 542,
          width: 120,
          height: 160,
          child: _Retrato(),
        ),
        for (final (i, (k, v)) in const [('Rol', 'Inventor'), ('Rasgo', 'Sarcástico'), ('Motor', 'Lógica'), ('Altura', '1,75 m')]
            .indexed) ...[
          txt(200, 560.0 + i * 36, k, AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
          txt(200, 578.0 + i * 36, v, AT.sans(14, weight: FontWeight.w700)),
        ],
        txt(64, 740, 'Sabelotodo, calculador y obsesionado con la lógica escondida detrás de la magia.',
            AT.sans(14, color: AC.ink2, height: 1.55),
            w: 270),
        marginNote(64, 822, '«Si no lo puedo medir,\nno existe.» — A.', 19, rot: -1.5),
      ];
}

class _Retrato extends StatelessWidget {
  const _Retrato();
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/asmodeo_retrato.jpg', fit: BoxFit.cover, filterQuality: FilterQuality.high),
      );
}

// ───────────────────────── 1A · plano enrollado ─────────────────────────

class _PlanoCerrado extends StatefulWidget {
  const _PlanoCerrado({super.key});
  @override
  State<_PlanoCerrado> createState() => _PlanoCerradoState();
}

class _PlanoCerradoState extends State<_PlanoCerrado> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..repeat(reverse: true);
  bool _hover = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final estado = {
      for (final f in fragmentos) f.id: s.recolectados.contains(f.id) ? Cristal.puesto : Cristal.vacio,
    };
    const y = 720.0;
    final dx = Lienzo.dxOf(context);
    return Stack(children: [
     shift(dx / 2, [
      Positioned.fill(
        child: IgnorePointer(
         child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => CustomPaint(
            painter: MotorPainter(center: const Offset(714, 380), k: .95, estado: estado, pulse: _pulse.value),
          ),
         ),
        ),
      ),
      txt(714, 662, 'Fig. 0 — El Motor, incompleto', AT.serif(14, color: AC.mute, weight: FontWeight.w400, style: FontStyle.italic),
          align: TextAlign.center, w: 400),
      // plano enrollado (clic para abrir)
      Positioned(
        left: 414,
        top: y - 30,
        width: 600,
        height: 124,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: Tap(
            onTap: () => s.abrirPlano(),
            tooltip: 'Desenrollar el plano',
            child: AnimatedScale(
              scale: _hover ? 1.03 : 1,
              duration: const Duration(milliseconds: 180),
              child: CustomPaint(painter: _RolloPainter()),
            ),
          ),
        ),
      ),
      txt(714, y + 104, 'Haz clic en el plano o en «Desenrollar el plano» para abrir Midgard',
          AT.sans(13, color: AC.mute, weight: FontWeight.w500),
          align: TextAlign.center, w: 600),
     ]),
     shift(dx, _panelMision(s)),
    ]);
  }

  List<Widget> _panelMision(AsmodeoState s) {
    const px = 1044.0, pw = 356.0;
    final n = s.recolectados.length;
    return [
      card(px, 100, pw, 760),
      eyebrow(px + 24, 136, 'Tu misión'),
      txt(px + 24, 176, 'Tres fragmentos,\ntres guardianes', AT.serif(24, height: 1.33)),
      txt(px + 24, 254, 'Recupera cada cristal del Génesis y llévalo a la fragua del volcán.',
          AT.sans(14, color: AC.ink2, height: 1.5),
          w: 300),
      for (final (i, f) in fragmentos.indexed) ...[
        Positioned(
          left: px + 24,
          top: 310.0 + i * 96,
          width: pw - 48,
          height: 82,
          child: Tap(
            onTap: () => s.verEnViaje(i),
            child: Container(
              decoration: BoxDecoration(
                color: AC.parch2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AC.line),
              ),
              child: Row(children: [
                const SizedBox(width: 16),
                FragBadge(f, r: 22, got: s.recolectados.contains(f.id)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.nombre, style: AT.sans(15, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${f.zona} · ${f.guardian}', style: AT.sans(12, color: AC.mute)),
                  ]),
                ),
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.recolectados.contains(f.id) ? f.color : const Color(0xFFEFE6D2),
                    borderRadius: BorderRadius.circular(13),
                    border: s.recolectados.contains(f.id) ? null : Border.all(color: AC.line),
                  ),
                  child: Text(s.recolectados.contains(f.id) ? 'Forjado' : 'Sin forjar',
                      style: AT.sans(11,
                          color: s.recolectados.contains(f.id) ? Colors.white : AC.mute, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
              ]),
            ),
          ),
        ),
      ],
      Positioned(left: px + 24, top: 610, width: pw - 48, height: 1, child: const ColoredBox(color: AC.line)),
      txt(px + 24, 644, 'Progreso del viaje', AT.sans(13, weight: FontWeight.w700)),
      txt(px + pw - 24, 644, '$n / 3', AT.sans(13, color: AC.mute, weight: FontWeight.w700), align: TextAlign.right, w: 100),
      Positioned(left: px + 24, top: 658, width: pw - 48, height: 8, child: ProgressBar(n / 3)),
      marginNote(px + 30, 718, n == 3 ? '3 cristales.\nA la fragua.' : '${3 - n} huecos.\n0 excusas.', 24, rot: -3),
    ];
  }
}

class _RolloPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    // coordenadas locales: el rollo (540×64) empieza en (30, 30)
    const x = 30.0, y = 30.0;
    c.drawRRect(RRect.fromLTRBR(x, y + 8, x + 540, y + 72, const Radius.circular(32)), fillP(const Color(0xFF3A2C1E), .10));
    final body = RRect.fromLTRBR(x, y, x + 540, y + 64, const Radius.circular(32));
    c.drawRRect(body, fillP(const Color(0xFFD8C29A)));
    c.drawRRect(body, strokeP(AC.ink2, 1.4));
    c.drawRRect(RRect.fromLTRBR(x + 16, y + 10, x + 524, y + 20, const Radius.circular(5)), fillP(Colors.white, .3));
    c.drawLine(const Offset(x + 28, y + 44), const Offset(x + 512, y + 44), strokeP(AC.ink2, 1, .35));
    c.drawRRect(RRect.fromLTRBR(x + 196, y + 18, x + 344, y + 46, const Radius.circular(4)), fillP(AC.carm));
    drawText(c, 'PLANO DE MIDGARD', const Offset(x + 270, y + 32),
        AT.sans(11, color: Colors.white, weight: FontWeight.w700, spacing: 1.4),
        align: TextAlign.center);
    for (final ex in [x, x + 540]) {
      c.drawCircle(Offset(ex, y + 32), 30, fillP(const Color(0xFFC9AE82)));
      c.drawCircle(Offset(ex, y + 32), 30, strokeP(AC.ink2, 1.4));
      c.drawCircle(Offset(ex, y + 32), 8, fillP(AC.ink2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ───────────────────────── 1B · plano desenrollado ─────────────────────────

const _articulo = ['Las', 'Los', 'Las', 'El', ''];

Color colorLugar(int i) => i == 4 ? AC.ink2 : (lugares[i].fragId == null ? AC.ochre : fragPorId(lugares[i].fragId!).color);

class _PlanoAbierto extends StatelessWidget {
  const _PlanoAbierto({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const mx = 384.0, my = 100.0, mw = 640.0, mh = 760.0;
    final dx = Lienzo.dxOf(context);
    return Stack(children: [
      CanvasPaint((c) => paintScroll(c, Rect.fromLTWH(mx, my, mw + dx, mh))),
     shift(dx / 2, [
      CanvasPaint((c) {
        paintContinent(c, const Rect.fromLTWH(mx + 80, my + 120, 540, 520));
      }),
      txt(mx + 360, my + 64, 'MIDGARD', AT.serif(14, color: AC.ink2).copyWith(letterSpacing: 6), align: TextAlign.center, w: 300),
      for (var i = 0; i < lugares.length; i++) _Punto(i: i, sel: s.lugarSel == i, onTap: () => s.seleccionarLugar(i)),
     ]),
      Positioned(
        left: mx + 60,
        top: my + mh - 70,
        width: 290,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AC.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AC.line),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: AC.carm, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
            const SizedBox(width: 8),
            Text('Haz clic en un punto de interés', style: AT.sans(13, color: AC.ink2, weight: FontWeight.w600)),
          ]),
        ),
      ),
      shift(dx, _panelLugar(context, s)),
    ]);
  }

  List<Widget> _panelLugar(BuildContext context, AsmodeoState s) {
    const px = 1044.0, pw = 356.0;
    final i = s.lugarSel;
    final l = lugares[i];
    final f = l.fragId == null ? null : fragPorId(l.fragId!);
    final datos = [('Población', l.poblacion), ('Facción', l.faccion), ('Extracción', l.extraccion), ('Guardián', l.guardian)];
    return [
      card(px, 100, pw, 760),
      eyebrow(px + 24, 136, 'Información del lugar'),
      Positioned(
        left: px + 24,
        top: 156,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(color: f?.colorClaro ?? (i == 4 ? const Color(0xFFEADFC6) : const Color(0xFFF1D2AE)), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: f != null
              ? FragIcon(f.forma, f.color, 11)
              : (i == 4
                  ? const Icon(Icons.cottage, color: AC.ink2, size: 22)
                  : const Icon(Icons.local_fire_department, color: AC.ochre, size: 22)),
        ),
      ),
      txt(px + 76, 186, '${_articulo[i]} ${l.nombre}'.trim(), AT.serif(26)),
      Positioned(left: px + 24, top: 214, width: pw - 48, height: 150, child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Image.asset(
              'assets/lugares/lugar_${const ['llanuras', 'pantanos', 'tundras', 'volcan', 'midgard'][i]}.jpg',
              key: ValueKey(i),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              width: pw - 48,
              height: 150,
            ),
          ),
        )),
      txt(px + 24, 398, 'Datos', AT.sans(15, weight: FontWeight.w700)),
      for (final (k, (lab, v)) in datos.indexed)
        Positioned(
          left: px + 24 + (k % 2) * 158,
          top: 414.0 + (k ~/ 2) * 74,
          width: 150,
          height: 62,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            decoration: BoxDecoration(
              color: AC.parch2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AC.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lab, style: AT.sans(11, color: AC.mute, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(v, style: AT.serif(17), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      txt(px + 24, 592, 'Curiosidades', AT.sans(15, weight: FontWeight.w700)),
      for (final (k, cur) in l.curiosidades.indexed) ...[
        Positioned(
          left: px + 26.5,
          top: 622.0 + k * 52 - 7.5,
          width: 7,
          height: 7,
          child: Container(decoration: BoxDecoration(color: colorLugar(i), shape: BoxShape.circle)),
        ),
        txt(px + 44, 622.0 + k * 52, cur, AT.sans(13, color: AC.ink2, height: 1.45), w: pw - 72),
      ],
      button(px + 24, 792, pw - 48, i == 4 ? 'Empezar el viaje →' : (i == 3 ? 'Ver la ruta hasta el volcán →' : 'Ver en el viaje →'),
          kind: BtnKind.accent, onTap: () => s.verEnViaje(i)),
    ];
  }
}

class _Punto extends StatefulWidget {
  final int i;
  final bool sel;
  final VoidCallback onTap;
  const _Punto({required this.i, required this.sel, required this.onTap});
  @override
  State<_Punto> createState() => _PuntoState();
}

class _PuntoState extends State<_Punto> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l = lugares[widget.i];
    final p = l.posMesa;
    final col = colorLugar(widget.i);
    final lw = l.nombre.length * 8.0 + 28;
    final activo = widget.sel || _hover;
    return Positioned(
      left: p.dx - 60,
      top: p.dy - 64,
      width: 120,
      height: 110,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Tap(
          onTap: widget.onTap,
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
            // halo
            Positioned(
              top: 64 - 34,
              child: SizedBox(
                width: 68,
                height: 68,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: activo ? 68 : 0,
                    height: activo ? 68 : 0,
                    decoration: BoxDecoration(color: col.withValues(alpha: .18), shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 64 - 9 - 2.5,
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
              ),
            ),
            // etiqueta
            Positioned(
              top: 14,
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: lw,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.sel ? AC.ink : AC.paper,
                    borderRadius: BorderRadius.circular(8),
                    border: widget.sel ? null : Border.all(color: AC.line),
                  ),
                  child: Text(l.nombre, style: AT.sans(13, color: widget.sel ? AC.paper : AC.ink, weight: FontWeight.w700)),
                ),
                if (widget.sel) CustomPaint(size: const Size(14, 8), painter: _Pico()),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Pico extends CustomPainter {
  @override
  void paint(Canvas c, Size s) => c.drawPath(polyPath([Offset.zero, Offset(s.width / 2, s.height), Offset(s.width, 0)]), fillP(AC.ink));
  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
