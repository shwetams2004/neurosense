import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimelineChart
    extends StatelessWidget {
  final List<double> memory;

  final List<double> attention;

  final List<double> executive;

  const TimelineChart({
    super.key,
    required this.memory,
    required this.attention,
    required this.executive,
  });

  List<FlSpot> _spots(
    List<double> values,
  ) {
    return List.generate(
      values.length,
      (i) => FlSpot(
        i.toDouble(),
        values[i],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          // =========================
          // LEGEND
          // =========================

          Wrap(
            spacing: 18,
            runSpacing: 10,
            alignment:
                WrapAlignment.center,
            children: [
              _legend(
                "Memory",
                Colors.blue,
              ),
              _legend(
                "Attention",
                Colors.orange,
              ),
              _legend(
                "Executive",
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =========================
          // CHART
          // =========================

          Expanded(
            child: LineChart(
              LineChartData(
                minY: -3,
                maxY: 3,

                backgroundColor:
                    Colors.transparent,

                gridData:
                    FlGridData(
                  show: true,
                  drawVerticalLine:
                      false,
                  horizontalInterval:
                      1,
                  getDrawingHorizontalLine:
                      (value) {
                    return FlLine(
                      color: Colors
                          .grey
                          .withOpacity(
                        0.12,
                      ),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData:
                    FlBorderData(
                  show: false,
                ),

                titlesData:
                    FlTitlesData(
                  topTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          false,
                    ),
                  ),

                  rightTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          false,
                    ),
                  ),

                  bottomTitles:
                      AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          true,
                      interval: 1,
                      reservedSize:
                          34,
                      getTitlesWidget:
                          (
                        value,
                        meta,
                      ) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Text(
                            "W${value.toInt() + 1}",
                            style:
                                const TextStyle(
                              fontSize:
                                  12,
                              color: Colors
                                  .grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles:
                      AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          true,
                      interval: 1,
                      reservedSize:
                          36,
                      getTitlesWidget:
                          (
                        value,
                        meta,
                      ) {
                        return Text(
                          value
                              .toInt()
                              .toString(),
                          style:
                              const TextStyle(
                            fontSize:
                                11,
                            color: Colors
                                .grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData:
                    LineTouchData(
                  touchTooltipData:
                      LineTouchTooltipData(
                    tooltipRoundedRadius:
                        14,
                  ),
                ),

                lineBarsData: [
                  _line(
                    memory,
                    Colors.blue,
                  ),
                  _line(
                    attention,
                    Colors.orange,
                  ),
                  _line(
                    executive,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LINE STYLE
  // =========================

  LineChartBarData _line(
    List<double> values,
    Color color,
  ) {
    return LineChartBarData(
      spots: _spots(values),

      isCurved: true,

      curveSmoothness: 0.35,

      color: color,

      barWidth: 4,

      isStrokeCapRound: true,

      belowBarData:
          BarAreaData(
        show: true,
        color: color.withOpacity(
          0.08,
        ),
      ),

      dotData: FlDotData(
        show: true,
        getDotPainter:
            (
          spot,
          percent,
          barData,
          index,
        ) {
          return FlDotCirclePainter(
            radius: 4.5,
            color: color,
            strokeWidth: 2,
            strokeColor:
                Colors.white,
          );
        },
      ),
    );
  }

  // =========================
  // LEGEND WIDGET
  // =========================

  Widget _legend(
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(
              4,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }
}