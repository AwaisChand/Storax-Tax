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

Widget buildTransactionReportFilterBar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showTransactionFilterReportDialog(context);
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

Future showTransactionFilterReportDialog(BuildContext context) async {
  final now = DateTime.now();
  final currentYear = now.year;

  // Provider
  final provider = Provider.of<GasolineViewModel>(context, listen: false);

  // Initial values
  DateTime? selectedMonth = provider.selectedTransMonth;
  DateTime? fromDate = provider.fromTransDate;
  DateTime? toDate = provider.toTransDate;
  String? selectedSortBy = provider.sortBy;
  String? selectedOrder = provider.sortOrder;
  String? selectedYear = provider.selectedTransYear;

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

                    // Month & Year
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: monthController,
                            readOnly: true,
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("selectMonthText") ??
                                  '',
                            ),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            onTap: () async {
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
                        Flexible(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedYear,
                            isExpanded: true,
                            hint: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("selectYearText") ??
                                  '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
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
                                selectedYear = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedSortBy,
                            hint: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("sortByText") ??
                                  '',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            isExpanded: true,
                            decoration: _input(""),
                            items: [
                              DropdownMenuItem(
                                value: 'Date',
                                child: Text(
                                  'Date',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Merchant',
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("merchantText") ??
                                      '',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Total Amount',
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("totalAmountText") ??
                                      '',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedSortBy = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedOrder,
                            hint: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("sortOrderText") ??
                                  '',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            isExpanded: true,
                            decoration: _input(""),
                            items: [
                              DropdownMenuItem(
                                value: 'asc',
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("ascText") ??
                                      '',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'desc',
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("descendingText") ??
                                      '',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedOrder = val;
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
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          onPressed: () {
                            provider.clearTransactionFilters();

                            provider.getTransactionReportApi(
                              context,
                              year: null,
                              month: null,
                              fromDate: null,
                              toDate: null,
                              sortBy: null,
                              sortOrder: null,
                            );

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
                            provider.fromTransDate = fromDate;
                            provider.toTransDate = toDate;
                            provider.selectedTransMonth = selectedMonth;
                            provider.selectedTransYear = selectedYear;
                            provider.sortBy = selectedSortBy;
                            provider.sortOrder = selectedOrder;

                            String? formattedMonth;
                            if (selectedMonth != null) {
                              formattedMonth = DateFormat(
                                'yyyy-MM',
                              ).format(selectedMonth!);

                              // Build print URL
                              String printUrl =
                                  "https://storatax.com/api/gasolines/gasoline-transactions/report/print?"
                                  "year=${selectedMonth!.year}&month=$formattedMonth&language=fr";
                              debugPrint("Print report URL: $printUrl");
                            } else if (selectedYear != null) {
                              String printUrl =
                                  "https://storatax.com/api/gasolines/gasoline-transactions/report/print?"
                                  "year=$selectedYear&month=&language=fr";
                              debugPrint("Print report URL: $printUrl");
                            }

                            // Call the API
                            provider.getTransactionReportApi(
                              context,
                              year: selectedYear,
                              month: formattedMonth,
                              fromDate:
                                  fromController.text.isEmpty
                                      ? null
                                      : fromController.text,
                              toDate:
                                  toController.text.isEmpty
                                      ? null
                                      : toController.text,
                              sortBy:
                                  selectedSortBy != null
                                      ? mapSortByToApi(selectedSortBy!)
                                      : null,
                              sortOrder: selectedOrder,
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

String mapSortByToApi(String value) {
  switch (value) {
    case 'Date':
      return 'date_recieved';
    case 'Merchant':
      return 'merchant';
    case 'Total Amount':
      return 'total';
    default:
      return 'date_recieved';
  }
}

InputDecoration _input(String hint) {
  return InputDecoration(
    hintText: hint,
    isDense: true,
    hintStyle: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
