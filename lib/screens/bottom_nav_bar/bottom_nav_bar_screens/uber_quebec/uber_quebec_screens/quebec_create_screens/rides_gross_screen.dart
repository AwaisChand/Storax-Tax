import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_create_screens/fee_break_down_screen.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/name_year_input_field_widget.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class RidesGrossScreen extends StatefulWidget {
  final QuebecModel? quebecModel;

  const RidesGrossScreen({super.key, this.quebecModel});

  @override
  State<RidesGrossScreen> createState() => _RidesGrossScreenState();
}

class _RidesGrossScreenState extends State<RidesGrossScreen> {
  String? _selectedYear;
  final TextEditingController _nameController = TextEditingController();

  double grossRidesFare = 0.00;
  double bookingFee = 0.00;
  double mtqDues = 0.00;
  double airportFee = 0.00;
  double splitFare = 0.00;
  double miscellaneous = 0.00;
  double tolls = 0.00;
  double tips = 0.00;
  double gstRider = 0.00;
  double qstRiders = 0.00;
  late List<String> _years;

  @override
  void initState() {
    super.initState();

    final String currentYear = DateTime.now().year.toString();

    if (widget.quebecModel != null) {
      _nameController.text = widget.quebecModel!.name;
      _selectedYear = widget.quebecModel!.year;

      _years = _getYears();
      if (_selectedYear != null && !_years.contains(_selectedYear)) {
        _years.insert(0, _selectedYear!);
      }

      grossRidesFare = widget.quebecModel!.grossUberRidesFares;
      bookingFee = widget.quebecModel!.bookingFee;
      mtqDues = widget.quebecModel!.mtqDues;
      airportFee = widget.quebecModel!.airportFee;
      splitFare = widget.quebecModel!.splitFare;
      miscellaneous = widget.quebecModel!.miscellaneous;
      tolls = widget.quebecModel!.tolls;
      tips = widget.quebecModel!.tips;
      gstRider = widget.quebecModel!.gstCollectedFromRiders;
      qstRiders = widget.quebecModel!.qstCollectedFromRiders;
    } else {
      _selectedYear = currentYear;
      _years = _getYears();

      if (!_years.contains(currentYear)) {
        _years.insert(0, currentYear);
      }
    }
  }

  List<String> _getYears() {
    final int currentYear = DateTime.now().year;
    return List.generate(7, (i) => (currentYear - i).toString());
  }

  double _calculateTotal() {
    return grossRidesFare +
        bookingFee +
        mtqDues +
        airportFee +
        splitFare +
        miscellaneous +
        tolls +
        tips +
        gstRider +
        qstRiders;
  }

  void _onNextPressed() {
    if (_nameController.text.trim().isEmpty) {
      Utils.toastMessage("Please enter your name");
      return;
    }

    final QuebecModel updatedModel = (widget.quebecModel ?? QuebecModel.empty())
        .copyWith(
          name: _nameController.text.trim(),
          year: _selectedYear,
          grossUberRidesFares: grossRidesFare,
          bookingFee: bookingFee,
          mtqDues: mtqDues,
          airportFee: airportFee,
          splitFare: splitFare,
          miscellaneous: miscellaneous,
          tolls: tolls,
          tips: tips,
          gstCollectedFromRiders: gstRider,
          qstCollectedFromRiders: qstRiders,
          section1Total: _calculateTotal(),
        );

    debugPrint("===== QuebecModel being sent to FeeBreakDownScreen =====");
    debugPrint(updatedModel.toJson().toString());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeeBreakDownScreen(quebecModel: updatedModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final quebec = context.watch<QuebecViewModel>();
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

          // Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  NameYearInputField(
                    controller: _nameController,
                    selectedYear: _selectedYear,
                    onYearChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    },
                    years: _years,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("grossRideDescText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.translate("uberTitle") ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.translate("subText") ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInput(
                    AppLocalizations.of(context)!.translate("grossRidesText") ??
                        '',
                    grossRidesFare,
                    (v) => grossRidesFare = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("bookingFeeText") ??
                        '',
                    bookingFee,
                    (v) => bookingFee = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("mtqDuesText") ??
                        '',
                    mtqDues,
                    (v) => mtqDues = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("airportFeeText") ??
                        '',
                    airportFee,
                    (v) => airportFee = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("splitText") ?? '',
                    splitFare,
                    (v) => splitFare = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("miscText") ?? '',
                    miscellaneous,
                    (v) => miscellaneous = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("tollsText") ?? '',
                    tolls,
                    (v) => tolls = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("tipsText") ?? '',
                    tips,
                    (v) => tips = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("gstCRiderText") ??
                        '',
                    gstRider,
                    (v) => gstRider = v,
                  ),
                  _buildInput(
                    AppLocalizations.of(context)!.translate("qstCRiderText") ??
                        '',
                    qstRiders,
                    (v) => qstRiders = v,
                  ),

                  const SizedBox(height: 10),

                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(value: _calculateTotal()),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                              id: widget.quebecModel?.id,

                              // Section 1
                              name: _nameController.text.trim(),
                              year: _selectedYear ?? '',
                              grossUberRidesFares: grossRidesFare,
                              bookingFee: bookingFee,
                              mtqDues: mtqDues,
                              airportFee: airportFee,
                              splitFare: splitFare,
                              miscellaneous: miscellaneous,
                              tolls: tolls,
                              tips: tips,
                              gstCollectedFromRiders: gstRider,
                              qstCollectedFromRiders: qstRiders,
                              section1Total: _calculateTotal(),

                              // Section 2+
                              otherTaxableIncome:
                                  widget.quebecModel?.otherTaxableIncome ?? 0.0,
                              serviceFee: widget.quebecModel?.serviceFee ?? 0.0,
                              otherAmounts:
                                  widget.quebecModel?.otherAmounts ?? 0.0,
                              feeDiscount:
                                  widget.quebecModel?.feeDiscount ?? 0.0,
                              gstPaidToUber:
                                  widget.quebecModel?.gstPaidToUber ?? 0.0,
                              qstPaidToUber:
                                  widget.quebecModel?.qstPaidToUber ?? 0.0,
                              section2Total:
                                  widget.quebecModel?.section2Total ?? 0.0,
                              uberGstRegistrationNumber: 'XXXXXXXXXRT0001',
                              uberQstRegistrationNumber: 'XXXXXXXXXTQ0001',
                              suppliesExcludingGstQst:
                                  widget.quebecModel?.suppliesExcludingGstQst ??
                                  0.0,
                              gstRemittedByUber:
                                  widget.quebecModel?.gstRemittedByUber ?? 0.0,
                              qstRemittedByUber:
                                  widget.quebecModel?.qstRemittedByUber ?? 0.0,
                              gstCollectedFromRidersSec3:
                                  widget
                                      .quebecModel
                                      ?.gstCollectedFromRidersSec3 ??
                                  0.0,
                              qstCollectedFromRidersSec3:
                                  widget
                                      .quebecModel
                                      ?.qstCollectedFromRidersSec3 ??
                                  0.0,
                              yourGstNumberSec3: 'XXXXXXXXXRT0001',
                              yourQstNumberSec3: 'XXXXXXXXTQ0001',
                              grossUberEatsFare:
                                  widget.quebecModel?.grossUberEatsFare ?? 0.0,
                              eatsTips: widget.quebecModel?.eatsTips ?? 0.0,
                              gstCollectedFromUber:
                                  widget.quebecModel?.gstCollectedFromUber ??
                                  0.0,
                              qstCollectedFromUber:
                                  widget.quebecModel?.qstCollectedFromUber ??
                                  0.0,
                              section4Total:
                                  widget.quebecModel?.section4Total ?? 0.0,
                              yourGstNumberSec4: 'XXXXXXXXXRT0001',
                              yourQstNumberSec4: 'XXXXXXXXTQ0001',
                              quickAccountingMethod6085:
                                  widget
                                      .quebecModel
                                      ?.quickAccountingMethod6085 ??
                                  0.0,
                              gstCollectedFromUberSec5:
                                  widget
                                      .quebecModel
                                      ?.gstCollectedFromUberSec5 ??
                                  0.0,
                              qstCollectedFromUberSec5:
                                  widget
                                      .quebecModel
                                      ?.qstCollectedFromUberSec5 ??
                                  0.0,
                              section5Total:
                                  widget.quebecModel?.section5Total ?? 0.0,
                              uberGstRegistrationNumberSec5: 'XXXXXXXXXRT0001',
                              uberQstRegistrationNumberSec5: 'XXXXXXXXTQ0001',
                              onTripMileage:
                                  widget.quebecModel?.onTripMileage ?? 0.0,
                              onlineMileage:
                                  widget.quebecModel?.onlineMileage ?? 0.0,
                              otherIncomeMiscellaneous:
                                  widget
                                      .quebecModel
                                      ?.otherIncomeMiscellaneous ??
                                  0.0,
                              periodFrom: widget.quebecModel?.periodFrom ?? '',
                              periodTo: widget.quebecModel?.periodTo ?? '',
                              dueDate: widget.quebecModel?.dueDate ?? '',
                            );

                            // Optional validation
                            if (model.name.isEmpty) {
                              Utils.toastMessage("Please enter name");
                              return;
                            }

                            // Always CREATE
                            provider.createQuebecApi(context, model.toJson());
                          },
                          child:
                              quebec.isLoading
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
                      Align(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                          height: 40,
                          color: AppColors.goldenOrangeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: _onNextPressed,
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("nextText") ??
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
              debugPrint("$label => $value");
            });
          },
          currencyText: 'CA\$',
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
