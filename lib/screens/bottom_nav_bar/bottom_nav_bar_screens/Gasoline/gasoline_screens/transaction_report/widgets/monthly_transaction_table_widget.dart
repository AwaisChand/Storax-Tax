import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_transaction_report_model/get_transaction_report_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../view_models/auth_view_model/auth_view_model.dart';

class MerchantTransactionTable extends StatelessWidget {
  final List<Transactions> transactions;

  final double totalBeforeTax;
  final double totalTax;
  final double totalAmount;
  final double totalGstHst;
  final double totalPst;

  const MerchantTransactionTable({
    super.key,
    required this.transactions,
    required this.totalBeforeTax,
    required this.totalTax,
    required this.totalAmount,
    required this.totalGstHst,
    required this.totalPst,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context)!.translate("noTransAvailable") ?? '',
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          return DataTable(
            columnSpacing: 20,
            headingRowHeight: 40,
            dataRowHeight: 45,
            columns: _buildColumns(auth, context),
            rows: [
              ...transactions.map((t) => _buildRow(auth, t)),
              _buildTotalRow(auth),
            ],
          );
        },
      ),
    );
  }

  // -------------------- COLUMNS --------------------
  List<DataColumn> _buildColumns(AuthViewModel auth, context) {
    TextStyle headerStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return [
      DataColumn(
        label: SizedBox(width: 90, child: Text("Date", style: headerStyle)),
      ),
      DataColumn(
        label: SizedBox(
          width: 120,
          child: Text(
            AppLocalizations.of(context)!.translate("merchantText") ?? '',
            style: headerStyle,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 90,
          child: Text(
            AppLocalizations.of(context)!.translate("refText") ?? '',
            style: headerStyle,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 90,
          child: Text(
            AppLocalizations.of(context)!.translate("beforeTText") ?? '',
            style: headerStyle,
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
                fontWeight: FontWeight.w600,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      DataColumn(
        label: SizedBox(
          width: 80,
          child: Text(
            AppLocalizations.of(context)!.translate("totalTaxText") ?? '',
            style: headerStyle,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 80,
          child: Text(
            AppLocalizations.of(context)!.translate("totalText") ?? '',
            style: headerStyle,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 60,
          child: Text(
            AppLocalizations.of(context)!.translate("statusText") ?? '',
            style: headerStyle,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(width: 50, child: Text("Actions", style: headerStyle)),
      ),
    ];
  }

  DataRow _buildRow(AuthViewModel auth, Transactions t) {
    TextStyle cellStyle = GoogleFonts.poppins(fontSize: 12);

    return DataRow(
      cells: [
        DataCell(Text(t.dateRecieved ?? '-', style: cellStyle)),
        DataCell(Text(t.merchant ?? '-', style: cellStyle)),
        DataCell(Text(t.reference ?? '-', style: cellStyle)),
        DataCell(
          Text(
            "\$${(t.beforeTaxAmount ?? 0).toStringAsFixed(2)}",
            style: cellStyle,
          ),
        ),
        if (auth.user?.regCountry == "ca") ...[
          DataCell(Text("\$${t.gst?.toStringAsFixed(2)}", style: cellStyle)),
          DataCell(Text("\$${t.pst?.toStringAsFixed(2)}", style: cellStyle)),
        ],
        DataCell(
          Text("\$${(t.tax ?? 0).toStringAsFixed(2)}", style: cellStyle),
        ),
        DataCell(
          Text("\$${(t.total ?? 0).toStringAsFixed(2)}", style: cellStyle),
        ),
        DataCell(
          Text(
            t.status ?? '-',
            style: cellStyle.copyWith(
              color: t.status == "Approved" ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.remove_red_eye, size: 18),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  DataRow _buildTotalRow(AuthViewModel auth) {
    TextStyle totalStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return DataRow(
      color: WidgetStateProperty.all(Colors.grey.shade100),
      cells: [
        DataCell(Text("Total", style: totalStyle)),
        const DataCell(Text("")),
        const DataCell(Text("")),
        DataCell(
          Text("\$${totalBeforeTax.toStringAsFixed(2)}", style: totalStyle),
        ),
        if (auth.user?.regCountry == "ca") ...[
          DataCell(
            Text("\$${totalGstHst.toStringAsFixed(2)}", style: totalStyle),
          ),
          DataCell(Text("\$${totalPst.toStringAsFixed(2)}", style: totalStyle)),
        ],
        DataCell(Text("\$${totalTax.toStringAsFixed(2)}", style: totalStyle)),
        DataCell(
          Text("\$${totalAmount.toStringAsFixed(2)}", style: totalStyle),
        ),
        const DataCell(Text("")),
        const DataCell(Text("")),
      ],
    );
  }
}
