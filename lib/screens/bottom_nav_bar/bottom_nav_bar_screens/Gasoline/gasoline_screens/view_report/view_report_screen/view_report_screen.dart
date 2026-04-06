import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/view_report/widget/build_multiple_buttons.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import '../widget/amount_by_month_widget.dart';
import '../widget/gasoline_report_filter_dialog.dart';
import '../widget/monthly_summary_table_widget.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context).languageCode;
      context.read<GasolineViewModel>().getGasolineReportApi(
        context,
        language: locale,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.read<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
    final isFreeGasPlan = planNames.any(
      (n) => n.contains('free version') || n.contains('basic'),
    );
    return Consumer<GasolineViewModel>(
      builder: (context, gasoline, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("allGraphicEntryText") ??
                '',
            text2: AppLocalizations.of(context)!.translate("viewRepText") ?? '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GasolineListScreen()),
              );
            },
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
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          gasoline.isLoading
                              ? SizedBox(
                                height: Utils.setHeight(context),
                                child: Center(
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ),
                              )
                              : Column(
                                children: [
                                  const SizedBox(height: 20),
                                  buildGasolineReportFilterBar(context),
                                  const SizedBox(height: 20),
                                  if (!isFreeGasPlan)
                                    buildForwardGasolineReportMultipleButton(
                                      context,
                                    ),
                                  const SizedBox(height: 30),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("amountMonthText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const AmountByMonthChart(),
                                  MonthlySummaryTable(
                                    summary: gasoline.monthlySummary,
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
