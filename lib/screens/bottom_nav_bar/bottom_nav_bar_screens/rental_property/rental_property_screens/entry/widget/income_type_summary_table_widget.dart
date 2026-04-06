import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../models/rental_property_models/database_entry_model/database_entry_model.dart';
import '../../../../../../../res/components/app_localization.dart';

class IncomeTypeTableWidget extends StatelessWidget {
  final List<IncomeByType> incomeByTypeList;

  const IncomeTypeTableWidget({super.key, required this.incomeByTypeList});

  double parsedAmount(String? amountStr) {
    return double.tryParse(amountStr ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = incomeByTypeList.fold<double>(
      0.0,
      (sum, item) => sum + parsedAmount(item.amount.toString()),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.translate("incomeTypeText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("totalAmountText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  numeric: true,
                ),
              ],
              rows:
                  incomeByTypeList.map((income) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            income.incomeType ?? 'N/A',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${parsedAmount(income.amount.toString()).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          const Divider(thickness: 1, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.translate("grandTotalText") ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "\$${grandTotal.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
