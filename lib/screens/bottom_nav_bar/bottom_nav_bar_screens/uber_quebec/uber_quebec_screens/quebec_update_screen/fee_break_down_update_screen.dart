import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../utils/utils.dart';
import '../uber_quebec_widgets/increment_decrement_input_field.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/total_values_widget.dart';
import 'gst_qst_return_update_screen.dart';

class FeeBreakDownUpdateScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const FeeBreakDownUpdateScreen({super.key, required this.quebecModel});

  @override
  State<FeeBreakDownUpdateScreen> createState() =>
      _FeeBreakDownUpdateScreenState();
}

class _FeeBreakDownUpdateScreenState extends State<FeeBreakDownUpdateScreen> {
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
        builder: (context) => GstQstReturnUpdateScreen(quebecModel: updatedModel),
      ),
    );
  }

  final uberGstController = TextEditingController();
  final uberQstController = TextEditingController();

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
                    "Many of the items listed below may be tax deductible. For more information, we recommend that you seek guidance from a qualified tax site or service.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "UBER RIDES\nFEES BREAKDOWN",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: AppColors.darkMidnightColor,
                    ),
                  ),
                  Text(
                    "This section indicates the fees you have paid to Uber. These include the service fees, as well as passthrough fees such as the booking fee, regulatory fees or airport fees.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInput(
                    "Service Fee",
                    serviceFee,
                    (v) => serviceFee = v,
                    "CA\$",
                  ),
                  _buildInput(
                    "Other Amounts (Booking, Airport, Split Fare, Green Future Fees)",
                    otherAmounts,
                    (v) => otherAmounts = v,
                    "CA\$",
                  ),
                  _buildInput(
                    "Fee Discount",
                    feeDiscount,
                    (v) => feeDiscount = v,
                    "-CA\$",
                  ),
                  _buildInput(
                    "GST you paid to Uber",
                    gstUber,
                    (v) => gstUber = v,
                    "CA\$",
                  ),
                  _buildInput(
                    "QST you paid to Uber",
                    qstUber,
                    (v) => qstUber = v,
                    "CA\$",
                  ),

                  const SizedBox(height: 10),
                  _labelText("Total"),
                  const SizedBox(height: 4),
                  TotalValuesWidget(value: _calculateTotal()),

                  const SizedBox(height: 10),
                  _labelText("Uber GST registration number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: uberGstController,
                    hintText: widget.quebecModel.uberGstRegistrationNumber,
                    textInputType: TextInputType.name,
                  ),
                  const SizedBox(height: 10),
                  _labelText("Uber QST registration number"),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: uberQstController,
                    hintText: widget.quebecModel.uberQstRegistrationNumber,
                    textInputType: TextInputType.name,
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
                        onPressed: _onNextPressed,
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
