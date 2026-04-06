import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../transaction_report_screen/transaction_report_screen.dart';
import 'bar_chart_widget.dart';
import 'draw_merchant_donut.dart';
import 'line_chart_widget.dart';
import 'monthly_summary_table_widget.dart';
import 'monthly_transaction_table_widget.dart';

class ChartSelectorWidget extends StatefulWidget {
  final GasolineViewModel gasoline;

  const ChartSelectorWidget({super.key, required this.gasoline});

  @override
  State<ChartSelectorWidget> createState() => _ChartSelectorState();
}

class _ChartSelectorState extends State<ChartSelectorWidget> {
  ChartType selectedChart = ChartType.line;
  bool showTotal = true;
  bool showTax = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.translate("monthlyGasText") ?? '',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => selectedChart = ChartType.line),
                  child: _chartIcon(
                    Icons.show_chart,
                    selectedChart == ChartType.line,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => setState(() => selectedChart = ChartType.bar),
                  child: _chartIcon(
                    Icons.short_text,
                    selectedChart == ChartType.bar,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height:
              (!showTotal && !showTax)
                  ? Utils.setHeight(context) * 0.16
                  : Utils.setHeight(context) * 0.46,
          width: double.infinity,
          padding: EdgeInsets.only(top: 20, right: 20, left: 20),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.mediumGrayColor, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    selectedChart == ChartType.line
                        ? [
                          _rowWidget(
                            AppLocalizations.of(
                                  context,
                                )!.translate("totalAmountText") ??
                                '',
                            Colors.blue,
                            showTotal,
                            () => setState(() => showTotal = !showTotal),
                          ),
                          const SizedBox(width: 8),
                          _rowWidget(
                            AppLocalizations.of(
                                  context,
                                )!.translate("taxAmountText") ??
                                '',
                            AppColors.goldenOrangeColor,
                            showTax,
                            () => setState(() => showTax = !showTax),
                          ),
                        ]
                        : [
                          _rowWidgetForBar(
                            AppLocalizations.of(
                                  context,
                                )!.translate("totalAmountText") ??
                                '',
                            Colors.blue,
                            showTotal,
                            () => setState(() => showTotal = !showTotal),
                          ),
                          const SizedBox(width: 8),
                          _rowWidgetForBar(
                            AppLocalizations.of(
                                  context,
                                )!.translate("taxAmountText") ??
                                '',
                            AppColors.goldenOrangeColor,
                            showTax,
                            () => setState(() => showTax = !showTax),
                          ),
                        ],
              ),
              SizedBox(height: 5),
              (!showTotal && !showTax)
                  ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate("noDataText") ??
                          '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        height: 2,
                      ),
                    ),
                  )
                  : selectedChart == ChartType.line
                  ? buildLineChart(
                    widget.gasoline,
                    context,
                    showTotal: showTotal,
                    showTax: showTax,
                  )
                  : MonthlyBarChart(showTotal: showTotal, showTax: showTax),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _monthlyInsightsWidget(
                    AppLocalizations.of(context)!.translate("hMonthText") ?? '',
                    "${widget.gasoline.getTransactionReportModel?.data?.charts?.monthlyInsights?.highestMonth}",
                  ),
                  _monthlyInsightsWidget(
                    AppLocalizations.of(context)!.translate("mAverageText") ??
                        '',
                    "\$${widget.gasoline.getTransactionReportModel?.data?.charts?.monthlyInsights?.monthlyAverage}",
                  ),
                  _monthlyInsightsWidget(
                    AppLocalizations.of(context)!.translate("trendText") ?? '',
                    "${widget.gasoline.getTransactionReportModel?.data?.charts?.monthlyInsights?.trend}",
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 5,
            right: 20,
            left: 20,
            bottom: 8,
          ),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.mediumGrayColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.translate("merchantText") ?? '',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 2,
                ),
              ),

              /// 🔵 DONUT CHART
              merchantDonutChart(
                widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.charts
                        ?.merchantDistribution ??
                    [],
              ),

              const SizedBox(height: 12),

              /// 🔹 LEGEND
              merchantLegend(widget.gasoline),

              const SizedBox(height: 16),

              /// Bottom stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _topMerchantWidget(
                      AppLocalizations.of(context)!.translate("merchantText") ??
                          '',
                      widget
                              .gasoline
                              .getTransactionReportModel
                              ?.data
                              ?.charts
                              ?.topMerchant
                              ?.name ??
                          '',
                    ),
                  ),
                  Expanded(
                    child: _topMerchantWidget(
                      AppLocalizations.of(context)!.translate("transText") ?? '',
                      "${widget.gasoline.getTransactionReportModel?.data?.charts?.topMerchant?.transactionCount ?? 0}",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 10,
            right: 20,
            left: 20,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.mediumGrayColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.translate("transDetailsText") ??
                    '',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 2,
                ),
              ),
              MerchantTransactionTable(
                transactions:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.transactions ??
                    [],
                totalBeforeTax:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.summary
                        ?.totalBeforeTax ??
                    0.00,
                totalTax:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.summary
                        ?.totalTax ??
                    0.0,
                totalAmount:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.summary
                        ?.totalAmount ??
                    0.0,
                totalGstHst:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.summary
                        ?.totalGstHst ??
                    0.0,

                totalPst:
                    widget
                        .gasoline
                        .getTransactionReportModel
                        ?.data
                        ?.summary
                        ?.totalPst ??
                    0.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        MonthlyTransactionTable(
          groupedTransactions:
              widget
                  .gasoline
                  .getTransactionReportModel
                  ?.data
                  ?.groupedTransactions ??
              {},
        ),
      ],
    );
  }

  Widget _topMerchantWidget(String text1, text2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text1,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: AppColors.mediumGrayColor,
          ),
        ),
        Text(
          text2,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _monthlyInsightsWidget(String text1, text2) {
    return Column(
      children: [
        Text(
          text1,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: AppColors.mediumGrayColor,
          ),
        ),
        Text(
          text2,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _rowWidget(
    String labelText,
    Color color,
    bool isVisible,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 10,
            width: 25,
            decoration: BoxDecoration(
              border: Border.all(
                color: isVisible ? color : color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            labelText,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isVisible ? AppColors.blackColor : Colors.grey,
              decoration:
                  isVisible ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidgetForBar(
    String labelText,
    Color color,
    bool isVisible,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 10,
            width: 25,
            color: isVisible ? color : color.withOpacity(0.3),
          ),
          const SizedBox(width: 5),
          Text(
            labelText,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isVisible ? AppColors.blackColor : Colors.grey,
              decoration:
                  isVisible ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartIcon(IconData icon, bool isSelected) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.goldenOrangeColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black,
        size: 23,
      ),
    );
  }
}
