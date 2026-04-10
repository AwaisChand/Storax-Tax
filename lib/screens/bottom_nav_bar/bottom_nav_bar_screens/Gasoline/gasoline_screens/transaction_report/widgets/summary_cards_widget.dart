import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';

class SummaryCardsWidget extends StatelessWidget {
  final GasolineViewModel gasoline;

  const SummaryCardsWidget({super.key, required this.gasoline});

  @override
  Widget build(BuildContext context) {
    final kpStats = gasoline.getTransactionReportModel?.data?.kpiStats;

    // Collect all progress values dynamically
    final kpiProgressValues = [
      kpStats?.totalTransactions?.progress ?? 0,
      kpStats?.totalAmount?.progress ?? 0,
      kpStats?.totalTax?.progress ?? 0,
      kpStats?.totalBeforeTax?.progress ?? 0,
    ];

    // Find the maximum progress for scaling
    final double maxProgress =
    kpiProgressValues.isNotEmpty
        ? kpiProgressValues.reduce((a, b) => a > b ? a : b)
        : 100;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _cardWidget(
              AppLocalizations.of(context)!.translate("totalTransText") ?? '',
              "${kpStats?.totalTransactions?.value?.toStringAsFixed(0)}",
              "${kpStats?.totalTransactions?.badgeValue}",
              Icons.assignment_outlined,
              Color(0xFF51d88a),
              Color(0xFF51d88a),
              Color(0xFF51d88a),
              subText: "${kpStats?.totalTransactions?.badgeLabel}",
              progress: normalizedProgress(
                kpStats?.totalTransactions?.progress ?? 0,
                maxProgress,
              ),
              progressColor: Color(0xFF51d88a),
            ),
            _cardWidget(
              AppLocalizations.of(context)!.translate("totalAmountText") ?? '',
              "\$${kpStats?.totalAmount?.value?.toStringAsFixed(2)}",
              "${kpStats?.totalAmount?.badgeValue}",
              Icons.attach_money,
              Color(0xFF51d88a),
              Color(0xFF51d88a),
              Color(0xFF51d88a),
              subText: "${kpStats?.totalAmount?.badgeLabel}",
              progress: normalizedProgress(
                kpStats?.totalAmount?.progress ?? 0,
                maxProgress,
              ),
              progressColor: Color(0xFF51d88a),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _cardWidget(
              AppLocalizations.of(context)!.translate("totalTaxText") ?? '',
              "\$${kpStats?.totalTax?.value?.toStringAsFixed(2)}",
              "${kpStats?.totalTax?.badgeValue}",
              Icons.percent,
              Color(0xFFffc107),
              Color(0xFFffc107),
              Color(0xFFffc107),
              subText: "${kpStats?.totalTax?.badgeLabel}",
              progress: normalizedProgress(
                kpStats?.totalTax?.progress ?? 0,
                maxProgress,
              ),
              progressColor: Color(0xFFffc107),
            ),
            _cardWidget(
              AppLocalizations.of(context)!.translate("beforeTText") ?? '',
              "\$${kpStats?.totalBeforeTax?.value?.toStringAsFixed(2)}",
              "${kpStats?.totalBeforeTax?.badgeValue}",
              Icons.calculate,
              Color(0xFF17a2b8),
              Color(0xFF17a2b8),
              Color(0xFF17a2b8),
              subText: "${kpStats?.totalBeforeTax?.badgeLabel}",
              progress: normalizedProgress(
                kpStats?.totalBeforeTax?.progress ?? 0,
                maxProgress,
              ),
              progressColor: Color(0xFF17a2b8),
            ),
          ],
        ),
      ],
    );
  }

  // Normalize progress relative to the max value
  double normalizedProgress(double value, double maxValue) {
    if (maxValue == 0) return 0.0;
    return (value / maxValue).clamp(0.0, 1.0);
  }

  Widget _cardWidget(
      String title,
      String mainValue,
      String badgeValue,
      IconData icon,
      Color badgeColor,
      Color badgeBgColor,
      Color textColor, {
        String? subText,
        double? progress,
        Color? progressColor,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumGrayColor,
                    ),
                  ),
                ),
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: AppColors.whiteColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              mainValue,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  height: 18,
                  width: 45,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeValue,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                if (subText != null)
                  Expanded(
                    child: Text(
                      subText,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mediumGrayColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress line
            if (progress != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: (progressColor ?? textColor).withOpacity(
                    0.3,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? textColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
