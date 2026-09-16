import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GuardiansRadarChart extends StatelessWidget {
  const GuardiansRadarChart({super.key});

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
              'Perfiles de amenaza comparados en 5 ejes tácticos',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendEntity('Tirano Porcino', const Color(0xFFD84315)),
                          const SizedBox(height: 10),
                          _buildLegendEntity('Hechicero', const Color(0xFF6A1B9A)),
                          const SizedBox(height: 10),
                          _buildLegendEntity('Minotauros', const Color(0xFF00695C)),
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

  Widget _buildLegendEntity(String name, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
