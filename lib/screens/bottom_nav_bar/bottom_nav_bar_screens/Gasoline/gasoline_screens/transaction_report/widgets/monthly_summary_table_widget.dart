import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../../models/get_transaction_report_model/get_transaction_report_model.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';

class MonthlyTransactionTable extends StatelessWidget {
  final Map<String, GroupedTransactionData> groupedTransactions;

  const MonthlyTransactionTable({super.key, required this.groupedTransactions});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (groupedTransactions.isEmpty) {
      return Center(
        child: Text(
          "No Transactions Available",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    /// Keep API order
    final months = groupedTransactions.keys.toList();

    // Wrap everything in horizontal scroll to avoid tiny overflows
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            months.map((monthKey) {
              final group = groupedTransactions[monthKey];
              final transactions = group?.transactions ?? [];
              final summary = group?.summary;

              return SizedBox(
                width:
                    MediaQuery.of(
                      context,
                    ).size.width, // ensure full screen width
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.mediumGrayColor,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Month Header
                      Text(
                        monthKey,
                        overflow:
                            TextOverflow.ellipsis, // prevent overflow warning
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Scrollable DataTable
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 600),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              AppColors.goldenOrangeColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            columns: [
                              _col('Date'),
                              _col(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("merchantText") ??
                                    '',
                              ),
                              _col(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("beforeTText") ??
                                    '',
                              ),
                              if (auth.user?.regCountry == "ca") ...[
                                _col(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("gst/hstText") ??
                                      '',
                                ),
                                _col(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("pstText") ??
                                      '',
                                ),
                              ],
                              _col(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("taxText") ??
                                    '',
                              ),
                              _col('Total'),
                            ],
                            rows: [
                              ...transactions.map((tx) {
                                final date = DateTime.tryParse(
                                  tx.dateRecieved ?? '',
                                );
                                final formattedDate =
                                    date != null
                                        ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                                        : '';
                                return DataRow(
                                  cells: [
                                    _cell(formattedDate),
                                    _cell(tx.merchant ?? ''),
                                    _cell(
                                      "\$${(tx.beforeTaxAmount ?? 0).toStringAsFixed(2)}",
                                    ),
                                    if (auth.user?.regCountry == "ca") ...[
                                      _cell(
                                        "\$${(tx.gst ?? 0).toStringAsFixed(2)}",
                                      ),
                                      _cell(
                                        "\$${(tx.pst ?? 0).toStringAsFixed(2)}",
                                      ),
                                    ],
                                    _cell(
                                      "\$${(tx.tax ?? 0).toStringAsFixed(2)}",
                                    ),
                                    _cell(
                                      "\$${(tx.total ?? 0).toStringAsFixed(2)}",
                                    ),
                                  ],
                                );
                              }),
                              if (summary != null)
                                DataRow(
                                  color: MaterialStateProperty.all(
                                    AppColors.goldenOrangeColor.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  cells: [
                                    _boldCell('Total'),
                                    const DataCell(Text('')),
                                    _boldCell(
                                      "\$${summary.totalBeforeTax?.toStringAsFixed(2) ?? '0.00'}",
                                    ),
                                    if (auth.user?.regCountry == "ca") ...[
                                      _boldCell(
                                        "\$${summary.totalGstHst?.toStringAsFixed(2) ?? '0.00'}",
                                      ),
                                      _boldCell(
                                        "\$${summary.totalPst?.toStringAsFixed(2) ?? '0.00'}",
                                      ),
                                    ],
                                    _boldCell(
                                      "\$${summary.totalTax?.toStringAsFixed(2) ?? '0.00'}",
                                    ),
                                    _boldCell(
                                      "\$${summary.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// Helpers
  DataColumn _col(String text) => DataColumn(
    label: Text(
      text,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13),
      overflow: TextOverflow.ellipsis,
    ),
  );

  DataCell _cell(String text) => DataCell(
    Text(
      text,
      style: GoogleFonts.montserrat(fontSize: 13),
      overflow: TextOverflow.ellipsis,
    ),
  );

  DataCell _boldCell(String text) => DataCell(
    Text(
      text,
      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
