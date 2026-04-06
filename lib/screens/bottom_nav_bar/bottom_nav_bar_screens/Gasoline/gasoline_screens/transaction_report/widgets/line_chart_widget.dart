import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';

Widget buildLineChart(
    GasolineViewModel gasoline,
    BuildContext context, {
      required bool showTotal,
      required bool showTax,
    }) {
  final monthlyTrend =
      gasoline.getTransactionReportModel?.data?.charts?.monthlyTrend ?? [];

  if (monthlyTrend.isEmpty || (!showTotal && !showTax)) {
    return const Center(child: Text("No Data"));
  }

  /// ---------- MAX Y CALCULATION ----------
  double rawMaxY = 0;
  for (var item in monthlyTrend) {
    final total = showTotal ? (item.total ?? 0) : 0;
    final tax = showTax ? (item.tax ?? 0) : 0;
    rawMaxY = rawMaxY < (total + tax) ? (total + tax).toDouble() : rawMaxY;
  }

  num calculateNiceMax(double raw) {
    const steps = [50, 100, 200, 500, 1000, 2000, 5000];
    for (final s in steps) {
      if (raw / s <= 5) return (raw / s).ceil() * s;
    }
    return raw.ceilToDouble();
  }

  final maxY = calculateNiceMax(rawMaxY);
  final step = maxY / 3;

  final currency =
  NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  const monthWidth = 60.0;

  /// ---------- LINES ----------
  final List<LineChartBarData> lines = [];

  if (showTotal) {
    lines.add(
      LineChartBarData(
        spots: List.generate(
          monthlyTrend.length,
              (i) => FlSpot(
            i.toDouble(),
            (monthlyTrend[i].total ?? 0).toDouble(),
          ),
        ),
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        dotData: FlDotData(show: true),
      ),
    );
  }

  if (showTax) {
    lines.add(
      LineChartBarData(
        spots: List.generate(
          monthlyTrend.length,
              (i) => FlSpot(
            i.toDouble(),
            (monthlyTrend[i].tax ?? 0).toDouble(),
          ),
        ),
        isCurved: true,
        color: Colors.amber,
        barWidth: 3,
        dotData: FlDotData(show: true),
      ),
    );
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: monthlyTrend.length * monthWidth + 40,
      height: Utils.setHeight(context) * 0.35,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: monthlyTrend.length - 1,
          minY: 0,
          maxY: maxY.toDouble(),

          /// ---------- TOOLTIP ----------
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final month = monthlyTrend[spot.x.toInt()].month ?? '';
                  return LineTooltipItem(
                    '$month\n${currency.format(spot.y)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),

          /// ---------- AXES ----------
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < monthlyTrend.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        monthlyTrend[i].month ?? '',
                        style: GoogleFonts.montserrat(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    currency.format(value),
                    style: GoogleFonts.montserrat(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          /// ---------- GRID ----------
          gridData: FlGridData(
            show: true,
            horizontalInterval: step,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),

          lineBarsData: lines,
        ),
      ),
    ),
  );
}

Widget legendItem({
  required String text,
  required Color color,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            decoration:
            isActive ? TextDecoration.none : TextDecoration.lineThrough,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
