import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../utils/app_colors.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/name_year_input_field_widget.dart';
import '../uber_quebec_widgets/total_values_widget.dart';
import 'fee_break_down_update_screen.dart';

class RidesGrossUpdateScreen extends StatefulWidget {
  final QuebecModel? quebecModel;


  const RidesGrossUpdateScreen({
    super.key,
    this.quebecModel,
  });

  @override
  State<RidesGrossUpdateScreen> createState() => _RidesGrossUpdateScreenState();
}

class _RidesGrossUpdateScreenState extends State<RidesGrossUpdateScreen> {
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
      _selectedYear = DateTime
          .now()
          .year
          .toString();
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

    final QuebecModel updatedModel = (widget.quebecModel ?? QuebecModel.empty()).copyWith(
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
        builder: (context) => FeeBreakDownUpdateScreen(quebecModel: updatedModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text3: 'NOT AN OFFICIAL INVOICE OR TAX DOCUMENT',
        text1: 'UBER',
        text2: 'Tax summary for the period by\n(Taxation Year)',
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
                  NameYearInputField(
                    controller: _nameController,
                    selectedYear: _selectedYear,
                    onYearChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                        debugPrint("Year changed to $_selectedYear");
                      });
                    },
                    years: _getYears(),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Many of the items listed below may be tax deductible. For more information, we recommend that you seek guidance from a qualified tax site or service.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "UBER RIDES - GROSS\nFARES BREAKDOWN",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    "This section indicates the fees you have charged to Riders.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInput("Gross Uber rides fares", grossRidesFare,
                          (v) => grossRidesFare = v),
                  _buildInput("Booking fee", bookingFee, (v) => bookingFee = v),
                  _buildInput("MTQ Dues", mtqDues, (v) => mtqDues = v),
                  _buildInput("Airport fee", airportFee, (v) => airportFee = v),
                  _buildInput("Split fare", splitFare, (v) => splitFare = v),
                  _buildInput("Miscellaneous", miscellaneous,
                          (v) => miscellaneous = v),
                  _buildInput("Tolls", tolls, (v) => tolls = v),
                  _buildInput("Tips", tips, (v) => tips = v),
                  _buildInput("GST you collected from Riders", gstRider,
                          (v) => gstRider = v),
                  _buildInput("QST you collected from Riders", qstRiders,
                          (v) => qstRiders = v),

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
                        "Next",
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

  Widget _buildInput(
      String label, double initial, ValueChanged<double> onChanged) {
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
