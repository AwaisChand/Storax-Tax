import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_create_screens/uber_eats_gross_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_text_field_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../view_models/quebec_view_model/quebec_view_model.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';

class GstQstReturnScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const GstQstReturnScreen({super.key, required this.quebecModel});

  @override
  State<GstQstReturnScreen> createState() => _GstQstReturnScreenState();
}

class _GstQstReturnScreenState extends State<GstQstReturnScreen> {
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
    widget.quebecModel.yourGstNumberSec3 = "XXXXXXXXXRT0001";
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
                        )!.translate("forGstQstReturnText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate("forDescText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _labelText(
                    AppLocalizations.of(context)!.translate("supplyText") ?? '',
                  ),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText:
                        AppLocalizations.of(context)!.translate("supplyText") ??
                        '',
                    initialValue: supplyExcluding,
                    onChanged: (value) {
                      setState(() {
                        supplyExcluding = value;
                      });
                    },
                    currencyText: 'CA\$',
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(
                          context,
                        )!.translate("gstRemittedText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText:
                        AppLocalizations.of(
                          context,
                        )!.translate("gstRemittedText") ??
                        '',
                    initialValue: gstRemitted,
                    onChanged: (value) {
                      setState(() {
                        gstRemitted = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(
                          context,
                        )!.translate("qstRemittedText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText:
                        AppLocalizations.of(
                          context,
                        )!.translate("qstRemittedText") ??
                        '',
                    initialValue: qstRemitted,
                    onChanged: (value) {
                      setState(() {
                        qstRemitted = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("gstCRiderText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText:
                        AppLocalizations.of(
                          context,
                        )!.translate("gstCRiderText") ??
                        '',
                    initialValue: gstRiders,
                    onChanged: (value) {
                      setState(() {
                        gstRiders = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("qstCRiderText") ??
                        '',
                  ),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText:
                        AppLocalizations.of(
                          context,
                        )!.translate("qstCRiderText") ??
                        '',
                    initialValue: qstRiders,
                    onChanged: (value) {
                      setState(() {
                        qstRiders = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("gstNumText") ?? '',
                  ),
                  const SizedBox(height: 4),
                  StaticTextField(text: "XXXXXXXXXRT0001"),
                  SizedBox(height: 10),
                  _labelText(
                    AppLocalizations.of(context)!.translate("qstNumText") ?? '',
                  ),
                  const SizedBox(height: 4),
                  StaticTextField(text: "XXXXXXXXTQ0001"),
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
                              section1Total: widget.quebecModel.section1Total,

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
                        onPressed: () {
                          final updatedModel = widget.quebecModel.copyWith(
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
                                  (context) => UberEatsGrossScreen(
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

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
