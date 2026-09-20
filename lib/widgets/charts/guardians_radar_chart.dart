import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GuardiansRadarChart extends StatefulWidget {
  const GuardiansRadarChart({super.key});

  @override
  State<GuardiansRadarChart> createState() => _GuardiansRadarChartState();
}

class _GuardiansRadarChartState extends State<GuardiansRadarChart> {
  // Estado para controlar qué métricas están visibles (filtros)
  bool showTirano = true;
  bool showHechicero = true;
  bool showMinotauro = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comparativa de Amenaza de los Guardianes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'RADAR - 3 ENTIDADES',
                    style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Text(
              'Filtra haciendo clic en las leyendas para aislar entidades',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        tickCount: 5,
                        ticksTextStyle: const TextStyle(color: Colors.transparent),
                        gridBorderData: const BorderSide(color: Colors.black12, width: 2),
                        tickBorderData: const BorderSide(color: Colors.black12),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0: return const RadarChartTitle(text: 'Fuerza Bruta');
                            case 1: return const RadarChartTitle(text: 'Magia / Alcance');
                            case 2: return const RadarChartTitle(text: 'Resistencia');
                            case 3: return const RadarChartTitle(text: 'Velocidad');
                            case 4: return const RadarChartTitle(text: 'Letalidad');
                            default: return const RadarChartTitle(text: '');
                          }
                        },
                        titlePositionPercentageOffset: 0.2,
                        titleTextStyle: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold),
                        dataSets: [
                          // Tirano Porcino (Naranja)
                          if (showTirano)
                            RadarDataSet(
                              fillColor: const Color(0xFFD84315).withValues(alpha: 0.2),
                              borderColor: const Color(0xFFD84315),
                              entryRadius: 3,
                              dataEntries: const [
                                RadarEntry(value: 92),
                                RadarEntry(value: 18),
                                RadarEntry(value: 78),
                                RadarEntry(value: 40),
                                RadarEntry(value: 85),
                              ],
                            ),
                          // Hechicero (Morado)
                          if (showHechicero)
                            RadarDataSet(
                              fillColor: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                              borderColor: const Color(0xFF6A1B9A),
                              entryRadius: 3,
                              dataEntries: const [
                                RadarEntry(value: 22),
                                RadarEntry(value: 95),
                                RadarEntry(value: 35),
                                RadarEntry(value: 60),
                                RadarEntry(value: 88),
                              ],
                            ),
                          // Minotauros (Verde)
                          if (showMinotauro)
                            RadarDataSet(
                              fillColor: const Color(0xFF00695C).withValues(alpha: 0.2),
                              borderColor: const Color(0xFF00695C),
                              entryRadius: 3,
                              dataEntries: const [
                                RadarEntry(value: 80),
                                RadarEntry(value: 30),
                                RadarEntry(value: 95),
                                RadarEntry(value: 55),
                                RadarEntry(value: 72),
                              ],
                            ),
                          // Dataset fantasma: evita que fl_chart colapse si apagas todos los filtros
                          if (!showTirano && !showHechicero && !showMinotauro)
                            RadarDataSet(
                              fillColor: Colors.transparent,
                              borderColor: Colors.transparent,
                              entryRadius: 0,
                              dataEntries: const [
                                RadarEntry(value: 0),
                                RadarEntry(value: 0),
                                RadarEntry(value: 0),
                                RadarEntry(value: 0),
                                RadarEntry(value: 0),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Leyenda Interactiva
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInteractiveLegend(
                            name: 'Tirano Porcino',
                            color: const Color(0xFFD84315),
                            isActive: showTirano,
                            onTap: () => setState(() => showTirano = !showTirano),
                          ),
                          const SizedBox(height: 10),
                          _buildInteractiveLegend(
                            name: 'Hechicero',
                            color: const Color(0xFF6A1B9A),
                            isActive: showHechicero,
                            onTap: () => setState(() => showHechicero = !showHechicero),
                          ),
                          const SizedBox(height: 10),
                          _buildInteractiveLegend(
                            name: 'Minotauros',
                            color: const Color(0xFF00695C),
                            isActive: showMinotauro,
                            onTap: () => setState(() => showMinotauro = !showMinotauro),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las leyendas clickeables
  Widget _buildInteractiveLegend({
    required String name,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: isActive ? color : Colors.grey.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isActive ? color : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
              ),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}
