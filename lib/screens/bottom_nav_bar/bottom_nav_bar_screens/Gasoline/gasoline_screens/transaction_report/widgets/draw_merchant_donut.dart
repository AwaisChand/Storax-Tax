import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

Widget merchantDonutChart(List<dynamic> merchants) {
  if (merchants.isEmpty) return const SizedBox.shrink();

  // find max total
  final maxTotal = merchants.fold<double>(
    0,
        (prev, m) => (m.total ?? 0) > prev ? (m.total ?? 0) : prev,
  );

  // 🔥 sort: lower value first → green first
  final sortedMerchants = List.of(merchants)
    ..sort((a, b) => (a.total ?? 0).compareTo(b.total ?? 0));

  return SizedBox(
    height: 120,
    child: PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,

        // ⭐ rotate chart so first section starts from LEFT
        startDegreeOffset: 180,

        sections: sortedMerchants.map((m) {
          final value = (m.total ?? 0).toDouble();
          final isMax = value == maxTotal;

          return PieChartSectionData(
            value: value,
            color: isMax ? Colors.blue : Colors.greenAccent,
            radius: 18,
            showTitle: false,
          );
        }).toList(),
      ),
    ),
  );
}

Widget merchantLegend(GasolineViewModel gasolineVM) {
  final merchants = List.of(
    gasolineVM
        .getTransactionReportModel!
        .data!
        .charts!
        .merchantDistribution!,
  );

  final maxTotal = merchants.fold<double>(
    0,
        (prev, m) => (m.total ?? 0) > prev ? (m.total ?? 0) : prev,
  );

  merchants.sort(
        (a, b) => (b.total ?? 0).compareTo(a.total ?? 0),
  );

  return Padding(
    padding: const EdgeInsets.only(right: 25, left: 25),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: merchants.map((m) {
        final isMax = (m.total ?? 0) == maxTotal;
        final color = isMax ? Colors.blue : Colors.greenAccent;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                m.merchant ?? '',
                style: GoogleFonts.montserrat(fontSize: 11),
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}


