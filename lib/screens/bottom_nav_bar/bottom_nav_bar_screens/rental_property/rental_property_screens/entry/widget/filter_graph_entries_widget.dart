import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';

Widget buildGraphEntriesFilterBar(BuildContext context, int planId) {
  return GestureDetector(
    onTap: () {
      showFilterGraphDialog(context, planId);
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
          const Text(
            "Filter By",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Image.asset(AppAssets.filterIcon, height: 15),
        ],
      ),
    ),
  );
}

Future showFilterDialog(BuildContext context, int planId) async {
  final now = DateTime.now();
  final currentYear = now.year;
  final List<String> past7Years = List.generate(
    7,
    (i) => (currentYear - i).toString(),
  );

  final provider = Provider.of<RentalPropertyViewModel>(context, listen: false);

  String? selectedYear = provider.selectedYear ?? currentYear.toString();

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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// Year Dropdown
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedYear,
                      items:
                          past7Years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(
                                year,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => selectedYear = val),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Year',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset Button
                        MaterialButton(
                          height: 40,
                          color: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedYear =
                                  currentYear
                                      .toString(); // reset to current year
                            });
                            provider.clearDatabaseFilters();
                            provider.getAllRegularEntriesApi(
                              context: context,
                              planId: planId,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Reset",
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        // Filter Button
                        MaterialButton(
                          height: 40,
                          color: AppColors.goldenOrangeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            final provider =
                                Provider.of<RentalPropertyViewModel>(
                                  context,
                                  listen: false,
                                );
                            provider.selectedYear = selectedYear;

                            provider.getAllDatabaseEntriesApi(
                              context: context,
                              planId: planId,
                              year: selectedYear ?? '',
                            );

                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Filter",
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
          );
        },
      );
    },
  );
}

List<int> selectedGraphEntry = [];

Widget buildGraphEntryFilter(BuildContext context, int planId) {
  return GestureDetector(
    onTap: () {
      showFilterGraphDialog(context, planId);
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

Future showFilterGraphDialog(BuildContext context, int planId) async {
  final now = DateTime.now();
  final currentYear = now.year;
  final List<String> past7Years = List.generate(
    7,
    (i) => (currentYear - i).toString(),
  );

  final provider = Provider.of<RentalPropertyViewModel>(context, listen: false);

  DateTime? selectedMonth = provider.selectedMonth;
  DateTime? fromDate = provider.fromDate;
  DateTime? toDate = provider.toDate;
  String? selectedYear = provider.selectedYear ?? currentYear.toString();

  final fromController = TextEditingController(
    text: fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : "",
  );
  final toController = TextEditingController(
    text: toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : "",
  );
  final monthController = TextEditingController(
    text:
        provider.selectedMonth != null
            ? DateFormat('MMMM yyyy').format(provider.selectedMonth!)
            : "", // keep empty if no month selected
  );

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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// From and To Dates
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromController,
                            readOnly: true,
                            style: GoogleFonts.poppins(fontSize: 15),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("fromDateText") ??
                                  '',
                              hintStyle: GoogleFonts.poppins(fontSize: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                            style: GoogleFonts.poppins(fontSize: 15),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("toDateText") ??
                                  '',
                              hintStyle: GoogleFonts.poppins(fontSize: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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

                    /// Month + Year
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: monthController,
                            readOnly: true,
                            style: GoogleFonts.poppins(fontSize: 15),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("selectMonthText") ??
                                  '',
                              hintStyle: GoogleFonts.poppins(fontSize: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onTap: () async {
                              final picked = await showMonthPicker(
                                context: context,
                                initialDate:
                                    selectedMonth ??
                                    DateTime.now(), // keep last if exists
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year, 12),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedMonth = picked;
                                  monthController.text = DateFormat(
                                    'MMMM yyyy',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                selectedYear, // will be current year by default
                            items:
                                past7Years
                                    .map(
                                      (year) => DropdownMenuItem(
                                        value: year,
                                        child: Text(
                                          year,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) => setState(() => selectedYear = val),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.blackColor,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("yearText") ??
                                  '',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 15,
                                color: AppColors.blackColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset Button
                        MaterialButton(
                          height: 40,
                          color: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            setState(() {
                              fromDate = null;
                              toDate = null;
                              selectedMonth = null;
                              selectedYear = null;
                              fromController.clear();
                              toController.clear();
                              monthController.clear();
                            });
                            provider.clearDatabaseFilters();
                            provider.getAllDatabaseEntriesApi(
                              context: context,
                              planId: planId,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("resetText") ??
                                '',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Filter Button
                        MaterialButton(
                          color: AppColors.goldenOrangeColor,
                          height: 40,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            // Use filtered year if selected, otherwise current year
                            final yearToUse =
                                selectedYear ?? DateTime.now().year.toString();

                            // Update provider filters
                            provider.fromDate = fromDate;
                            provider.toDate = toDate;
                            provider.selectedMonth = selectedMonth;
                            provider.selectedYear = yearToUse;

                            // Call API with proper parameters
                            provider.getAllDatabaseEntriesApi(
                              context: context,
                              planId: planId,
                              year: yearToUse,
                              month: selectedMonth,
                              fromDate: fromDate,
                              toDate: toDate,
                            );

                            Navigator.of(context).pop();
                          },

                          child: Text(
                            AppLocalizations.of(context)!.translate("filter") ??
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
