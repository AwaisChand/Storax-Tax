import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../models/expense_type_model/expense_type_model.dart';
import '../../../../../../../models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../view_models/auth_view_model/auth_view_model.dart';

Widget buildEntriesFilterBar(BuildContext context, int planId) {
  return GestureDetector(
    onTap: () {
      context.read<RentalPropertyViewModel>().getIncomeTypesApi(
        context: context,
        planId: planId,
      );

      showFilterDialog(context, planId);
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

Future showFilterDialog(BuildContext context, int planId) async {
  final now = DateTime.now();
  final currentYear = now.year;
  final List<String> past7Years = List.generate(
    7,
    (i) => (currentYear - i).toString(),
  );

  final provider = Provider.of<RentalPropertyViewModel>(context, listen: false);

  // DateTime? selectedMonth = provider.selectedMonth;
  // DateTime? fromDate = provider.fromDate;
  // DateTime? toDate = provider.toDate;
  // String? selectedYear = provider.selectedYear ?? currentYear.toString();

  String? selectedExpenseKey;
  int? selectedIncomeId;


  IncomeTypeOption? selectedIncomeType = provider.selectedIncomeType;
  ExpenseType? selectedExpenseType = provider.selectedExpenseType;
  DateTime? fromDate = provider.fromDate;
  DateTime? toDate = provider.toDate;
  DateTime? selectedMonth = provider.selectedMonth;
  String? selectedYear = provider.selectedYear ?? DateTime.now().year.toString();

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
            : "",
  );

  final rentalVM = context.read<RentalPropertyViewModel>();

  // IncomeTypeOption? selectedIncomeType;

  final List<IncomeTypeOption> dynamicIncomeOptions =
      planId != null
          ? rentalVM.getIncomeTypeOptions(planId).map((e) {
            return IncomeTypeOption(
              id: e.id,
              name: e.name,
              rawEntry: e.rawEntry ?? e,
            );
          }).toList()
          : [];

  final List<ExpenseType> caExpenseTypes = [
    ExpenseType(key: 'Advertising', en: 'Advertising', fr: 'Publicité'),
    ExpenseType(key: 'Insurance', en: 'Insurance', fr: 'Assurance'),
    ExpenseType(
      key: 'Interest and bank charges',
      en: 'Interest and bank charges',
      fr: 'Intérêts et frais bancaires',
    ),
    ExpenseType(
      key: 'Office expenses',
      en: 'Office expenses',
      fr: 'Frais de bureau',
    ),
    ExpenseType(
      key: 'Professional fees',
      en: 'Professional fees',
      fr: 'Honoraires professionnels',
    ),
    ExpenseType(
      key: 'Management and administration fees',
      en: 'Management and administration fees',
      fr: 'Frais de gestion et d’administration',
    ),
    ExpenseType(
      key: 'Repairs and maintenance',
      en: 'Repairs and maintenance',
      fr: 'Réparations et entretien',
    ),
    ExpenseType(
      key: 'Salaries wages and benefits',
      en: 'Salaries wages and benefits',
      fr: 'Salaires, traitements et avantages sociaux',
    ),
    ExpenseType(
      key: 'Property taxes',
      en: 'Property taxes',
      fr: 'Impôts fonciers',
    ),
    ExpenseType(key: 'Travel', en: 'Travel', fr: 'Déplacements'),
    ExpenseType(key: 'Utilities', en: 'Utilities', fr: 'Services publics'),
    ExpenseType(
      key: 'Motor vehicle expenses',
      en: 'Motor vehicle expenses',
      fr: 'Frais de véhicule à moteur',
    ),
    ExpenseType(
      key: 'Other expenses (BusAuto)',
      en: 'Other expenses (BusAuto)',
      fr: 'Autres dépenses (véhicule d’entreprise)',
    ),
    ExpenseType(
      key: 'Other expenses',
      en: 'Other expenses',
      fr: 'Autres dépenses',
    ),
  ];

  final List<ExpenseType> usExpenseTypes = [
    ExpenseType(key: 'Advertising', en: 'Advertising', fr: 'Publicité'),
    ExpenseType(
      key: 'Auto and travel (see instructions)',
      en: 'Auto and travel (see instructions)',
      fr: 'Automobile et déplacements (voir instructions)',
    ),
    ExpenseType(
      key: 'Cleaning and maintenance',
      en: 'Cleaning and maintenance',
      fr: 'Nettoyage et entretien',
    ),
    ExpenseType(key: 'Commissions', en: 'Commissions', fr: 'Commissions'),
    ExpenseType(key: 'Insurance', en: 'Insurance', fr: 'Assurance'),
    ExpenseType(
      key: 'Legal and other professional fees',
      en: 'Legal and other professional fees',
      fr: 'Frais juridiques et autres honoraires professionnels',
    ),
    ExpenseType(
      key: 'Management fees',
      en: 'Management fees',
      fr: 'Frais de gestion',
    ),
    ExpenseType(
      key: 'Mortgage interest paid to banks, etc. (see instructions)',
      en: 'Mortgage interest paid to banks, etc. (see instructions)',
      fr: 'Intérêts hypothécaires payés aux banques, etc. (voir instructions)',
    ),
    ExpenseType(
      key: 'Other interest',
      en: 'Other interest',
      fr: 'Autres intérêts',
    ),
    ExpenseType(key: 'Repairs', en: 'Repairs', fr: 'Réparations'),
    ExpenseType(key: 'Supplies', en: 'Supplies', fr: 'Fournitures'),
    ExpenseType(key: 'Taxes', en: 'Taxes', fr: 'Impôts'),
    ExpenseType(key: 'Utilities', en: 'Utilities', fr: 'Services publics'),
    ExpenseType(
      key: 'Depreciation expense or depletion',
      en: 'Depreciation expense or depletion',
      fr: 'Charge d’amortissement ou épuisement',
    ),
    ExpenseType(
      key: 'Other (list)',
      en: 'Other (list)',
      fr: 'Autre (à préciser)',
    ),
  ];

  List<ExpenseType> getExpenseTypes(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    return auth.user?.regCountry == 'ca' ? caExpenseTypes : usExpenseTypes;
  }

  final List<ExpenseType> dynamicExpenseOptions = getExpenseTypes(context);
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
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Close Button
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
                                initialDate: selectedMonth ?? DateTime.now(),
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
                            value: selectedYear,
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

                    const SizedBox(height: 15),

                    /// Income Type Row
                    Row(
                      children: [
                        // First dropdown
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                              AppLocalizations.of(context)!.translate("incomeType") ??
                              '',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<IncomeTypeOption>(
                                value: selectedIncomeType != null
                                    ? dynamicIncomeOptions.firstWhere(
                                      (item) => item.id == selectedIncomeType!.id,
                                )
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  "Income Type",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                items: dynamicIncomeOptions.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedIncomeType = val),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Second dropdown
                        Flexible(
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                              AppLocalizations.of(context)!.translate("expenseText") ??
                              '',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<ExpenseType>(
                                value: selectedExpenseType != null
                                    ? dynamicExpenseOptions.firstWhere(
                                      (item) => item.key == selectedExpenseType!.key,
                                )
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  "Expense Type",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                items: dynamicExpenseOptions.map((item) {
                                  return DropdownMenuItem<ExpenseType>(
                                    value: item, // still use full object
                                    child: Text(
                                      AppLocalizations.of(context)!.locale.languageCode == 'fr'
                                          ? item.fr
                                          : item.en,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 15),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedExpenseType = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            ],
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
                              selectedIncomeType =
                                  null; // <-- clear Income Type
                              selectedExpenseType =
                                  null; // <-- clear Expense Type
                              fromController.clear();
                              toController.clear();
                              monthController.clear();
                            });

                            provider.clearDatabaseFilters();
                            provider.getAllRegularEntriesApi(
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
                            final yearToUse = selectedYear ?? DateTime.now().year.toString();

                            // Update provider values
                            provider.selectedIncomeType = selectedIncomeType;
                            provider.selectedExpenseType = selectedExpenseType;
                            provider.fromDate = fromDate;
                            provider.toDate = toDate;
                            provider.selectedMonth = selectedMonth;
                            provider.selectedYear = yearToUse;

                            // Call API
                            provider.getAllRegularEntriesApi(
                              context: context,
                              planId: planId,
                              year: selectedYear,
                              fromDate: fromDate,
                              toDate: toDate,
                              month: selectedMonth,
                              incomeTypeId: selectedIncomeType?.id,
                              expenseType: selectedExpenseType?.key,
                            );

                            Navigator.of(context).pop(); // Close dialog immediately
                          },

                          child:
                             Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("filter") ??
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
