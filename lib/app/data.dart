import 'package:flutter/material.dart';
import 'theme.dart';

/// Forma del ícono de cada fragmento (igual que en la infografía).
enum FragShape { tri, hex, sq }

class Fragmento {
  final String id;
  final String nombre;
  final String zona;
  final String guardian;
  final String guardianCorto;
  final String artefacto;
  final Color color;
  final Color colorClaro;
  final Color colorOscuro;
  final FragShape forma;

  /// Ángulo del cristal en el Motor ensamblado (grados).
  final double angulo;

  const Fragmento({
    required this.id,
    required this.nombre,
    required this.zona,
    required this.guardian,
    required this.guardianCorto,
    required this.artefacto,
    required this.color,
    required this.colorClaro,
    required this.colorOscuro,
    required this.forma,
    required this.angulo,
  });
}

const fragmentos = <Fragmento>[
  Fragmento(
    id: 'esmeralda', nombre: 'Esmeralda', zona: 'Llanuras', guardian: 'Tirano porcino', guardianCorto: 'Tirano',
    artefacto: 'Trampas al tirano porcino', color: AC.esme, colorClaro: AC.esmeL, colorOscuro: AC.esmeD,
    forma: FragShape.tri, angulo: 90,
  ),
  Fragmento(
    id: 'carmesi', nombre: 'Carmesí', zona: 'Pantanos', guardian: 'Hechicero', guardianCorto: 'Hechicero',
    artefacto: 'Báculo del hechicero', color: AC.carm, colorClaro: AC.carmL, colorOscuro: AC.carmD,
    forma: FragShape.hex, angulo: -150,
  ),
  Fragmento(
    id: 'turquesa', nombre: 'Turquesa', zona: 'Tundras', guardian: 'Minotauros', guardianCorto: 'Minotauros',
    artefacto: 'Mano mecánica', color: AC.turq, colorClaro: AC.turqL, colorOscuro: AC.turqD,
    forma: FragShape.sq, angulo: -30,
  ),
];

Fragmento fragPorId(String id) => fragmentos.firstWhere((f) => f.id == id);

/// Ejes y valores del radar de guardianes (dato original de guardians_radar_chart.dart).
const ejesRadar = ['Fuerza bruta', 'Magia / alcance', 'Resistencia', 'Velocidad', 'Letalidad'];
const radarGuardian = <String, List<double>>{
  'esmeralda': [92, 18, 78, 40, 85], // Tirano porcino
  'carmesi': [22, 95, 35, 60, 88], // Hechicero
  'turquesa': [80, 30, 95, 55, 72], // Minotauros
};

/// Tiempo de extracción por bioma, en horas (extraction_time_chart.dart, renombrado a los biomas de la historia).
const horasExtraccion = <String, int>{'esmeralda': 12, 'carmesi': 18, 'turquesa': 30};

/// Desgaste del Motor por etapa del viaje T1→T5 (wear_level_chart.dart).
const desgastePorEtapa = [10, 25, 50, 72, 100];

/// Recursos tácticos (tactical_resources_chart.dart).
const recursos = [
  ('Materiales', 40, Color(0xFF27AE60)),
  ('Energía', 35, Color(0xFF16A085)),
  ('Componentes', 25, Color(0xFFF39C12)),
];

/// Origen del daño crítico (damage_origin_chart.dart).
const danos = [
  ('Mecánico', 45, Color(0xFFC62828)),
  ('Energético', 35, Color(0xFFFF9800)),
  ('Entrópico', 20, Color(0xFF7B1FA2)),
];

/// Daño dominante por zona (supuesto de diseño: un tipo de daño por guardián).
const danoDominante = <String, (String, int)>{
  'esmeralda': ('Mecánico', 45),
  'carmesi': ('Energético', 35),
  'turquesa': ('Entrópico', 20),
};

/// Lugares del mapa de la Mesa. Población por facción (population_map_chart.dart);
/// la asignación facción → lugar es un supuesto de diseño.
class Lugar {
  final String nombre;
  final String? fragId;
  final String poblacion;
  final String faccion;
  final String extraccion;
  final String guardian;
  final List<String> curiosidades;
  final Offset posMesa; // posición en la Mesa (lienzo 1440x900)
  const Lugar(this.nombre, this.fragId, this.poblacion, this.faccion, this.extraccion, this.guardian, this.curiosidades, this.posMesa);
}

const lugares = <Lugar>[
  Lugar('Llanuras', 'esmeralda', '6.500', 'Nómadas', '12 h', 'Tirano porcino', [
    'Pura fuerza bruta y cero cerebro: el tirano cayó en su propio juego.',
    'Asmodeo calculó peso, impacto y velocidad antes de armar las trampas.',
    'Aquí se arrebató el Fragmento Esmeralda.',
  ], Offset(584, 620)), // = sitioEn(continente Mesa, 0)
  Lugar('Pantanos', 'carmesi', '4.200', 'Chatarreros', '18 h', 'Hechicero', [
    'Húmedo y tóxico: el barro esconde el báculo del hechicero.',
    'Asmodeo usó pólvora y temporizadores, no hechizos.',
    'Aquí se extrajo el Fragmento Carmesí.',
  ], Offset(714, 460)),
  Lugar('Tundras', 'turquesa', '2.800', 'Supervivientes', '30 h', 'Minotauros', [
    'Laberintos de hielo patrullados por minotauros.',
    'Sobrevivió escondido en la nieve, con los planos húmedos y gastados.',
    'Aquí consiguió el Fragmento Turquesa, a costa de nuevas cicatrices.',
  ], Offset(854, 620)),
  Lugar('Volcán', null, '1.500', 'Eruditos', '—', 'Ninguno', [
    'Un volcán inactivo: la fragua natural que el Motor necesitaba.',
    'El calor es insoportable; la precisión, obligatoria.',
    'Aquí se ensamblan los tres fragmentos.',
  ], Offset(854, 400)),
  // Midgard: punto de partida (datos propuestos, ajustables)
  Lugar('Midgard', null, '800', 'Artesanos', '—', 'Ninguno', [
    'Aquí está el taller de Asmodeo, donde nació el plano del Motor.',
    'Desde aquí parte la línea progresiva del viaje.',
    '60 horas de ruta lo separan de la fragua del volcán.',
  ], Offset(591, 331)),
];

/// Etapas del viaje (línea progresiva). Índice 0 = inicio en Midgard.
class Etapa {
  final String nombre;
  final String? fragId;
  final Offset pos; // posición en el mapa del Viaje (lienzo 1440x900)
  const Etapa(this.nombre, this.fragId, this.pos);
}

const etapas = <Etapa>[
  Etapa('Inicio', null, Offset(290, 330)),
  Etapa('Llanuras', 'esmeralda', Offset(281, 641)),
  Etapa('Pantanos', 'carmesi', Offset(445, 469)),
  Etapa('Tundras', 'turquesa', Offset(621, 641)),
  Etapa('Volcán', null, Offset(621, 404)),
];

/// Notas al margen de Asmodeo por fragmento.
const notasAsmodeo = <String, String>{
  'esmeralda': 'Fuerza 92. Cerebro: ausente.',
  'carmesi': 'Magia 95. Cerebro táctico: discutible.',
  'turquesa': 'Resistencia 95. Yo, cicatrices.',
};
