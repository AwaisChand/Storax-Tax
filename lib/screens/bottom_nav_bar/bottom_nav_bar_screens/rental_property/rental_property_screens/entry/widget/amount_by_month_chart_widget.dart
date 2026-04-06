import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/auth_view_model/auth_view_model.dart';

class AmountByMonthChartWidget extends StatelessWidget {
  final List<double> income;
  final List<double> expense;

  const AmountByMonthChartWidget({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();

    // Calculate maxY and interval
    double maxY = _calculateMaxY();
    double interval = _calculateInterval(maxY);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate("amountMonthText") ?? '',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 900,
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: RotatedBox(
                      quarterTurns: 1,
                      child:Text(
                          '\$ (Amount)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ),
                    axisNameSize:30,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: Utils.setHeight(context) * 0.06,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        // All-zero case: only show multiples of 0.2
                        if (income.every((e) => e == 0) &&
                            expense.every((e) => e == 0)) {
                          if (value < 0 || value > 2) return Container();
                          if ((value * 10).round() % 2 != 0) return SizedBox();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                          );
                        }

                        // Normal case
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            "\$${value.toStringAsFixed(maxY < 1 ? 2 : 0)}",
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final locale = Localizations.localeOf(context).languageCode;
                        final months = locale == 'fr'
                            ? [
                          'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                          'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
                        ]
                            : [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                        ];
                        if (value.toInt() < 0 || value.toInt() > 11)
                          return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            months[value.toInt()],
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (index) {
                  double barIncome = index < income.length ? income[index] : 0;
                  double barExpense =
                      index < expense.length ? expense[index] : 0;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 14,
                    barRods: [
                      BarChartRodData(
                        toY: barIncome,
                        color: Colors.blue,
                        width: 12,
                        borderRadius: BorderRadius.zero,
                      ),
                      BarChartRodData(
                        toY: barExpense,
                        color: AppColors.goldenOrangeColor,
                        width: 12,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateMaxY() {
    double highestIncome = income.isNotEmpty ? income.reduce(max) : 0;
    double highestExpense = expense.isNotEmpty ? expense.reduce(max) : 0;
    double maxY = max(highestIncome, highestExpense);

    if (maxY == 0) return 2000; // clean default

    // Round to nearest 1000 like website
    return ((maxY / 1000).ceil() * 1000).toDouble();
  }

  double _calculateInterval(double maxY) {
    return maxY / 5; // 5 equally spaced labels (clean)
  }
}
