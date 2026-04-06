import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/files/create_personal_info/create_personal_file_screen.dart';
import 'package:storatax/screens/files/create_tax_manager/create_tax_manager_screen.dart';
import 'package:storatax/screens/files/get_personal_info/get_personal_info_screen.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import '../../res/app_assets.dart';
import '../../res/components/app_localization.dart';
import '../../utils/app_colors.dart';
import '../../utils/utils.dart';
import '../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import 'dialog_box.dart';

List<int> selectedFileIds = [];

Widget buildForwardMultipleButton(BuildContext context) {
  final plans = context.watch<PricingPlansViewModel>();
  final planNames =
      plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

  final isBusinessTaxManager = planNames.any(
    (n) => n.contains('business tax manager'),
  );
  final authProvider = context.read<AuthViewModel>();
  return Row(
    children: [
      SizedBox(
        width: Utils.setHeight(context) * 0.2,
        child: MaterialButton(
          color: AppColors.goldenOrangeColor,
          height: 40,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("forwardFileText") ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            if (selectedFileIds.isEmpty) {
              Utils.toastMessage(
                AppLocalizations.of(
                      context,
                    )!.translate("selectFileForwardText") ??
                    '',
              );
              return;
            }
            showMultipleForwardDialog(context, selectedFileIds);
          },
        ),
      ),
      SizedBox(width: 10),
      if (!isBusinessTaxManager &&
          authProvider.user?.regCountry?.toLowerCase() != 'us')
        SizedBox(
          width: Utils.setHeight(context) * 0.2,
          child: MaterialButton(
            color: AppColors.goldenOrangeColor,
            height: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)!.translate("personalInfoText") ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GetPersonalInfoScreen(),
                ),
              );
            },
          ),
        ),
    ],
  );
}

Widget buildFilterBar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showFilterDialog(context);
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

Future showFilterDialog(BuildContext context) async {
  final now = DateTime.now();
  final currentYear = now.year;
  final List<String> past7Years = List.generate(
    7,
    (i) => (currentYear - i).toString(),
  );

  final provider = Provider.of<TaxManagerViewModel>(context, listen: false);

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

                    /// From and To Date Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("fromText") ??
                                    '',
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 45,
                                child: TextField(
                                  readOnly: true,
                                  controller: fromController,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("fromDateText") ??
                                        '',
                                    contentPadding: const EdgeInsets.only(
                                      top: 12,
                                      left: 15,
                                    ),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("toText") ??
                                    '',
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 45,
                                child: TextField(
                                  readOnly: true,
                                  controller: toController,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("toDateText") ??
                                        '',
                                    contentPadding: const EdgeInsets.only(
                                      top: 12,
                                      left: 15,
                                    ),
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// Month and Year Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              controller: monthController,
                              readOnly: true,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(
                                      context,
                                    )!.translate("selectMonthText") ??
                                    '',
                                contentPadding: const EdgeInsets.only(
                                  left: 15,
                                  top: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onTap: () async {
                                final picked = await showMonthPicker(
                                  context: context,
                                  initialDate: selectedMonth,
                                  firstDate: DateTime(DateTime.now().year),
                                  lastDate: DateTime(DateTime.now().year, 12),
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
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedYear,
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
                            onChanged:
                                (val) => setState(() => selectedYear = val),
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            provider.clearFilters();
                            provider.getFilesApi(context);
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
                        MaterialButton(
                          color: AppColors.goldenOrangeColor,
                          height: 40,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            provider.fromDate = fromDate;
                            provider.toDate = toDate;
                            provider.selectedMonth = selectedMonth;
                            provider.selectedYear = selectedYear;

                            provider.getFilesApi(
                              context,
                              year: selectedYear,

                              // ✅ send month only if selected
                              month:
                                  selectedMonth != null
                                      ? DateFormat(
                                        'yyyy-MM',
                                      ).format(selectedMonth!)
                                      : null,

                              // ✅ send dates ONLY if user picked them
                              fromDate:
                                  fromController.text.isNotEmpty
                                      ? fromController.text
                                      : null,
                              toDate:
                                  toController.text.isNotEmpty
                                      ? toController.text
                                      : null,
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
