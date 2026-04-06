import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/static_values_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_fee_break_screen.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class ViewRidesGrossScreen extends StatefulWidget {
  final QuebecModel? quebecModel;

  const ViewRidesGrossScreen({super.key, this.quebecModel});

  @override
  State<ViewRidesGrossScreen> createState() => _ViewRidesGrossScreenState();
}

class _ViewRidesGrossScreenState extends State<ViewRidesGrossScreen> {
  String? _selectedYear;

  final TextEditingController _nameController = TextEditingController();

  // Fields
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

  @override
  void initState() {
    super.initState();

    if (widget.quebecModel != null) {
      _nameController.text = widget.quebecModel!.name;
      _selectedYear = widget.quebecModel!.year;
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
      _selectedYear = DateTime.now().year.toString();
    }
  }

  List<String> _getYears() {
    final currentYear = DateTime.now().year;
    return List.generate(20, (index) => (currentYear - index).toString());
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
    final QuebecModel updatedModel = (widget.quebecModel ?? QuebecModel.empty())
        .copyWith(
          id: widget.quebecModel?.id,
          name: _nameController.text.trim(),
          year: _selectedYear!,
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
        builder: (context) => ViewFeeBreakDownScreen(quebecModel: updatedModel),
      ),
    );
  }

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
          // Background
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
                  StaticNameYearInputField(
                    selectedYear: widget.quebecModel!.year,
                    name: widget.quebecModel!.name,
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
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("grossRidesText") ??
                        '',
                    widget.quebecModel!.grossUberRidesFares,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("bookingFeeText") ??
                        '',
                    widget.quebecModel!.bookingFee,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("mtqDuesText") ??
                        '',
                    widget.quebecModel!.mtqDues,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("airportFeeText") ??
                        '',
                    widget.quebecModel!.airportFee,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("splitText") ?? '',
                    widget.quebecModel!.splitFare,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("miscText") ?? '',
                    widget.quebecModel!.miscellaneous,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("tollsText") ?? '',
                    widget.quebecModel!.tolls,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("tipsText") ?? '',
                    widget.quebecModel!.tips,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("gstCRiderText") ??
                        '',
                    widget.quebecModel!.gstCollectedFromRiders,
                  ),
                  _valuesViewsWidget(
                    AppLocalizations.of(context)!.translate("qstCRiderText") ??
                        '',
                    widget.quebecModel!.qstCollectedFromRiders,
                  ),

                  const SizedBox(height: 10),

                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(value: _calculateTotal()),

                  const SizedBox(height: 10),

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
                        AppLocalizations.of(context)!.translate("nextText") ??
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
