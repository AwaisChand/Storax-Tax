import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

Widget buildGasolineReportFilterBar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showFilterReportDialog(context);
    },
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.goldenOrangeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.translate("filterText") ?? '',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Image.asset(AppAssets.filterIcon, height: 15),
        ],
      ),
    ),
  );
}

Future showFilterReportDialog(BuildContext context) async {
  final now = DateTime.now();
  final currentYear = now.year;

  // Provider
  final provider = Provider.of<GasolineViewModel>(context, listen: false);

  // Initial values
  DateTime? selectedMonth = provider.selectedGraphMonth;
  DateTime? fromDate = provider.fromGraphDate;
  DateTime? toDate = provider.toGraphDate;
  String? selectedYear = provider.selectedGraphYear ?? currentYear.toString();

  final fromController = TextEditingController(
    text: fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : "",
  );
  final toController = TextEditingController(
    text: toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : "",
  );
  final monthController = TextEditingController(
    text:
        selectedMonth != null
            ? DateFormat('MMMM yyyy').format(selectedMonth)
            : "",
  );

  // Pricing plans
  final plans = Provider.of<PricingPlansViewModel>(context, listen: false);
  final planNames =
      plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
  final isFreeGasPlan = planNames.any(
    (n) => n.contains('free version') || n.contains('basic'),
  );

  // 🔒 Force FREE plan defaults
  if (isFreeGasPlan) {
    selectedMonth = DateTime(now.year, now.month);
    selectedYear = now.year.toString();
    monthController.text = DateFormat('MMMM yyyy').format(selectedMonth);
  }

  // Determine year items based on plan
  final List<String> yearItems =
      isFreeGasPlan
          ? [now.year.toString()]
          : List.generate(7, (i) => (currentYear - i).toString());
  final locale = Localizations.localeOf(context).languageCode;


  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // From & To Dates
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromController,
                            readOnly: true,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("fromDateText") ??
                                  '',
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  fromDate = picked;
                                  fromController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: toController,
                            readOnly: true,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("toDateText") ??
                                  '',
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  toDate = picked;
                                  toController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: monthController,
                            readOnly: true,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("selectMonthText") ??
                                  '',
                            ),
                            onTap: () async {
                              // Limit the valid range for free plan
                              final firstDate =
                                  isFreeGasPlan
                                      ? DateTime(now.year, 1)
                                      : DateTime(now.year - 5);
                              final lastDate =
                                  isFreeGasPlan
                                      ? DateTime(now.year, 12)
                                      : DateTime(now.year, 12);

                              final picked = await showMonthPicker(
                                context: context,
                                initialDate: selectedMonth ?? now,
                                firstDate: firstDate,
                                lastDate: lastDate,
                              );

                              if (picked != null) {
                                setState(() {
                                  selectedMonth = picked;
                                  monthController.text = DateFormat(
                                    'MMMM yyyy',
                                  ).format(selectedMonth!);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedYear,
                            decoration: _input("Year"),
                            items:
                                yearItems
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text(
                                          y,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedYear =
                                    isFreeGasPlan ? now.year.toString() : val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            provider.clearGraphFilters();
                            provider.getGasolineReportApi(context);
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("resetText") ??
                                '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        MaterialButton(
                          color: AppColors.goldenOrangeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            provider.fromGraphDate = fromDate;
                            provider.toGraphDate = toDate;
                            provider.selectedGraphMonth = selectedMonth;
                            provider.selectedGraphYear = selectedYear;

                            provider.getGasolineReportApi(
                              context,
                              year: selectedYear,
                              month: selectedMonth,
                              fromDate: fromDate,
                              toDate: toDate,
                              language: locale
                            );

                            Navigator.pop(context);
                          },

                          child: Text(
                            AppLocalizations.of(context)!.translate("filter") ??
                                '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

InputDecoration _input(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
