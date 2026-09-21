import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HumanFactionChart extends StatelessWidget {
  const HumanFactionChart({super.key});

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
                  'Distribución de la Facción Humana',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: const Text(
                    'FACCIONES',
                    style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Text(
              'Población por región — umbral estratégico a 3,750 unidades',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 8, // Subido a 8 para que la barra de 6.5k no golpee el techo
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 3.75,
                        color: Colors.orange,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 5, bottom: 5),
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          labelResolver: (line) => '3.75k',
                        ),
                      ),
                    ],
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY}k',
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
                        reservedSize: 36, // Espacio reservado para los textos "Norte", "Sur", etc.
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 14);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Norte'; break;
                            case 1: text = 'Sur'; break;
                            case 2: text = 'Este'; break;
                            case 3: text = 'Oeste'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(meta: meta, space: 8.0, child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 40, // Más espacio para los números del eje Y ("2k", "4k")
                        getTitlesWidget: (value, meta) {
                          if (value == 8) return const SizedBox.shrink(); // Ocultamos la etiqueta superior
                          return Text('${value.toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 6.5, color: const Color(0xFFAB47BC), width: 50, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 4.2, color: const Color(0xFF66BB6A), width: 50, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2.8, color: const Color(0xFFFFCA28), width: 50, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1.5, color: const Color(0xFF26A69A), width: 50, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '--- Umbral estratégico (3,750) — Norte y Sur superan el límite crítico',
              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
