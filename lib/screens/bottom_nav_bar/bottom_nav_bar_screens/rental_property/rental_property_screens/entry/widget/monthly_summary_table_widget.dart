import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../res/components/app_localization.dart';

class MonthlySummaryTableWidget extends StatelessWidget {
  final List<double> income;
  final List<double> expense;

  const MonthlySummaryTableWidget({
    super.key,
    required this.income,
    required this.expense,
  });

  /// Always shows positive currency
  String formatCurrency(double value) {
    return "\$${value.abs().toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    /// English months
    const monthsEn = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    /// French months
    const monthsFr = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];

    final List<String> months = locale == 'fr' ? monthsFr : monthsEn;

    /// Safe lists (always 12 months)
    final List<double> safeIncome =
    List.generate(12, (i) => i < income.length ? income[i] : 0.0);

    final List<double> safeExpense =
    List.generate(12, (i) => i < expense.length ? expense[i] : 0.0);

    final double totalIncome = safeIncome.fold(0.0, (a, b) => a + b);
    final double totalExpense = safeExpense.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        const SizedBox(height: 30),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: DataTable(
              columnSpacing: 20,
              columns: [
                _buildColumn(
                  AppLocalizations.of(context)!
                      .translate("monthText") ??
                      '',
                ),
                _buildColumn(
                  AppLocalizations.of(context)!
                      .translate("incomeText") ??
                      '',
                ),
                _buildColumn(
                  AppLocalizations.of(context)!
                      .translate("expenseText") ??
                      '',
                ),
                _buildColumn("Total"),
              ],
              rows: [
                /// Monthly rows
                for (int i = 0; i < 12; i++)
                  DataRow(
                    cells: [
                      _buildCell(months[i]),
                      _buildCell(formatCurrency(safeIncome[i])),
                      _buildCell(formatCurrency(safeExpense[i])),
                      _buildCell(
                        formatCurrency(safeIncome[i] - safeExpense[i]),
                      ),
                    ],
                  ),

                /// Grand total row
                DataRow(
                  cells: [
                    _buildBoldCell(
                      AppLocalizations.of(context)!
                          .translate("grandTotalText") ??
                          '',
                    ),
                    _buildBoldCell(formatCurrency(totalIncome)),
                    _buildBoldCell(formatCurrency(totalExpense)),
                    _buildBoldCell(
                      formatCurrency(totalIncome - totalExpense),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
      ),
    );
  }

  DataCell _buildCell(String value) {
    return DataCell(
      Text(
        value,
        style: GoogleFonts.poppins(fontSize: 13),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  DataCell _buildBoldCell(String value) {
    return DataCell(
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
