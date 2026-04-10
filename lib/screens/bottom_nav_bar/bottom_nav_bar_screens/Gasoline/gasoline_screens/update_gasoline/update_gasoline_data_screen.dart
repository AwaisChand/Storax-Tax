import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_gasoline_list_model/get_gasoline_list_model.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/utils.dart';
import '../create_gasoline/widget/static_dual_stepper_widget.dart';
import '../create_gasoline/widget/total_amount_field_widget.dart';
import '../gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';

class UpdateGasolineDataScreen extends StatefulWidget {
  const UpdateGasolineDataScreen({super.key, this.data});

  final Data? data;

  @override
  State<UpdateGasolineDataScreen> createState() =>
      _UpdateGasolineDataScreenState();
}

class _UpdateGasolineDataScreenState extends State<UpdateGasolineDataScreen> {
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController beforeTaxController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final DateFormat displayDateFormat = DateFormat('dd/MM/yyyy');

  double gst = 0.0;
  double pst = 0.0;
  double hst = 0.0;
  double hstActual = 0.0;
  double gstActual = 0.0;
  double pstActual = 0.0;
  int? index;

  double totalAmount = 0.0;
  double totalTaxesValue = 0;
  double beforeTaxAmount = 0;
  String dateReceivedValue = "2025-07-28";
  DateTime? selectedDate;
  late String fileName;
  File? pickedReceipt;

  String smartFormat(num value) {
    // If whole number: return 0, 5, 13
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    // If decimal: return 0.25 or 4.75
    return value.toStringAsFixed(2);
  }

  void recalculateTaxes() {
    final authViewModel = context.read<AuthViewModel>();
    final bool isUS = authViewModel.user?.regCountry.toLowerCase() == "us";

    if (isUS) {
      double beforeTax = totalAmount - totalTaxesValue;
      setState(() {
        beforeTaxAmount = double.parse(beforeTax.toStringAsFixed(2));
        beforeTaxController.text = beforeTaxAmount.toStringAsFixed(2);
      });
    } else {
      double percentageGST_HST = hstActual > 0 ? hstActual : gstActual;
      double percentagePST = pstActual;

      double beforeTax =
          totalAmount / (1 + (percentageGST_HST + percentagePST) / 100);

      double fetchedGST_HST = beforeTax * (percentageGST_HST / 100);
      double fetchedPST = beforeTax * (percentagePST / 100);

      setState(() {
        beforeTaxAmount = double.parse(beforeTax.toStringAsFixed(2));
        beforeTaxController.text = beforeTaxAmount.toStringAsFixed(2);

        if (hstActual > 0) {
          hst = double.parse(fetchedGST_HST.toStringAsFixed(2));
        } else {
          gst = double.parse(fetchedGST_HST.toStringAsFixed(2));
        }

        pst = double.parse(fetchedPST.toStringAsFixed(2));
        totalTaxesValue = hst + gst + pst;
      });
    }
  }

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
            dialogBackgroundColor: Colors.white,
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

  @override
  void initState() {
    super.initState();

    final data = widget.data;
    final authViewModel = context.read<AuthViewModel>();

    // Initialize text controllers
    merchantController.text = data?.merchant ?? '';
    referenceController.text = data?.reference ?? '';
    totalAmountController.text = data?.total?.toStringAsFixed(2) ?? '';
    fileName = data?.image ?? '';
    // Initialize tax values
    gst = data?.gst?.toDouble() ?? 0.0;
    pst = data?.pst?.toDouble() ?? 0.0;
    hst = data?.hst?.toDouble() ?? 0.0;

    gstActual = data?.gstPercent?.toDouble() ?? 0.0;
    hstActual = data?.hstPercent?.toDouble() ?? 0.0;
    pstActual = data?.pstPercent?.toDouble() ?? 0.0;

    // Before tax and total tax
    totalTaxesValue = data?.tax?.toDouble() ?? 0.0;
    beforeTaxAmount = data?.beforeTaxAmount?.toDouble() ?? 0.0;
    totalAmount = data?.total?.toDouble() ?? 0.0;

    // Date handling
    if (data?.dateRecieved != null && data!.dateRecieved!.isNotEmpty) {
      // Parse the date string
      selectedDate = DateTime.tryParse(data.dateRecieved!);
    } else {
      selectedDate = DateTime.now();
    }

    // Initialize dateController with formatted date
    dateController.text =
        selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
            : DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final String dateText =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : "Select Date";
    final authViewModel = context.watch<AuthViewModel>();

    return Consumer<GasolineViewModel>(
      builder: (context, gasoline, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("updateGasolineText") ??
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
                                Consumer<GasolineViewModel>(
                                  builder: (context, gasolineVM, _) {
                                    final authVM = context.read<AuthViewModel>();

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            // Pick image
                                            final image = await authVM.pickImageFromGallery();
                                            if (image == null) return;

                                            setState(() {
                                              pickedReceipt = image;
                                            });

                                            // Automatically start scanning
                                            try {
                                              final result = await gasolineVM.scanFileApi(image);

                                              if (result != null && result["status"].toString() == "1") {
                                                final data = result["data"];

                                                setState(() {
                                                  // Merchant (remove address if included)
                                                  String trader = data['trader'] ?? '';
                                                  merchantController.text = trader.split(',').first;

                                                  // Invoice
                                                  referenceController.text = data['invoice_no'] ?? '';

                                                  // Total
                                                  totalAmount = double.tryParse(data['total'].toString()) ?? 0;
                                                  totalAmountController.text = totalAmount.toStringAsFixed(2);

                                                  // Taxes
                                                  gst = double.tryParse(data['gst'].toString()) ?? 0;
                                                  pst = double.tryParse(data['pst'].toString()) ?? 0;
                                                  hst = double.tryParse(data['hst'].toString()) ?? 0;

                                                  // Actual values
                                                  gstActual = gst;
                                                  pstActual = pst;
                                                  hstActual = hst;

                                                  // Before tax
                                                  beforeTaxAmount =
                                                      double.tryParse(data['before_tax_amount'].toString()) ?? 0;
                                                  beforeTaxController.text =
                                                      beforeTaxAmount.toStringAsFixed(2);

                                                  // Total tax
                                                  totalTaxesValue = double.tryParse(data['tax'].toString()) ?? 0;

                                                  // Date
                                                  if (data['date'] != null) {
                                                    selectedDate = DateTime.tryParse(data['date']);
                                                    if (selectedDate != null) {
                                                      dateController.text =
                                                          displayDateFormat.format(selectedDate!);
                                                    }
                                                  }

                                                  // Recalculate UI totals
                                                  recalculateTaxes();
                                                });
                                              } else {
                                                Utils.toastMessage("Scan failed");
                                              }
                                            } catch (e) {
                                              debugPrint("Scan API error: $e");
                                              Utils.toastMessage("Scan failed");
                                            }
                                          },
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade400),
                                              borderRadius: BorderRadius.circular(6),
                                              color: Colors.grey.shade100,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      right: BorderSide(color: Colors.grey.shade400),
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
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Text(
                                                      pickedReceipt?.path.split('/').last ?? "No file chosen",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: pickedReceipt != null
                                                            ? Colors.grey.shade600
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        /// Display picked image with loader overlay
                                        if (pickedReceipt != null)
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(pickedReceipt!.path),
                                                  width: double.infinity,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (gasolineVM.isLoading)
                                                Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("merchantText") ??
                                  '',
                            ),
                            const SizedBox(height: 6),
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
                            if (authViewModel.data?.regCountry != "us") ...[
                              Builder(
                                builder: (context) {
                                  final bool isHst = hst > 0;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      fieldLabel(
                                        isHst
                                            ? "${AppLocalizations.of(context)!.translate("hstText") ?? ''} (%)"
                                            : "${AppLocalizations.of(context)!.translate("gstText") ?? ''} (%)",
                                      ),
                                      const SizedBox(height: 6),
                                      StaticDualStepper(
                                        actualValue:
                                            isHst ? hstActual : gstActual,
                                        fetchedValue: isHst ? hst : gst,
                                      ),
                                      const SizedBox(height: 12),
                                      if (!isHst) ...[
                                        fieldLabel(
                                          "${AppLocalizations.of(context)!.translate("pstText") ?? ''} (%)",
                                        ),
                                        const SizedBox(height: 6),
                                        StaticDualStepper(
                                          actualValue: pstActual,
                                          fetchedValue: pst,
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 10),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("totalTaxText") ??
                                  '',
                            ),
                            const SizedBox(height: 6),
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
                                smartFormat(totalTaxesValue),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // Before Tax
                            const SizedBox(height: 13),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("beforeTaxText") ??
                                  '',
                            ),
                            const SizedBox(height: 6),
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
                                smartFormat(beforeTaxAmount),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
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
                                    readOnly: true, // 👈 disables manual typing
                                    onTap: _pickDate, // opens calendar
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
                            const SizedBox(height: 13),
                            fieldLabel(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("refText") ??
                                  '',
                            ),
                            const SizedBox(height: 6),
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
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
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
                                          'total': totalAmount,
                                          'tax': totalTaxesValue,
                                          'before_tax_amount': beforeTaxAmount,
                                          'date_recieved': dateText,
                                          'gst': gst,
                                          'hst': hst,
                                          'pst': pst,
                                          'gst_percent': gstActual,
                                          'hst_percent': hstActual,
                                          'pst_percent': pstActual,
                                        };

                                        gasoline.updateGasolineApi(
                                          context: context,
                                          fields: fields,
                                          id: widget.data?.id ?? 0,
                                          avatarFile: pickedReceipt,
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
                                                  )!.translate("updateText") ??
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

  Text fieldLabel(String title) {
    return Text(title, style: fieldLabelStyle());
  }

  TextStyle fieldLabelStyle() {
    return GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600);
  }
}
