import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DamageOriginChart extends StatefulWidget {
  const DamageOriginChart({super.key});

  @override
  State<DamageOriginChart> createState() => _DamageOriginChartState();
}

class _DamageOriginChartState extends State<DamageOriginChart> {
  int touchedIndex = -1;

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
                  'Origen del Daño Crítico',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'ANÁLISIS DMG',
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Text(
              'Clasificación del daño recibido por tipología de fuente',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Σ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)),
                            Text('daño total', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 35,
                            sections: showingSections(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Leyenda
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(color: const Color(0xFFC62828), text: 'Mecánico', value: '45%'),
                        const SizedBox(height: 12),
                        _buildLegendItem(color: const Color(0xFFFF9800), text: 'Energético', value: '35%'),
                        const SizedBox(height: 12),
                        _buildLegendItem(color: const Color(0xFF7B1FA2), text: 'Entrópico', value: '20%'),
                      ],
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

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 35.0 : 25.0;
      const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white);

      switch (i) {
        case 0:
          return PieChartSectionData(color: const Color(0xFFC62828), value: 45, title: isTouched ? '45%' : '', radius: radius, titleStyle: textStyle);
        case 1:
          return PieChartSectionData(color: const Color(0xFFFF9800), value: 35, title: isTouched ? '35%' : '', radius: radius, titleStyle: textStyle);
        case 2:
          return PieChartSectionData(color: const Color(0xFF7B1FA2), value: 20, title: isTouched ? '20%' : '', radius: radius, titleStyle: textStyle);
        default:
          throw Error();
      }
    });
  }

  Widget _buildLegendItem({required Color color, required String text, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: double.parse(value.replaceAll('%', '')) / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          color: color,
          minHeight: 4,
        ),
      ],
    );
  }
}
