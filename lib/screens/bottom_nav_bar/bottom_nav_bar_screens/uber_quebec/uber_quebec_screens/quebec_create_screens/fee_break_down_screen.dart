import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_create_screens/gst_qst_return_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../view_models/quebec_view_model/quebec_view_model.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class FeeBreakDownScreen extends StatefulWidget {
  final QuebecModel quebecModel;
  const FeeBreakDownScreen({super.key, required this.quebecModel});

  @override
  State<FeeBreakDownScreen> createState() => _FeeBreakDownScreenState();
}

class _FeeBreakDownScreenState extends State<FeeBreakDownScreen> {
  double serviceFee = 0.00;
  double otherAmounts = 0.00;
  double feeDiscount = 0.00;
  double gstUber = 0.00;
  double qstUber = 0.00;
  double sec2Total = 0.00;

  @override
  void initState() {
    super.initState();
    serviceFee = widget.quebecModel.serviceFee;
    otherAmounts = widget.quebecModel.otherAmounts;
    feeDiscount = widget.quebecModel.feeDiscount;
    gstUber = widget.quebecModel.gstPaidToUber;
    qstUber = widget.quebecModel.qstPaidToUber;
    sec2Total = widget.quebecModel.section2Total;
  }

  double _calculateTotal() {
    return sec2Total;
  }

  void _onNextPressed() {
    final updatedModel = widget.quebecModel.copyWith(
      serviceFee: serviceFee,
      otherAmounts: otherAmounts,
      feeDiscount: feeDiscount,
      gstPaidToUber: gstUber,
      qstPaidToUber: qstUber,
      uberGstRegistrationNumber: 'XXXXXXXXXRT0001',
      uberQstRegistrationNumber: 'XXXXXXXXXTQ0001',
      section2Total: sec2Total,
    );

    debugPrint("===== QuebecModel being sent to GSTQstReturnScreen =====");
    debugPrint(updatedModel.toJson().toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GstQstReturnScreen(quebecModel: updatedModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuebecViewModel>();
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

                  _buildInput(
                    AppLocalizations.of(context)!.translate("serviceFeeText") ??
                        '',
                    serviceFee,
                    (v) => serviceFee = v,
                    "CA\$",
                  ),
                  _buildInput(
                    AppLocalizations.of(
                          context,
                        )!.translate("otherAmountsText") ??
                        '',
                    otherAmounts,
                    (v) => otherAmounts = v,
                    "CA\$",
                  ),
                  _buildInput(
                    AppLocalizations.of(
                          context,
                        )!.translate("feeDiscountText") ??
                        '',
                    feeDiscount,
                    (v) => feeDiscount = v,
                    "-CA\$",
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("gstUberText") ??
                        '',
                    gstUber,
                    (v) => gstUber = v,
                    "CA\$",
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("qstUberText") ??
                        '',
                    qstUber,
                    (v) => qstUber = v,
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
                  const StaticTextField(text: 'XXXXXXXXXRT0001'),
                  const SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("qstRegNumText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  const StaticTextField(text: 'XXXXXXXXXTQ0001'),

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
                          AppLocalizations.of(context)!.translate("prevText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                          height: 40,
                          color: AppColors.goldenOrangeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            final provider = context.read<QuebecViewModel>();

                            // Build model using current form values (widget.quebecModel is optional)
                            final model = QuebecModel(
                              // If you want to keep the ID from an existing model, you can:
                              id: widget.quebecModel.id,

                              // Section 1
                              name: widget.quebecModel.name,
                              year: widget.quebecModel.year,
                              grossUberRidesFares:
                                  widget.quebecModel.grossUberRidesFares,
                              bookingFee: widget.quebecModel.bookingFee,
                              mtqDues: widget.quebecModel.mtqDues,
                              airportFee: widget.quebecModel.airportFee,
                              splitFare: widget.quebecModel.splitFare,
                              miscellaneous: widget.quebecModel.miscellaneous,
                              tolls: widget.quebecModel.tolls,
                              tips: widget.quebecModel.tips,
                              gstCollectedFromRiders:
                                  widget.quebecModel.gstCollectedFromRiders,
                              qstCollectedFromRiders:
                                  widget.quebecModel.qstCollectedFromRiders,
                              section1Total: _calculateTotal(),

                              // Section 2+
                              otherTaxableIncome:
                                  widget.quebecModel.otherTaxableIncome,
                              serviceFee: widget.quebecModel.serviceFee,
                              otherAmounts: widget.quebecModel.otherAmounts,
                              feeDiscount: widget.quebecModel.feeDiscount,
                              gstPaidToUber: widget.quebecModel.gstPaidToUber,
                              qstPaidToUber: widget.quebecModel.qstPaidToUber,
                              section2Total:
                                  widget.quebecModel.section2Total ?? 0.0,
                              uberGstRegistrationNumber: 'XXXXXXXXXRT0001',
                              uberQstRegistrationNumber: 'XXXXXXXXXTQ0001',
                              suppliesExcludingGstQst:
                                  widget.quebecModel.suppliesExcludingGstQst,
                              gstRemittedByUber:
                                  widget.quebecModel.gstRemittedByUber,
                              qstRemittedByUber:
                                  widget.quebecModel.qstRemittedByUber,
                              gstCollectedFromRidersSec3:
                                  widget.quebecModel.gstCollectedFromRidersSec3,
                              qstCollectedFromRidersSec3:
                                  widget.quebecModel.qstCollectedFromRidersSec3,
                              yourGstNumberSec3: 'XXXXXXXXXRT0001',
                              yourQstNumberSec3: 'XXXXXXXXTQ0001',
                              grossUberEatsFare:
                                  widget.quebecModel.grossUberEatsFare,
                              eatsTips: widget.quebecModel.eatsTips,
                              gstCollectedFromUber:
                                  widget.quebecModel.gstCollectedFromUber,
                              qstCollectedFromUber:
                                  widget.quebecModel.qstCollectedFromUber,
                              section4Total: widget.quebecModel.section4Total,
                              yourGstNumberSec4: 'XXXXXXXXXRT0001',
                              yourQstNumberSec4: 'XXXXXXXXTQ0001',
                              quickAccountingMethod6085:
                                  widget.quebecModel.quickAccountingMethod6085,
                              gstCollectedFromUberSec5:
                                  widget.quebecModel.gstCollectedFromUberSec5,
                              qstCollectedFromUberSec5:
                                  widget.quebecModel.qstCollectedFromUberSec5,
                              section5Total: widget.quebecModel.section5Total,
                              uberGstRegistrationNumberSec5: 'XXXXXXXXXRT0001',
                              uberQstRegistrationNumberSec5: 'XXXXXXXXTQ0001',
                              onTripMileage: widget.quebecModel.onTripMileage,
                              onlineMileage: widget.quebecModel.onlineMileage,
                              otherIncomeMiscellaneous:
                                  widget.quebecModel.otherIncomeMiscellaneous,
                              periodFrom: widget.quebecModel.periodFrom,
                              periodTo: widget.quebecModel.periodTo,
                              dueDate: widget.quebecModel.dueDate,
                            );

                            // Always CREATE
                            provider.createQuebecApi(context, model.toJson());
                          },
                          child:
                              provider.isLoading
                                  ? Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("saveText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
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

  Widget _buildInput(
    String label,
    double initial,
    ValueChanged<double> onChanged,
    String currencyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        IncrementDecrementInputField(
          labelText: label,
          initialValue: initial,
          onChanged: (value) {
            setState(() {
              onChanged(value);

              //🔥 Always update total dynamically
              sec2Total =
                  serviceFee + otherAmounts - feeDiscount + gstUber + qstUber;
            });
          },
          currencyText: currencyText,
        ),
        const SizedBox(height: 10),
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
