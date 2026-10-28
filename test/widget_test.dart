import 'package:flutter_test/flutter_test.dart';
import 'package:asmodeo/app/state.dart';

// Pruebas de la lógica de la experiencia (sin Firebase ni fuentes de red).
void main() {
  test('la tuerca recorre todo el viaje y se forja en cada punto', () {
    final s = AsmodeoState();
    s.irEtapa(4);
    expect(s.etapa, 4);
    s.irEtapa(1);
    s.forjar(); // Esmeralda en las Llanuras
    expect(s.recolectados, {'esmeralda'});
  });

  test('la fragua solo enciende con los tres fragmentos', () {
    final s = AsmodeoState();
    s.meterEnFragua('esmeralda');
    s.meterEnFragua('carmesi');
    s.encender();
    expect(s.completo, isFalse);
    s.meterEnFragua('turquesa');
    s.encender();
    expect(s.completo, isTrue);
    s.reiniciar();
    expect(s.completo, isFalse);
    expect(s.pantalla, Pantalla.mesa);
  });
}
