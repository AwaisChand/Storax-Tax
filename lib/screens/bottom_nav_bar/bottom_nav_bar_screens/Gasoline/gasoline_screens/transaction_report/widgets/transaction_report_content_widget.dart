import 'package:flutter/material.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/widgets/chart_selector_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/widgets/summary_cards_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/widgets/transaction_report_filter.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/widgets/transaction_report_multiple_button.dart';

import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';

class TransactionReportContentWidget extends StatelessWidget {
  final GasolineViewModel gasoline;
  final bool isFreeGasPlan;

  const TransactionReportContentWidget({
    super.key,
    required this.gasoline,
    required this.isFreeGasPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTransactionReportFilterBar(context),
          const SizedBox(height: 10),
          buildForwardTransactionReportMultipleButton(context),
          const SizedBox(height: 10),

          /// Summary Cards
          SummaryCardsWidget(gasoline: gasoline),

          const SizedBox(height: 20),

          /// Line / Bar Chart Toggle
          ChartSelectorWidget(gasoline: gasoline),
        ],
      ),
    );
  }
}
