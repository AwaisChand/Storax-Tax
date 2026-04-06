import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/widgets/transaction_report_content_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import '../../../../../../../../res/app_assets.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import '../../../../../../../res/components/app_localization.dart';

enum ChartType { line, bar }

class TransactionReportScreen extends StatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  State<TransactionReportScreen> createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GasolineViewModel>().getTransactionReportApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
    final isFreeGasPlan = planNames.any(
      (n) => n.contains('free version') || n.contains('basic'),
    );

    return Scaffold(
      appBar: CustomAppBar(
        text1: AppLocalizations.of(context)!.translate("transReport") ?? '',
        text2: AppLocalizations.of(context)!.translate("descTransReport") ?? '',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Consumer<GasolineViewModel>(
            builder: (context, gasoline, _) {
              if (gasoline.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.blackColor,
                    ),
                  ),
                );
              }

              if (gasoline.getTransactionReportModel?.data == null) {
                return Center(
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("noTransReportText") ??
                        '',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mediumGrayColor,
                    ),
                  ),
                );
              }

              return TransactionReportContentWidget(
                gasoline: gasoline,
                isFreeGasPlan: isFreeGasPlan,
              );
            },
          ),
        ],
      ),
    );
  }
}
