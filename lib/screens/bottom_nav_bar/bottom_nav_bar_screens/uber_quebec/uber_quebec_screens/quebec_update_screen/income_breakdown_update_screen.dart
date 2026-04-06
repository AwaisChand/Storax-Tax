import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_update_screen/potential_deduction_update_screen.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_text_field.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';

class IncomeBreakdownUpdateScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const IncomeBreakdownUpdateScreen({super.key, required this.quebecModel});

  @override
  State<IncomeBreakdownUpdateScreen> createState() => _IncomeBreakdownUpdateScreenState();
}

class _IncomeBreakdownUpdateScreenState extends State<IncomeBreakdownUpdateScreen> {
  double quickAccounting = 0.00;
  double gstUber = 0.00;
  double qstUber = 0.00;
  final gstController = TextEditingController();
  final qstController = TextEditingController();
  double otherTaxable = 0.00;
  double otherMiscellaneous = 0.00;

  @override
  void initState() {
    super.initState();
    quickAccounting = widget.quebecModel.quickAccountingMethod6085;
    gstUber = widget.quebecModel.gstCollectedFromRidersSec3;
    qstUber = widget.quebecModel.qstCollectedFromRidersSec3;
    gstController.text = widget.quebecModel.uberGstRegistrationNumberSec5;
    qstController.text = widget.quebecModel.uberQstRegistrationNumberSec5;
    otherTaxable = widget.quebecModel.otherTaxableIncome;
    otherMiscellaneous = widget.quebecModel.miscellaneous;

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
                    "OTHER INCOME\nBREAKDOWN",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    "This section indicates other amounts paid to you by Uber. Referrals and Promotions are subject to GST/HST",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _labelText("6.085% with the Quick Accounting Method"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: '6.085% with the Quick Accounting Method',
                    initialValue: quickAccounting,
                    onChanged: (value) {
                      setState(() {
                        quickAccounting = value;
                      });
                    },
                    currencyText: 'CA\$',
                  ),
                  SizedBox(height: 12),
                  _labelText("Other Income Miscellaneous"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'Other Income Miscellaneous',
                    initialValue: quickAccounting,
                    onChanged: (value) {
                      setState(() {
                        quickAccounting = value;
                      });
                    },
                    currencyText: 'CA\$',
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
                  TotalValuesWidget(value: quickAccounting + gstUber + qstUber),
                  SizedBox(height: 10),
                  _labelText("Your GST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: qstController,
                    hintText: widget.quebecModel.uberGstRegistrationNumberSec5,
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  _labelText("Your QST number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: qstController,
                    hintText: widget.quebecModel.uberQstRegistrationNumberSec5,
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  _labelText("Other Taxable Income"),
                  const SizedBox(height: 4),
                  IncrementDecrementInputField(
                    labelText: 'Other Taxable Income',
                    initialValue: otherTaxable,
                    onChanged: (value) {
                      setState(() {
                        otherTaxable = value;
                      });
                    },
                    currencyText: "CA\$",
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
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
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
                          // Update QuebecModel with new values for step 5
                          final updatedModel = widget.quebecModel.copyWith(
                            id: widget.quebecModel.id,
                            quickAccountingMethod6085: quickAccounting,
                            gstCollectedFromUber: gstUber,
                            qstCollectedFromUber: qstUber,
                            uberGstRegistrationNumberSec5: 'XXXXXXXXXRT0001',
                            uberQstRegistrationNumberSec5: 'XXXXXXXXXTQ0001',
                            otherIncomeMiscellaneous: otherMiscellaneous
                          );
                          debugPrint(
                            "===== QuebecModel being sent to PotentialDeduction =====",
                          );
                          debugPrint(updatedModel.toJson().toString());
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (context) => PotentialDeductionUpdateScreen(
                                    quebecModel: updatedModel,
                                  ),
                            ),
                          );
                        },
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
