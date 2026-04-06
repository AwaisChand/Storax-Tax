import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_gst_qst_return_screen.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/static_values_widget.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class ViewFeeBreakDownScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const ViewFeeBreakDownScreen({super.key, required this.quebecModel});

  @override
  State<ViewFeeBreakDownScreen> createState() => _ViewFeeBreakDownScreenState();
}

class _ViewFeeBreakDownScreenState extends State<ViewFeeBreakDownScreen> {
  double serviceFee = 0.00;
  double otherAmounts = 0.00;
  double feeDiscount = 0.00;
  double gstUber = 0.00;
  double qstUber = 0.00;

  @override
  void initState() {
    super.initState();

    serviceFee = widget.quebecModel.serviceFee;
    otherAmounts = widget.quebecModel.otherAmounts;
    feeDiscount = widget.quebecModel.feeDiscount;
    gstUber = widget.quebecModel.gstPaidToUber;
    qstUber = widget.quebecModel.qstPaidToUber;
    uberGstController.text = widget.quebecModel.uberGstRegistrationNumber;
    uberQstController.text = widget.quebecModel.uberQstRegistrationNumber;
  }

  double _calculateTotal() {
    return serviceFee + otherAmounts - feeDiscount + gstUber + qstUber;
  }

  void _onNextPressed() {
    final updatedModel = widget.quebecModel.copyWith(
      id: widget.quebecModel.id,
      serviceFee: serviceFee,
      otherAmounts: otherAmounts,
      feeDiscount: feeDiscount,
      gstPaidToUber: gstUber,
      qstPaidToUber: qstUber,
      uberGstRegistrationNumber: 'XXXXXXXXXRT0001',
      uberQstRegistrationNumber: 'XXXXXXXXXTQ0001',
      section2Total: _calculateTotal(),
    );

    debugPrint("===== QuebecModel being sent to GSTQstReturnScreen =====");
    debugPrint(updatedModel.toJson().toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGstQstReturnScreen(quebecModel: updatedModel),
      ),
    );
  }

  final uberGstController = TextEditingController();
  final uberQstController = TextEditingController();

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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaticNameYearInputField(
                    selectedYear: widget.quebecModel.year,
                    name: widget.quebecModel.name,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("freesBreakdownUberText") ??
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
                        )!.translate("feesBreakdownText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("serviceFeeText") ??
                        '',
                    widget.quebecModel.serviceFee,
                    "CA\$",
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(
                          context,
                        )!.translate("otherAmountsText") ??
                        '',
                    widget.quebecModel.otherAmounts,
                    "CA\$",
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(
                          context,
                        )!.translate("feeDiscountText") ??
                        '',
                    widget.quebecModel.feeDiscount,
                    "-CA\$",
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstUberText") ??
                        '',
                    widget.quebecModel.gstPaidToUber,
                    "CA\$",
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstUberText") ??
                        '',
                    widget.quebecModel.qstPaidToUber,
                    "CA\$",
                  ),

                  const SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(value: _calculateTotal()),

                  const SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("uberRegNumText") ??
                        '',
                  ),
                  const SizedBox(height: 4),

                  StaticTextField(
                    text: widget.quebecModel.uberGstRegistrationNumber,
                  ),
                  const SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("qstRegNumText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  StaticTextField(
                    text: widget.quebecModel.uberQstRegistrationNumber,
                  ),
                  const SizedBox(height: 20),
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
                          AppLocalizations.of(
                                context,
                              )!.translate("prevText") ??
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
                        onPressed: _onNextPressed,
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

  Widget _valuesViewsWidget(String label, double values, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        StaticValuesWidget(value: values, currencyText: currency),
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
