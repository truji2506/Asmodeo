import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../painters/painters.dart';
import '../theme.dart';

/// Tamaño del lienzo (frame de Figma 1440×900).
const kW = 1440.0;
const kH = 900.0;

/// Coloca un texto con su línea base en (x, baseline), como en Figma/SVG.
/// [align] center/right usan [w] como ancho de caja alrededor de x.
Widget txt(double x, double baseline, String text, TextStyle style,
    {TextAlign align = TextAlign.left, double w = 600, int? maxLines}) {
  final size = style.fontSize ?? 14;
  final lh = style.height ?? 1.25;
  final top = baseline - size * (0.95 + (lh - 1.2) / 2);
  double left = x;
  if (align == TextAlign.center) left = x - w / 2;
  if (align == TextAlign.right) left = x - w;
  return Positioned(
    left: left,
    top: top,
    width: w,
    child: IgnorePointer(child: Text(text, style: style, textAlign: align, maxLines: maxLines, softWrap: true)),
  );
}

/// Área clicable con cursor de mano.
class Tap extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final String? tooltip;
  const Tap({super.key, this.onTap, required this.child, this.tooltip});

  @override
  Widget build(BuildContext context) {
    Widget w = MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
    );
    if (tooltip != null) w = Tooltip(message: tooltip!, child: w);
    return w;
  }
}

/// Tarjeta de papel (card de la guía de estilo).
class PaperCard extends StatelessWidget {
  final Widget? child;
  final Color fill;
  final Color border;
  final double radius;
  const PaperCard({super.key, this.child, this.fill = AC.paper, this.border = AC.line, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: const [BoxShadow(color: Color(0x0F3A2C1E), offset: Offset(0, 4))],
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

Widget card(double x, double y, double w, double h, {Color fill = AC.paper, Color border = AC.line, double radius = 16}) =>
    Positioned(left: x, top: y, width: w, height: h, child: PaperCard(fill: fill, border: border, radius: radius));

Widget eyebrow(double x, double baseline, String t, {Color color = AC.carm}) =>
    txt(x, baseline, t.toUpperCase(), AT.eyebrow(color: color));

enum BtnKind { primary, accent, ghost, light, disabled, outline }

class PillButton extends StatelessWidget {
  final String label;
  final BtnKind kind;
  final VoidCallback? onTap;
  final double size;
  final IconData? icon;
  const PillButton(this.label, {super.key, this.kind = BtnKind.primary, this.onTap, this.size = 15, this.icon});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    Border? border;
    switch (kind) {
      case BtnKind.primary:
        bg = AC.ink;
        fg = AC.paper;
      case BtnKind.accent:
        bg = AC.carm;
        fg = Colors.white;
      case BtnKind.ghost:
        bg = Colors.transparent;
        fg = AC.ink;
        border = Border.all(color: AC.ink, width: 1.4);
      case BtnKind.light:
        bg = AC.paper;
        fg = AC.ink;
      case BtnKind.disabled:
        bg = const Color(0xFFE3D8C2);
        fg = AC.faint;
      case BtnKind.outline:
        bg = Colors.transparent;
        fg = Colors.white;
        border = Border.all(color: Colors.white.withValues(alpha: .9), width: 1.2);
    }
    final enabled = kind != BtnKind.disabled && onTap != null;
    return Tap(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: border),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: size + 3, color: fg), const SizedBox(width: 8)],
          Text(label, style: AT.sans(size, color: fg, weight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

Widget button(double x, double y, double w, String label,
        {BtnKind kind = BtnKind.primary, VoidCallback? onTap, double h = 48, double size = 15, IconData? icon}) =>
    Positioned(left: x, top: y, width: w, height: h, child: PillButton(label, kind: kind, onTap: onTap, size: size, icon: icon));

/// Chip redondeado (filtros de guardianes, etc.).
class PillChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? color;
  final Color? dot;
  final VoidCallback? onTap;
  final double h;
  final double size;
  final bool dark;
  const PillChip(this.label,
      {super.key, this.active = false, this.color, this.dot, this.onTap, this.h = 28, this.size = 12, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final bg = active ? (color ?? AC.ink) : (dark ? Colors.transparent : AC.paper);
    final fg = active ? Colors.white : (dark ? AC.nightText : AC.ink2);
    final bd = active ? null : Border.all(color: dark ? (color ?? AC.nightLine) : AC.line, width: dark ? 1.4 : 1);
    return Tap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(h / 2), border: bd),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot != null) ...[
            Container(width: 10, height: 10, decoration: BoxDecoration(color: active ? Colors.white : dot, shape: BoxShape.circle)),
            const SizedBox(width: 7),
          ],
          Text(label, style: AT.sans(size, color: fg, weight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

/// Ícono de fragmento: triángulo, hexágono o cuadrado.
class FragIcon extends StatelessWidget {
  final FragShape shape;
  final Color color;
  final double r;
  final bool filled;
  final bool dashed;
  final double sw;
  const FragIcon(this.shape, this.color, this.r, {super.key, this.filled = true, this.dashed = false, this.sw = 1.6});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: r * 2 + 4,
        height: r * 2 + 4,
        child: CustomPaint(painter: _ShapePainter(shape, color, r, filled, dashed, sw)),
      );
}

class _ShapePainter extends CustomPainter {
  final FragShape shape;
  final Color color;
  final double r;
  final bool filled, dashed;
  final double sw;
  _ShapePainter(this.shape, this.color, this.r, this.filled, this.dashed, this.sw);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 1);
    final p = polyPath(shapePts(shape, c, r));
    if (filled) canvas.drawPath(p, fillP(color, .85));
    final s = strokeP(color, sw);
    canvas.drawPath(dashed ? dashPath(p, 3, 3) : p, s);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter o) => o.color != color || o.filled != filled || o.shape != shape;
}

/// Medallón circular con el ícono del fragmento.
class FragBadge extends StatelessWidget {
  final Fragmento f;
  final double r;
  final bool got;
  final bool dark;
  const FragBadge(this.f, {super.key, this.r = 14, this.got = true, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final mute = dark ? const Color(0xFFB9AC98) : AC.mute;
    return SizedBox(
      width: r * 2,
      height: r * 2,
      child: Stack(alignment: Alignment.center, children: [
        if (got)
          Container(decoration: BoxDecoration(color: f.colorClaro, shape: BoxShape.circle))
        else
          CustomPaint(size: Size(r * 2, r * 2), painter: DashedCirclePainter(mute)),
        Opacity(
          opacity: got ? 1 : .6,
          child: FragIcon(f.forma, got ? f.color : mute, r * (got ? .57 : .5), filled: got, sw: got ? 1.6 : 1.2),
        ),
      ]),
    );
  }
}

/// Nota manuscrita de Asmodeo al margen (Caveat, azul, ligeramente girada).
Widget marginNote(double x, double baseline, String text, double size, {Color color = AC.blue, double rot = -2, double w = 360}) {
  final s = size * 1.22; // Caveat se ve pequeña: misma escala que en Figma
  return Positioned(
    left: x,
    top: baseline - s * .9,
    width: w,
    child: IgnorePointer(
      child: Transform.rotate(
        angle: rot * math.pi / 180,
        alignment: Alignment.topLeft,
        child: Text(text, style: AT.hand(s, color: color)),
      ),
    ),
  );
}

/// Imagen pendiente (marco con aspa).
class ImgPlaceholder extends StatelessWidget {
  final String label;
  const ImgPlaceholder(this.label, {super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PlaceholderPainter(),
        child: Center(
          child: Container(
            color: const Color(0xFFE9DEC6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(label, style: AT.sans(12, color: AC.mute, weight: FontWeight.w500)),
          ),
        ),
      );
}

/// Barra de progreso simple.
class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final Color track;
  const ProgressBar(this.value, {super.key, this.color = AC.carm, this.track = const Color(0xFFE8DDC6)});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => Stack(children: [
          Container(decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(4))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: c.maxWidth * value.clamp(0, 1),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
        ]),
      );
}

void aviso(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: AT.sans(14, color: AC.paper, weight: FontWeight.w600)),
      backgroundColor: AC.ink,
      behavior: SnackBarBehavior.floating,
      width: 420,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      duration: const Duration(seconds: 2),
    ));
}

/// Pinta con coordenadas absolutas del lienzo 1440×900 (no recibe clics).
class CanvasPaint extends StatelessWidget {
  final void Function(Canvas c) painter;
  final Listenable? repaint;
  const CanvasPaint(this.painter, {super.key, this.repaint});
  @override
  // Positioned.fill: así no decide el tamaño del Stack (antes lo fijaba en 1440
  // y las pantallas quedaban corridas al centrarse en ventanas más anchas).
  Widget build(BuildContext context) =>
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _FnPainter(painter, repaint))));
}

class _FnPainter extends CustomPainter {
  final void Function(Canvas c) fn;
  _FnPainter(this.fn, Listenable? repaint) : super(repaint: repaint);
  @override
  void paint(Canvas canvas, Size size) => fn(canvas);
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Ancho extra del lienzo respecto al frame de 1440 (ventanas más anchas).
/// Las pantallas lo usan para estirar mapas y anclar paneles al borde derecho.
class Lienzo extends InheritedWidget {
  final double dx;
  const Lienzo({super.key, required this.dx, required super.child});
  static double dxOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Lienzo>()?.dx ?? 0;
  @override
  bool updateShouldNotify(Lienzo old) => old.dx != dx;
}

/// Grupo de elementos desplazado horizontalmente [dx] px (conserva los clics).
Widget shift(double dx, List<Widget> children) => Positioned.fill(
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
