import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_uber_eats_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/static_values_widget.dart';

class ViewGstQstReturnScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const ViewGstQstReturnScreen({super.key, required this.quebecModel});

  @override
  State<ViewGstQstReturnScreen> createState() => _ViewGstQstReturnScreenState();
}

class _ViewGstQstReturnScreenState extends State<ViewGstQstReturnScreen> {
  double supplyExcluding = 0.00;
  double gstRemitted = 0.00;
  double qstRemitted = 0.00;
  double gstRiders = 0.00;
  double qstRiders = 0.00;

  @override
  void initState() {
    super.initState();
    supplyExcluding = widget.quebecModel.suppliesExcludingGstQst;
    gstRemitted = widget.quebecModel.gstRemittedByUber;
    qstRemitted = widget.quebecModel.qstRemittedByUber;
    gstRiders = widget.quebecModel.gstCollectedFromRidersSec3;
    qstRiders = widget.quebecModel.qstCollectedFromRidersSec3;
    gstNumController.text = widget.quebecModel.yourGstNumberSec3;
    qstNumController.text = widget.quebecModel.yourQstNumberSec3;
  }

  final gstNumController = TextEditingController();
  final qstNumController = TextEditingController();

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
                    AppLocalizations.of(context)!.translate("forGstQstReturnText") ?? '',                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate("forDescText") ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("supplyText") ?? '',
                    widget.quebecModel.suppliesExcludingGstQst,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstRemittedText") ?? '',
                    widget.quebecModel.gstRemittedByUber,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstRemittedText") ?? '',
                    widget.quebecModel.qstRemittedByUber,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstCRiderText") ?? '',
                    widget.quebecModel.gstCollectedFromRiders,
                  ),
                  SizedBox(height: 10),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstCRiderText") ?? '',
                    widget.quebecModel.qstCollectedFromRiders,
                  ),
                  SizedBox(height: 10),
                  _labelText(AppLocalizations.of(context)!.translate("gstNumText") ?? ''),
                  const SizedBox(height: 4),
                  StaticTextField(text: widget.quebecModel.yourGstNumberSec3),
                  SizedBox(height: 10),
                  _labelText(AppLocalizations.of(context)!.translate("qstNumText") ?? ''),
                  const SizedBox(height: 4),
                  StaticTextField(text: widget.quebecModel.yourQstNumberSec3),
                  SizedBox(height: 20),
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
                            suppliesExcludingGstQst: supplyExcluding,
                            gstRemittedByUber: gstRemitted,
                            qstRemittedByUber: qstRemitted,
                            gstCollectedFromRiders: gstRiders,
                            qstCollectedFromRiders: qstRiders,
                            yourGstNumberSec3: 'XXXXXXXXXRT0001',
                            yourQstNumberSec3: 'XXXXXXXXTQ0001',
                          );

                          debugPrint(
                            "===== QuebecModel being sent to UberEats =====",
                          );
                          debugPrint(updatedModel.toJson().toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ViewUberEatsGrossScreen(
                                    quebecModel: updatedModel,
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate("nextText") ?? '',
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
