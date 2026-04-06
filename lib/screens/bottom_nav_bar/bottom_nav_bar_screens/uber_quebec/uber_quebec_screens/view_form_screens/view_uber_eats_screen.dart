import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_other_income_breakdown.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/static_values_widget.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class ViewUberEatsGrossScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const ViewUberEatsGrossScreen({super.key, required this.quebecModel});

  @override
  State<ViewUberEatsGrossScreen> createState() =>
      _ViewUberEatsGrossScreenState();
}

class _ViewUberEatsGrossScreenState extends State<ViewUberEatsGrossScreen> {
  double grossUber = 0.00;
  double tips = 0.00;
  double gstUber = 0.00;
  double qstUber = 0.00;

  @override
  void initState() {
    super.initState();
    grossUber = widget.quebecModel.grossUberEatsFare;
    tips = widget.quebecModel.eatsTips;
    gstUber = widget.quebecModel.gstCollectedFromUber;
    qstUber = widget.quebecModel.qstCollectedFromUber;
    gstController.text = widget.quebecModel.yourGstNumberSec4;
    qstController.text = widget.quebecModel.yourQstNumberSec4;
  }

  final gstController = TextEditingController();
  final qstController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text3: AppLocalizations.of(context)!.translate("docTitleText") ?? '',
        text1: 'UBER',
        text2:
            AppLocalizations.of(context)!.translate("taxSummaryPeriodText") ??
            '',
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
                    AppLocalizations.of(
                          context,
                        )!.translate("uberEatsGrossText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("uberEatsDescText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("grossUberText") ??
                        '',
                    widget.quebecModel.grossUberEatsFare,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("tipsText") ?? '',
                    widget.quebecModel.eatsTips,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstUberC") ?? '',
                    widget.quebecModel.gstCollectedFromUber,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstUberC") ?? '',
                    widget.quebecModel.qstCollectedFromUber,
                  ),

                  SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(
                    value: grossUber + tips + gstUber + qstUber,
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("gstNumText") ?? '',
                  ),
                  const SizedBox(height: 4),
                  StaticTextField(text: widget.quebecModel.yourGstNumberSec4),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("qstNumText") ?? '',
                  ),
                  const SizedBox(height: 4),
                  StaticTextField(text: widget.quebecModel.yourQstNumberSec4),
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
                          AppLocalizations.of(context)!.translate("prevText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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
                          final updatedModel = widget.quebecModel.copyWith(
                            id: widget.quebecModel.id,
                            grossUberEatsFare: grossUber,
                            eatsTips: tips,
                            gstCollectedFromUber: gstUber,
                            qstCollectedFromUber: qstUber,
                            yourGstNumberSec4: 'XXXXXXXXXRT0001',
                            yourQstNumberSec4: 'XXXXXXXXTQ0001',
                          );
                          debugPrint(
                            "===== QuebecModel being sent to IncomeBreakdown =====",
                          );
                          debugPrint(updatedModel.toJson().toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ViewIncomeBreakdownScreen(
                                    quebecModel: updatedModel,
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("nextText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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
