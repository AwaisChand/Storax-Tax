import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_potiential_deduction_screen.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/static_values_widget.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class ViewIncomeBreakdownScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const ViewIncomeBreakdownScreen({super.key, required this.quebecModel});

  @override
  State<ViewIncomeBreakdownScreen> createState() =>
      _ViewIncomeBreakdownScreenState();
}

class _ViewIncomeBreakdownScreenState extends State<ViewIncomeBreakdownScreen> {
  double quickAccounting = 0.00;
  double gstUber = 0.00;
  double qstUber = 0.00;
  final gstController = TextEditingController();
  final qstController = TextEditingController();
  double otherTaxable = 0.00;
  double otherMiscellaneous = 0.00;

  @override
  void initState() {
    super.initState();
    quickAccounting = widget.quebecModel.quickAccountingMethod6085;
    gstUber = widget.quebecModel.gstCollectedFromUberSec5;
    qstUber = widget.quebecModel.qstCollectedFromUberSec5;
    gstController.text = widget.quebecModel.uberGstRegistrationNumberSec5;
    qstController.text = widget.quebecModel.uberQstRegistrationNumberSec5;
    otherTaxable = widget.quebecModel.otherTaxableIncome;
    otherMiscellaneous = widget.quebecModel.otherIncomeMiscellaneous;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text3: AppLocalizations.of(context)!.translate("docTitleText") ?? '',
        text1: 'UBER',
        text2: AppLocalizations.of(context)!.translate("taxSummaryPeriodText") ?? '',
        showBackButton: true,
        onBackTap: () {
          Navigator.pop(context);
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
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaticNameYearInputField(
                    selectedYear: widget.quebecModel.year,
                    name: widget.quebecModel.name,
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.translate("otherIncomeText") ?? '',                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate("incomeDescText") ?? '',                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("quickAccountingText") ?? '',
                    widget.quebecModel.quickAccountingMethod6085,
                  ),
                  SizedBox(height: 12),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("miscText") ?? '',
                    widget.quebecModel.otherIncomeMiscellaneous,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstUberC") ?? '',
                    widget.quebecModel.gstCollectedFromUberSec5,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstUberC") ?? '',
                    widget.quebecModel.qstCollectedFromUberSec5,
                  ),
                  SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(
                    value:
                        quickAccounting +
                        otherMiscellaneous +
                        gstUber +
                        qstUber,
                  ),
                  SizedBox(height: 10),
                  _labelText(AppLocalizations.of(context)!.translate("gstNumText") ?? ''),
                  const SizedBox(height: 4),
                  StaticTextField(
                    text: widget.quebecModel.uberGstRegistrationNumberSec5,
                  ),
                  SizedBox(height: 10),
                  _labelText(AppLocalizations.of(context)!.translate("qstNumText") ?? ''),
                  const SizedBox(height: 4),
                  StaticTextField(
                    text: widget.quebecModel.uberQstRegistrationNumberSec5,
                  ),
                  // const SizedBox(height: 10),
                  // _valuesViewsWidget(
                  //   "Other Taxable Income",
                  //   widget.quebecModel.otherTaxableIncome,
                  // ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        height: 40,
                        color: AppColors.lightPinkColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("prevText") ?? '',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        height: 40,
                        color: AppColors.goldenOrangeColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () {
                          // Update QuebecModel with new values for step 5
                          final updatedModel = widget.quebecModel.copyWith(
                            id: widget.quebecModel.id,
                            quickAccountingMethod6085: quickAccounting,
                            gstCollectedFromUber: gstUber,
                            qstCollectedFromUber: qstUber,
                            uberGstRegistrationNumberSec5: 'XXXXXXXXXRT0001',
                            uberQstRegistrationNumberSec5: 'XXXXXXXXXTQ0001',
                            otherIncomeMiscellaneous: otherMiscellaneous,
                          );
                          debugPrint(
                            "===== QuebecModel being sent to PotentialDeduction =====",
                          );
                          debugPrint(updatedModel.toJson().toString());
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (context) => ViewPotentialDeductionScreen(
                                    quebecModel: updatedModel,
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("nextText") ?? '',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valuesViewsWidget(String label, double values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        StaticValuesWidget(value: values, currencyText: 'CA\$'),
      ],
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
