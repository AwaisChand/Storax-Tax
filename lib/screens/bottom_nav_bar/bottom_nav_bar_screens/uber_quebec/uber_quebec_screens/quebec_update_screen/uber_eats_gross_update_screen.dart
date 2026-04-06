import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_update_screen/income_breakdown_update_screen.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_text_field.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class UberEatsGrossUpdateScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const UberEatsGrossUpdateScreen({super.key, required this.quebecModel});

  @override
  State<UberEatsGrossUpdateScreen> createState() =>
      _UberEatsGrossUpdateScreenState();
}

class _UberEatsGrossUpdateScreenState extends State<UberEatsGrossUpdateScreen> {
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
                    "UBER EATS\nGROSS FARES BREAKDOWN",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    "Tolls and tips not subject to GST/HST. You have collected GST/HST from Uber on your Uber Eats Fares if you are registered for GST/HST and have entered all the relevant information in your tax profile. If you are not registered for GST/HST because you are a small supplier (e.g., you have less than \$30,000 in sales over the past 12 months), you do not need to fill your tax profile.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _labelText("Gross Uber Eats fare"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'Gross Uber Eats fare',
                    initialValue: grossUber,
                    onChanged: (value) {
                      setState(() {
                        grossUber = value;
                      });
                    },
                    currencyText: 'CA\$',
                  ),
                  SizedBox(height: 10),
                  _labelText("Tips"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'Tips',
                    initialValue: tips,
                    onChanged: (value) {
                      setState(() {
                        tips = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("GST you collected from Uber"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'GST you collected from Uber',
                    initialValue: gstUber,
                    onChanged: (value) {
                      setState(() {
                        gstUber = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("QST you collected from Uber"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'QST you collected from Uber',
                    initialValue: qstUber,
                    onChanged: (value) {
                      setState(() {
                        qstUber = value;
                      });
                    },
                    currencyText: "CA\$",
                  ),
                  SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(
                    value: grossUber + tips + gstUber + qstUber,
                  ),
                  SizedBox(height: 10),
                  _labelText("Your GST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: gstController,
                    hintText: widget.quebecModel.yourGstNumberSec4,
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  _labelText("Your QST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: qstController,
                    hintText: widget.quebecModel.yourQstNumberSec4,
                    textInputType: TextInputType.text,
                  ),
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
                                  (context) => IncomeBreakdownUpdateScreen(
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
