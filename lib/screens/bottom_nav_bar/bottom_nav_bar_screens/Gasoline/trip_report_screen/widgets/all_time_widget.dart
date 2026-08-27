import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildMetricCard({
  required String title,
  required String value,
  required Color leftBorderColor,
  required Color valueColor,
  required Color iconColor,
}) {
  return Container(
    width: 170,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border(left: BorderSide(color: leftBorderColor, width: 4)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: valueColor, fontSize: 20
              ),
            ),
          ],
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    ),
  );
}

Widget buildBarChart() {
  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 450,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              String text =
                  value.toInt() == 0
                      ? 'Jun 2026'
                      : (value.toInt() == 1 ? 'Jul 2026' : '');
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            getTitlesWidget:
                (value, meta) => Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.black45, fontSize: 10),
                ),
            reservedSize: 45,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine:
            (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(toY: 6, color: Colors.blue, width: 12),
            BarChartRodData(
              toY: 410,
              color: const Color(0xFFF5B025),
              width: 50,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(toY: 4, color: Colors.blue, width: 12),
            BarChartRodData(
              toY: 78,
              color: const Color(0xFFF5B025),
              width: 50,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildLegendItem({required Color color, required String label}) {
  return Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
    ],
  );
}
