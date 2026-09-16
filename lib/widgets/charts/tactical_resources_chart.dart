import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TacticalResourcesChart extends StatefulWidget {
  const TacticalResourcesChart({super.key});

  @override
  State<TacticalResourcesChart> createState() => _TacticalResourcesChartState();
}

class _TacticalResourcesChartState extends State<TacticalResourcesChart> {
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
                  'Recursos Tácticos Utilizados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'INVENTARIO',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Text(
              'Distribución porcentual del consumo táctico acumulado',
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
                            Text('100%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                            Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: showingSections(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Leyenda
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(color: const Color(0xFF27ae60), text: 'Materiales', value: '40%'),
                        const SizedBox(height: 8),
                        _buildLegendItem(color: const Color(0xFF16a085), text: 'Energía', value: '35%'),
                        const SizedBox(height: 8),
                        _buildLegendItem(color: const Color(0xFFf39c12), text: 'Componentes', value: '25%'),
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
      final fontSize = isTouched ? 16.0 : 0.0;
      final radius = isTouched ? 35.0 : 25.0;
      const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white);

      switch (i) {
        case 0:
          return PieChartSectionData(color: const Color(0xFF27ae60), value: 40, title: isTouched ? '40%' : '', radius: radius, titleStyle: textStyle);
        case 1:
          return PieChartSectionData(color: const Color(0xFF16a085), value: 35, title: isTouched ? '35%' : '', radius: radius, titleStyle: textStyle);
        case 2:
          return PieChartSectionData(color: const Color(0xFFf39c12), value: 25, title: isTouched ? '25%' : '', radius: radius, titleStyle: textStyle);
        default:
          throw Error();
      }
    });
  }

  Widget _buildLegendItem({required Color color, required String text, required String value}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 12))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
