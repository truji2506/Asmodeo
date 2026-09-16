import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExtractionTimeChart extends StatelessWidget {
  const ExtractionTimeChart({super.key});

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
                  'Tiempo de Extracción por Bioma',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'BIOMAS',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Text(
              'Duración media en horas por entorno de extracción',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 34,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()}h',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 14);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Pantano'; break;
                            case 1: text = 'Cueva'; break;
                            case 2: text = 'Volcán'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(meta: meta, child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % 8 != 0 && value != 34) return const SizedBox.shrink();
                          return Text('${value.toInt()}h', style: const TextStyle(color: Colors.grey, fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 8,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 12, color: const Color(0xFF16a085), width: 60, borderRadius: BorderRadius.circular(4))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 18, color: const Color(0xFF8e44ad), width: 60, borderRadius: BorderRadius.circular(4))
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 30, color: const Color(0xFFc0392b), width: 60, borderRadius: BorderRadius.circular(4))
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
