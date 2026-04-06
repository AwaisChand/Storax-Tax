import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';

class MonthlyBarChart extends StatelessWidget {
  final bool showTotal;
  final bool showTax;

  const MonthlyBarChart({
    super.key,
    required this.showTotal,
    required this.showTax,
  });

  @override
  Widget build(BuildContext context) {
    final gasoline = context.read<GasolineViewModel>();
    final monthlyTrend =
        gasoline.getTransactionReportModel?.data?.charts?.monthlyTrend ?? [];

    /// No data OR both disabled
    if (monthlyTrend.isEmpty || (!showTotal && !showTax)) {
      return const Center(child: Text("No Data"));
    }

    /// ---------- MAX Y CALC ----------
    double rawMaxY = 0;
    for (var item in monthlyTrend) {
      final total = showTotal ? (item.total ?? 0) : 0;
      final tax = showTax ? (item.tax ?? 0) : 0;
      final sum = total + tax;
      if (sum > rawMaxY) rawMaxY = sum.toDouble();
    }

    num calculateNiceMax(double raw) {
      const steps = [50, 100, 200, 500, 1000, 2000, 5000];
      for (final s in steps) {
        if (raw / s <= 5) {
          return (raw / s).ceil() * s;
        }
      }
      return raw.ceilToDouble();
    }

    final maxY = calculateNiceMax(rawMaxY);
    final step = maxY / 3;

    final currency =
    NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    const monthWidth = 60.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: Utils.setHeight(context) * 0.35,
        width: monthlyTrend.length * monthWidth + 40,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            alignment: BarChartAlignment.spaceAround,

            /// ---------- TOOLTIP ----------
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, __) {
                  final month = monthlyTrend[group.x].month ?? '';
                  return BarTooltipItem(
                    '$month\n${currency.format(rod.toY)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),

            /// ---------- AXES ----------
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: step,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      currency.format(value),
                      style: GoogleFonts.montserrat(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < monthlyTrend.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          monthlyTrend[index].month ?? '',
                          style: GoogleFonts.montserrat(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox();
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

            /// ---------- BARS ----------
            barGroups: List.generate(monthlyTrend.length, (i) {
              final item = monthlyTrend[i];

              final rods = <BarChartRodData>[];

              if (showTotal) {
                rods.add(
                  BarChartRodData(
                    toY: (item.total ?? 0).toDouble(),
                    color: Colors.blue,
                    width: 12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }

              if (showTax) {
                rods.add(
                  BarChartRodData(
                    toY: (item.tax ?? 0).toDouble(),
                    color: AppColors.goldenOrangeColor,
                    width: 12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }

              return BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: rods,
              );
            }),
          ),
        ),
      ),
    );
  }
}
