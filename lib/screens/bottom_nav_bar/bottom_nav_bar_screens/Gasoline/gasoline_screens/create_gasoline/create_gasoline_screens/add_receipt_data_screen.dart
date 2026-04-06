import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';
import '../widget/static_dual_stepper_widget.dart';
import '../widget/total_amount_field_widget.dart';

class AddReceiptDataScreen extends StatefulWidget {
  const AddReceiptDataScreen({super.key, this.receiptData, this.receiptFile});
  final Map<String, dynamic>? receiptData;
  final File? receiptFile;

  @override
  State<AddReceiptDataScreen> createState() => _AddReceiptDataScreenState();
}

class _AddReceiptDataScreenState extends State<AddReceiptDataScreen> {
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController beforeTaxController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  late TextEditingController dateController;
  final DateFormat displayDateFormat = DateFormat('dd/MM/yyyy');

  double gst = 0.0;
  double pst = 0.0;
  double hst = 0.0;
  double hstActual = 0.0;
  double gstActual = 0.0;
  double pstActual = 0.0;
  bool isUserEditing = false;
  late FocusNode focusNode;

  double totalAmount = 0.0;
  double totalTaxesValue = 12.45;
  String dateReceivedValue = "2025-07-28";
  DateTime? selectedDate;
  late String fileName;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "Select Date",
      fieldHintText: "yyyy-mm-dd",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = displayDateFormat.format(picked);
      });
    }
  }

  void recalculateTaxes() {
    final authViewModel = context.read<AuthViewModel>();
    final bool isUS = authViewModel.user?.regCountry.toLowerCase() == "us";

    if (isUS) {
      double beforeTax = totalAmount - totalTaxesValue;
      setState(() {
        beforeTaxController.text = beforeTax.toStringAsFixed(2);
        // gst, pst, hst, totalTaxesValue remain unchanged
      });
    } else {
      // For non-US users, calculate as before
      double percentagegstHst = hstActual > 0 ? hstActual : gstActual;
      double percentagePST = pstActual;

      double beforeTax =
          totalAmount / (1 + (percentagegstHst + percentagePST) / 100);

      double fetchedgstHst = beforeTax * (percentagegstHst / 100);
      double fetchedPST = beforeTax * (percentagePST / 100);

      setState(() {
        beforeTaxController.text = beforeTax.toStringAsFixed(2);

        if (hstActual > 0) {
          hst = fetchedgstHst;
        } else {
          gst = fetchedgstHst;
        }

        pst = fetchedPST;
        totalTaxesValue = fetchedgstHst + fetchedPST;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final data = widget.receiptData;
    final authViewModel = context.read<AuthViewModel>();

    fileName =
        widget.receiptFile != null
            ? widget.receiptFile!.path.split('/').last
            : 'No file chosen';

    // Initialize controllers
    merchantController.text = '';
    beforeTaxController.text = '';
    referenceController.text = '';

    // Date controller for editable field
    dateController = TextEditingController();

    // Date format for display
    final DateFormat displayDateFormat = DateFormat('dd/MM/yyyy');

    if (data != null) {
      merchantController.text = data['trader'] ?? 'No Merchant';
      beforeTaxController.text = data['before_tax_amount']?.toString() ?? '';
      referenceController.text = data['invoice_no'] ?? '';

      totalAmount = (data['total'] ?? 0).toDouble();
      gst = (data['gst'] ?? 0).toDouble();
      pst = (data['pst'] ?? 0).toDouble();
      hst = (data['hst'] ?? 0).toDouble();
      gstActual = authViewModel.data?.gst?.toDouble() ?? 0.0;
      hstActual = authViewModel.data?.hst?.toDouble() ?? 0.0;
      pstActual = authViewModel.data?.pst?.toDouble() ?? 0.0;

      totalTaxesValue = (data['tax'] ?? 0).toDouble();
      dateReceivedValue = data['date'] ?? '';

      // Parse the stored date
      if (dateReceivedValue.isNotEmpty) {
        selectedDate = DateTime.tryParse(dateReceivedValue);
      }

      // Set the text for editable date field
      dateController.text =
          selectedDate != null
              ? displayDateFormat.format(selectedDate!)
              : displayDateFormat.format(DateTime.now());
    } else {
      // If no data, set today's date by default
      selectedDate = DateTime.now();
      dateController.text = displayDateFormat.format(selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateText =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now());

    final authViewModel = context.read<AuthViewModel>();
    final bool isHst = authViewModel.data?.hst != null;
    return Consumer<GasolineViewModel>(
      builder: (context, gasoline, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("addNewReceiptText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("descNewReceiptText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GasolineListScreen()),
              );
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

              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.translate("uploadReceiptText") ?? ''} *",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.grey.shade100,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Choose File",
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Merchant
                            fieldLabel(
                              "${AppLocalizations.of(context)!.translate("merchantText") ?? ''} *",
                            ),
                            SizedBox(height: 6),
                            buildInputField(controller: merchantController),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("totalAmountText") ??
                                  '',
                            ),
                            SizedBox(height: 6),
                            TotalAmountField(
                              value: totalAmount,
                              onChanged: (val) {
                                setState(() => totalAmount = val);
                                recalculateTaxes();
                              },
                            ),
                            if (authViewModel.user?.regCountry != "us") ...[
                              fieldLabel(
                                isHst
                                    ? "${AppLocalizations.of(context)!.translate("hstText") ?? ''} (%)"
                                    : "${AppLocalizations.of(context)!.translate("gstText") ?? ''} (%)",
                              ),
                              SizedBox(height: 6),
                              StaticDualStepper(
                                actualValue: isHst ? hstActual : gstActual,
                                fetchedValue: isHst ? hst : gst,
                              ),

                              SizedBox(height: 12),
                              if (!isHst) ...[
                                fieldLabel(
                                  "${AppLocalizations.of(context)!.translate("pstText") ?? ''} (%)",
                                ),
                                SizedBox(height: 6),
                                StaticDualStepper(
                                  actualValue: pstActual,
                                  fetchedValue: pst,
                                ),
                              ],
                            ],

                            SizedBox(height: 10),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("totalTaxText") ??
                                  '',
                            ),
                            SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Text(
                                totalTaxesValue.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            SizedBox(height: 13),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("beforeTaxText") ??
                                  '',
                            ),
                            SizedBox(height: 6),
                            buildInputField(controller: beforeTaxController),

                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("dateText") ??
                                  '',
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: dateController,
                                    readOnly: true,
                                    onTap: _pickDate,
                                    decoration: InputDecoration(
                                      hintText: "yyyy-mm-dd",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 13),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("refText") ??
                                  '',
                            ),
                            SizedBox(height: 6),
                            buildInputField(controller: referenceController),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MaterialButton(
                                    height: 40,
                                    color: AppColors.lightPinkColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("cancelText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  MaterialButton(
                                    height: 40,
                                    color: AppColors.goldenOrangeColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onPressed: () {
                                      if (merchantController.text.isEmpty) {
                                        Utils.toastMessage(
                                          "Please enter merchant name",
                                        );
                                      } else if (referenceController
                                          .text
                                          .isEmpty) {
                                        Utils.toastMessage(
                                          "Please enter your reference",
                                        );
                                      } else {
                                        Map<String, dynamic> fields = {
                                          'merchant':
                                              merchantController.text
                                                  .toString(),
                                          'reference':
                                              referenceController.text
                                                  .toString(),
                                          'receipt_text': 'Sample receipt text',
                                          'total': totalAmount,
                                          'tax': totalTaxesValue,
                                          'before_tax_amount':
                                              double.tryParse(
                                                beforeTaxController.text,
                                              ) ??
                                              0.0,
                                          'date_recieved': dateText,
                                          'gst': gst,
                                          'hst': hst,
                                          'pst': pst,
                                          'gst_percent': gstActual,
                                          'hst_percent': hstActual,
                                          'pst_percent': pstActual,
                                        };

                                        gasoline.createGasolineApi(
                                          context,
                                          fields,
                                          widget.receiptFile,
                                        );
                                      }
                                    },
                                    child:
                                        gasoline.isLoading
                                            ? Center(
                                              child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          AppColors.blackColor,
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
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildInputField({required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

Text fieldLabel(String title) {
  return Text(title, style: fieldLabelStyle());
}

TextStyle fieldLabelStyle() {
  return GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600);
}

String formatValue(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(3);
}
