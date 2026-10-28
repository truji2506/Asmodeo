import 'package:flutter/material.dart';
import 'data.dart';
import 'screens/mesa.dart';
import 'screens/motor.dart';
import 'screens/viaje.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/common.dart';

/// Lienzo fijo de 1440×900 (el mismo frame de Figma) escalado a la ventana.

class AsmodeoShell extends StatefulWidget {
  const AsmodeoShell({super.key});
  @override
  State<AsmodeoShell> createState() => _AsmodeoShellState();
}

class _AsmodeoShellState extends State<AsmodeoShell> {
  final state = AsmodeoState();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Scaffold(
        backgroundColor: AC.parch,
        body: LayoutBuilder(builder: (context, box) {
          // Escala para que el lienzo de 1440×900 quepa entero; el fondo y la
          // barra de navegación se extienden a todo el ancho/alto de la ventana.
          final scale = (box.maxWidth / kW) < (box.maxHeight / kH) ? box.maxWidth / kW : box.maxHeight / kH;
          final w = box.maxWidth / scale, h = box.maxHeight / scale;
          // SizedBox con el tamaño exacto de la ventana: sin él, FittedBox recibe
          // restricciones flojas y no escala (por eso quedaban franjas vacías).
          return SizedBox(
            width: box.maxWidth,
            height: box.maxHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(width: w, height: h, child: _Canvas(w: w, h: h)),
            ),
          );
        }),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  final double w, h;
  const _Canvas({required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final dark = s.pantalla == Pantalla.motor && s.completo;
    final Widget screen = switch (s.pantalla) {
      Pantalla.mesa => const MesaScreen(key: ValueKey('mesa')),
      Pantalla.viaje => const ViajeScreen(key: ValueKey('viaje')),
      Pantalla.motor => const MotorScreen(key: ValueKey('motor')),
    };
    return ClipRect(
      child: Stack(children: [
        // fondo pergamino + viñeta a pantalla completa
        Positioned.fill(child: Image.asset('assets/pergamino.jpg', fit: BoxFit.cover)),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -.1),
                radius: .75,
                colors: [Color(0x003A2A18), Color(0x383A2A18)],
                stops: [.55, 1],
              ),
            ),
          ),
        ),
        // fondo nocturno a pantalla completa en la Creación
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: dark ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AC.night, AC.night2]),
                ),
              ),
            ),
          ),
        ),
        // contenido (frame de Figma) centrado
        Positioned(
          left: 0,
          top: (h - kH) / 2,
          width: w,
          height: kH,
          child: Lienzo(
            dx: w - kW,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              child: screen,
            ),
          ),
        ),
        Positioned(left: 0, top: 0, width: w, height: 77, child: NavBar(dark: dark, width: w)),
      ]),
    );
  }
}

class NavBar extends StatelessWidget {
  final bool dark;
  final double width;
  const NavBar({super.key, this.dark = false, this.width = kW});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ink = dark ? const Color(0xFFF3EADB) : AC.ink;
    final mute = dark ? const Color(0xFFB9AC98) : AC.mute;
    final dx = width - kW; // desplaza a la derecha lo que va anclado al borde derecho
    final cx = dx / 2; // los enlaces quedan centrados
    final items = [('Mesa', Pantalla.mesa), ('Viaje', Pantalla.viaje), ('El Motor', Pantalla.motor)];
    return Stack(children: [
      if (!dark) Positioned.fill(child: ColoredBox(color: AC.parch2.withValues(alpha: .72))),
      Positioned(left: 40, right: 40, top: 76, height: 1, child: ColoredBox(color: dark ? const Color(0xFF5A4A3A) : AC.line)),
      // logo
      Positioned(
        left: 40,
        top: 16,
        child: Tap(
          onTap: s.reiniciar,
          tooltip: 'Volver al inicio',
          child: Row(children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(alignment: Alignment.center, children: [
                FragIcon(FragShape.hex, ink, 15, filled: false, sw: 1.8),
                const Padding(padding: EdgeInsets.only(top: 2), child: FragIcon(FragShape.tri, AC.carm, 7)),
              ]),
            ),
            const SizedBox(width: 4),
            Text('ASMODEO', style: AT.serif(19, color: ink).copyWith(letterSpacing: 3)),
          ]),
        ),
      ),
      // enlaces
      for (var i = 0; i < items.length; i++)
        Positioned(
          left: cx + 570.0 + i * 130,
          top: 28,
          child: Tap(
            onTap: () => s.ir(items[i].$2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(items[i].$1,
                  style: AT.sans(15,
                      color: s.pantalla == items[i].$2 ? ink : mute,
                      weight: s.pantalla == items[i].$2 ? FontWeight.w600 : FontWeight.w500)),
              const SizedBox(height: 7),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: s.pantalla == items[i].$2 ? items[i].$1.length * 8.6 : 0,
                decoration: BoxDecoration(color: AC.carm, borderRadius: BorderRadius.circular(1.5)),
              ),
            ]),
          ),
        ),
      // contador de fragmentos
      txt(dx + 1190, 44, 'Fragmentos', AT.sans(12, color: mute, weight: FontWeight.w600)),
      for (var i = 0; i < fragmentos.length; i++)
        Positioned(
          left: dx + 1272.0 + i * 34,
          top: 25,
          child: Tooltip(
            message: 'Fragmento ${fragmentos[i].nombre}',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: FragBadge(
                fragmentos[i],
                key: ValueKey(s.recolectados.contains(fragmentos[i].id)),
                got: s.recolectados.contains(fragmentos[i].id),
                dark: dark,
              ),
            ),
          ),
        ),
      txt(dx + 1392, 44, '${s.recolectados.length}/3', AT.sans(13, color: ink, weight: FontWeight.w700)),
    ]);
  }
}
