import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../../models/get_gasoline_report_model/get_gasoline_report_model.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class AmountByMonthChart extends StatelessWidget {
  const AmountByMonthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final gasoline = context.watch<GasolineViewModel>();
    final monthlyData = gasoline.monthlySummary;
    final plans = Provider.of<PricingPlansViewModel>(context, listen: false);
    final planNames =
    plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
    final isFreeGasPlan = planNames.any(
          (n) => n.contains('free version') || n.contains('basic'),
    );

    final locale = Localizations.localeOf(context).languageCode;

    const monthsEn = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    const monthsFr = [
      'Janvier', 'Février', 'Mars', 'Avril',
      'Mai', 'Juin', 'Juillet', 'Août',
      'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];

    final months = locale == 'fr' ? monthsFr : monthsEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: Utils.setHeight(context) * 0.35,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 900,
              child: BarChart(
                BarChartData(
                  maxY: _calculateMaxY(monthlyData, isFreeGasPlan),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: Utils.setHeight(context) * 0.05,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              months[value.toInt()],
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(width: 1),
                      left: BorderSide(width: 1),
                    ),
                  ),
                  barGroups: _buildBarGroups(monthlyData, isFreeGasPlan),
                  barTouchData: BarTouchData(enabled: false),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue, 'Total Amount'),
            if (!isFreeGasPlan) ...[
              const SizedBox(width: 16),
              _buildLegendItem(Colors.orange, 'Total Tax'),
            ],
          ],
        ),
      ],
    );
  }

  double _calculateMaxY(List<MonthlySummary> data, bool isFree) {
    double maxY = 0;
    for (var item in data) {
      num total = isFree
          ? (item.totalAmount ?? 0)
          : (item.beforeTaxAmount ?? 0) + (item.totalTax ?? 0);
      if (total > maxY) maxY = total.toDouble();
    }
    return (maxY * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups(List<MonthlySummary> data, bool isFree) {
    return [
      for (int i = 0; i < data.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isFree
                  ? data[i].totalAmount!.toDouble()
                  : data[i].beforeTaxAmount!.toDouble(),
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.zero,
            ),
            if (!isFree)
              BarChartRodData(
                toY: data[i].totalTax!.toDouble(),
                color: Colors.orange,
                width: 12,
                borderRadius: BorderRadius.zero,
              ),
          ],
          barsSpace: 14,
        ),
    ];
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
