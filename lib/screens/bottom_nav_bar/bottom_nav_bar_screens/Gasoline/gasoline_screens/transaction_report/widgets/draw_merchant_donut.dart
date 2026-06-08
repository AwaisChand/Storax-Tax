import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

/// ✅ HEX → COLOR CONVERTER
Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex";
  }
  return Color(int.parse(hex, radix: 16));
}

//////////////////////////////////////////////////////////////
/// 🔵 DONUT CHART
//////////////////////////////////////////////////////////////
Widget merchantDonutChart(List<dynamic> merchants) {
  if (merchants.isEmpty) return const SizedBox.shrink();

  return SizedBox(
    height: 140,
    child: PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 45,
        startDegreeOffset: -90, // matches screenshot

        sections: merchants.map((m) {
          return PieChartSectionData(
            value: (m.total ?? 0).toDouble(),
            color: hexToColor(m.color ?? "#cccccc"),
            radius: 20,
            showTitle: false,
          );
        }).toList(),
      ),
    ),
  );
}

//////////////////////////////////////////////////////////////
/// 🔹 LEGEND (EXACT MATCH)
//////////////////////////////////////////////////////////////
Widget merchantLegend(GasolineViewModel gasolineVM) {
  final merchants = List.of(
    gasolineVM
        .getTransactionReportModel!
        .data!
        .charts!
        .merchantDistribution!,
  );

  /// sort descending (like UI)
  merchants.sort(
        (a, b) => (b.total ?? 0).compareTo(a.total ?? 0),
  );

  return Column(
    children: merchants.map((m) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            /// 🔵 color dot
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: hexToColor(m.color ?? "#ccc"),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 8),

            /// 🧾 merchant name (ellipsis)
            Expanded(
              child: Text(
                m.merchant ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(fontSize: 11),
              ),
            ),

            /// 💰 amount RIGHT aligned
            Text(
              "\$${(m.total ?? 0).toStringAsFixed(2)}",
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

//////////////////////////////////////////////////////////////
/// 🔻 COMPLETE MERCHANT SECTION WIDGET
//////////////////////////////////////////////////////////////
Widget merchantSection(GasolineViewModel gasolineVM) {
  final merchants =
      gasolineVM
          .getTransactionReportModel
          ?.data
          ?.charts
          ?.merchantDistribution ??
          [];

  final topMerchant =
      gasolineVM
          .getTransactionReportModel
          ?.data
          ?.charts
          ?.topMerchant;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔤 TITLE
        Text(
          "Merchants",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 12),

        /// 🔵 DONUT
        merchantDonutChart(merchants),

        const SizedBox(height: 12),

        /// 🔹 LEGEND
        merchantLegend(gasolineVM),

        const SizedBox(height: 16),

        /// 🔻 BOTTOM INFO
        Row(
          children: [
            /// LEFT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Merchant",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    topMerchant?.name ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            /// RIGHT (🔥 FIXED)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Transactions",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${topMerchant?.transactionCount ?? 0}",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )      ],
    ),
  );
}