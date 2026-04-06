import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_update_screen/uber_eats_gross_update_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../utils/utils.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class GstQstReturnUpdateScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const GstQstReturnUpdateScreen({super.key, required this.quebecModel});

  @override
  State<GstQstReturnUpdateScreen> createState() =>
      _GstQstReturnUpdateScreenState();
}

class _GstQstReturnUpdateScreenState extends State<GstQstReturnUpdateScreen> {
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
                    "Many of the items listed below may be tax deductible. For more information, we recommend that you seek guidance from a qualified tax site or service.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "FOR YOUR\nGST/QST RETURN",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    "This section includes relevant information to prepare your GST/QST return. Please note that...",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _labelText("Supplies excluding GST and QST"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'Supplies excluding GST and QST',
                    initialValue: supplyExcluding,
                    onChanged: (value) {
                      setState(() {
                        supplyExcluding = value;
                      });
                    },
                    currencyText: 'CA\$',
                  ),
                  SizedBox(height: 10),
                  _labelText("GST remitted by Uber on your behalf"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'GST remitted by Uber on your behalf',
                    initialValue: gstRemitted,
                    onChanged: (value) {
                      setState(() {
                        gstRemitted = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("QST remitted by Uber on your behalf"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'QST remitted by Uber on your behalf',
                    initialValue: qstRemitted,
                    onChanged: (value) {
                      setState(() {
                        qstRemitted = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("GST you collected from Riders"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'GST you collected from Riders',
                    initialValue: gstRiders,
                    onChanged: (value) {
                      setState(() {
                        gstRiders = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("QST you collected from Riders"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'QST you collected from Riders',
                    initialValue: qstRiders,
                    onChanged: (value) {
                      setState(() {
                        qstRiders = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(
                    value:
                        supplyExcluding +
                        gstRemitted +
                        qstRemitted +
                        gstRiders +
                        qstRiders,
                  ),
                  SizedBox(height: 10),
                  _labelText("Your GST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: gstNumController,
                    hintText: widget.quebecModel.yourGstNumberSec3,
                    textInputType: TextInputType.text,
                  ),                  SizedBox(height: 10),
                  _labelText("Your QST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: qstNumController,
                    hintText: widget.quebecModel.yourQstNumberSec3,
                    textInputType: TextInputType.text,
                  ),
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
                          "Previous",
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
                                  (context) => UberEatsGrossUpdateScreen(
                                    quebecModel: updatedModel,
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          "Next",
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
