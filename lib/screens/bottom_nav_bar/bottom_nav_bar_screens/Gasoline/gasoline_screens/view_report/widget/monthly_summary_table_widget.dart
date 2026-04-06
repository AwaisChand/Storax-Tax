import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../../models/get_gasoline_report_model/get_gasoline_report_model.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class MonthlySummaryTable extends StatelessWidget {
  final List<MonthlySummary> summary;

  const MonthlySummaryTable({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final plans = Provider.of<PricingPlansViewModel>(context, listen: false);
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
    final isFreeGasPlan = planNames.any(
      (n) => n.contains('free version') || n.contains('basic'),
    );

    // Grand total for Total Amount only
    final grandTotalAmount = summary.fold(
      0.0,
      (sum, item) => sum + (item.totalAmount ?? 0),
    );

    return Column(
      children: [
        const SizedBox(height: 30),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(
                label: Text(
                  AppLocalizations.of(context)!.translate("monthText") ?? '',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context)!.translate("totalAmountText") ??
                      '',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isFreeGasPlan) ...[
                DataColumn(
                  label: Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("beforeTaxText") ??
                        '',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (auth.user?.regCountry == "ca") ...[
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context)!.translate("gst/hstText") ?? '',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context)!.translate("pstText") ?? '',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.translate("totalTaxText") ??
                        '',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            rows: [
              ...summary.map((month) {
                List<DataCell> cells = [
                  DataCell(
                    Text(
                      month.month ?? '',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      "\$${month.totalAmount?.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ];

                if (!isFreeGasPlan) {
                  cells.addAll([
                    DataCell(
                      Text(
                        "\$${month.beforeTaxAmount?.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    if (auth.user?.regCountry == "ca") ...[
                      DataCell(
                        Text(
                          "\$${month.gst?.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "\$${month.pst?.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                    DataCell(
                      Text(
                        "\$${month.totalTax?.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ]);
                }

                return DataRow(cells: cells);
              }),

              // Grand Total row
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      AppLocalizations.of(
                            context,
                          )!.translate("grandTotalText") ??
                          '',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      "\$${grandTotalAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (!isFreeGasPlan) ...[
                    DataCell(
                      Text(
                        "\$${summary.fold(0.0, (sum, item) => sum + (item.beforeTaxAmount ?? 0)).toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (auth.user?.regCountry == "ca") ...[
                      DataCell(
                        Text(
                          "\$${summary.fold(0.0, (sum, item) => sum + (item.gst ?? 0)).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "\$${summary.fold(0.0, (sum, item) => sum + (item.pst ?? 0)).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    DataCell(
                      Text(
                        "\$${summary.fold(0.0, (sum, item) => sum + (item.totalTax ?? 0)).toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
