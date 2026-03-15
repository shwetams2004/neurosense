import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimelineChart extends StatelessWidget {
  final List<double> memory;
  final List<double> attention;
  final List<double> executive;

  const TimelineChart({
    super.key,
    required this.memory,
    required this.attention,
    required this.executive,
  });

  List<FlSpot> _spots(List<double> values) {
    return List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: -3,
          maxY: 3,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) =>
                    Text("W${value.toInt() + 1}"),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _spots(memory),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: _spots(attention),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: _spots(executive),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
