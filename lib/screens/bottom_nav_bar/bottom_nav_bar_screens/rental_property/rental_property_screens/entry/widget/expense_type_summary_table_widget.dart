import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../models/rental_property_models/database_entry_model/database_entry_model.dart';
import '../../../../../../../res/components/app_localization.dart';

class ExpenseTypeTableWidget extends StatelessWidget {
  final List<ExpenseByCategory> expenseList;

  const ExpenseTypeTableWidget({super.key, required this.expenseList});

  double parsedAmount(String? amountStr) {
    return double.tryParse(amountStr ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = expenseList.fold<double>(
      0.0,
      (sum, item) => sum + parsedAmount(item.amount.toString()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.translate("expenseType") ?? '',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.of(context)!.translate("amountText") ?? '',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),

        /// Table Rows
        for (var expense in expenseList) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(

                    expense.expenseCategory ?? 'N/A',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "\$${parsedAmount(expense.amount.toString()).toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
        ],

        const SizedBox(height: 12),

        /// Grand Total
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
    );
  }
}
