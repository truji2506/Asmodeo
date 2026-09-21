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
                        // Restauramos los números del radar que te gustaban.
                        // Gracias al ancla en 0 que pusimos antes, ahora los números serán exactos (20, 40, 60...)
                        ticksTextStyle: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold),
                        gridBorderData: const BorderSide(color: Colors.black12, width: 2),
                        tickBorderData: const BorderSide(color: Colors.black12),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0: return const RadarChartTitle(text: 'Fuerza Bruta');
                            case 1: return const RadarChartTitle(text: 'Magia /\nAlcance'); // Salto de línea para evitar choque
                            case 2: return const RadarChartTitle(text: 'Resistencia');
                            case 3: return const RadarChartTitle(text: 'Velocidad');
                            case 4: return const RadarChartTitle(text: 'Letalidad');
                            default: return const RadarChartTitle(text: '');
                          }
                        },
                        // Acercamos un poco más los títulos al gráfico para que no choquen con la leyenda
                        titlePositionPercentageOffset: 0.12,
                        titleTextStyle: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold),
                        dataSets: [
                          // Tirano Porcino (Naranja)
                          if (showTirano)
                            RadarDataSet(
                              fillColor: const Color(0xFFD84315).withValues(alpha: 0.2),
                              borderColor: const Color(0xFFD84315),
                              entryRadius: 4, // Puntos más grandes
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
                              entryRadius: 4, // Puntos más grandes
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
                              entryRadius: 4, // Puntos más grandes
                              dataEntries: const [
                                RadarEntry(value: 80),
                                RadarEntry(value: 30),
                                RadarEntry(value: 95),
                                RadarEntry(value: 55),
                                RadarEntry(value: 72),
                              ],
                            ),
                          // "Anchor Dataset" (Ancla estática al 100 y al 0)
                          RadarDataSet(
                            fillColor: Colors.transparent,
                            borderColor: Colors.transparent,
                            entryRadius: 0,
                            dataEntries: const [
                              RadarEntry(value: 100),
                              RadarEntry(value: 100),
                              RadarEntry(value: 100),
                              RadarEntry(value: 100),
                              RadarEntry(value: 100),
                            ],
                          ),
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
                  // Aumentamos la separación entre el radar y las leyendas
                  const SizedBox(width: 30),
                  
                  // Leyenda Interactiva con Valores Exactos
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
                          if (showTirano) _buildMetricsRow(const [92, 18, 78, 40, 85]),
                          const SizedBox(height: 12),
                          
                          _buildInteractiveLegend(
                            name: 'Hechicero',
                            color: const Color(0xFF6A1B9A),
                            isActive: showHechicero,
                            onTap: () => setState(() => showHechicero = !showHechicero),
                          ),
                          if (showHechicero) _buildMetricsRow(const [22, 95, 35, 60, 88]),
                          const SizedBox(height: 12),
                          
                          _buildInteractiveLegend(
                            name: 'Minotauros',
                            color: const Color(0xFF00695C),
                            isActive: showMinotauro,
                            onTap: () => setState(() => showMinotauro = !showMinotauro),
                          ),
                          if (showMinotauro) _buildMetricsRow(const [80, 30, 95, 55, 72]),
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

  // Row de métricas exactas (UI/UX enhancement)
  Widget _buildMetricsRow(List<int> values) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0, top: 4.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _metricBadge('FZA', values[0]),
          _metricBadge('MAG', values[1]),
          _metricBadge('RES', values[2]),
          _metricBadge('VEL', values[3]),
          _metricBadge('LET', values[4]),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, int val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.15)),
      ),
      child: Text(
        '$label: $val',
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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
