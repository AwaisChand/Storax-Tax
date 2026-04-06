import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../models/expense_type_model/expense_type_model.dart';
import '../../../../../../../models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/drop_down_widget.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../rental_property_addressing/widget/increment_decrement_double_widget.dart';
import '../../rental_property_tab_screen/rental_property_tab_screen.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key, this.planId});
  final int? planId;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';
  String get apiType {
    if (selectedType == typeIncome) return 'Income';
    return 'Expense';
  }

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

  File? selectedImage;
  DateTime? selectedDate;
  String selectedType = typeExpense;
  String? selectedExpenseType;
  int? selectedIncomeTypeId;
  String? onlyForRentalType = 'No';
  double personalUsePercentage = 0.0;

  final TextEditingController enterOtherExpenseNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.planId != null) {
        context.read<RentalPropertyViewModel>().getIncomeTypesApi(
          context: context,
          planId: widget.planId!,
        );
      }
    });
    Future.microtask(() {
      context.read<AuthViewModel>().clearPickedImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalVM, _) {
        return Scaffold(
          // extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("addEntryText") ?? '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalPropertyTabScreen(),
                ),
              );
            },
          ),
          body: Stack(
            children: [
              // Background image
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
              rentalVM.otherLoading
                  ? Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: AppColors.blackColor,
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            right: 20,
                            left: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.goldenOrangeColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Information",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              buildForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget buildForm() {
    final rentalVM = context.watch<RentalPropertyViewModel>();
    final locale = Localizations.localeOf(context).languageCode;
    final expenseList = getExpenseTypes(context);
    final types = [typeIncome, typeExpense];

    final isIncome = selectedType == typeIncome;

    final List<IncomeTypeOption> dynamicIncomeOptions =
        widget.planId != null
            ? rentalVM.getIncomeTypeOptions(widget.planId!).map((e) {
              return IncomeTypeOption(
                id: e.id,
                name: e.name,
                rawEntry: e.rawEntry ?? e,
              );
            }).toList()
            : [];

    IncomeTypeOption? selectedIncomeOption;
    if (selectedIncomeTypeId != null) {
      for (var opt in dynamicIncomeOptions) {
        if (opt.id == selectedIncomeTypeId) {
          selectedIncomeOption = opt;
          break;
        }
      }
    }

    final normalizedExpenseType =
        selectedExpenseType?.toLowerCase().trim() ?? '';

    final showOnlyForRentalDropdown =
        normalizedExpenseType == 'other expenses (busauto)' ||
        normalizedExpenseType == 'other expenses' ||
        normalizedExpenseType == 'repairs' ||
        normalizedExpenseType == 'repairs and maintenance' ||
        normalizedExpenseType == 'other (list)';

    final onlyForRentalOptions = ['Yes', 'No'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Date
        Text(
          "Date",
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now();

            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year - 6, 1, 1),
              lastDate: DateTime(2100), // ✅ allows future dates
            );

            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: AppColors.goldenOrangeColor,
              ),
            ),
            child: Text(
              selectedDate != null
                  ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                  : "mm/dd/yyyy",
              style: TextStyle(
                color:
                    selectedDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        /// Type
        GenericDropdown<String>(
          label: AppLocalizations.of(context)!.translate("type") ?? '',
          hint: AppLocalizations.of(context)!.translate("chooseTypeText") ?? '',
          value: selectedType,
          items:
              types
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t == typeIncome
                            ? AppLocalizations.of(
                                  context,
                                )!.translate("incomeText") ??
                                'Income'
                            : AppLocalizations.of(
                                  context,
                                )!.translate("expenseText") ??
                                'Expense',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            setState(() {
              selectedType = val!;
              selectedExpenseType = null;
              selectedIncomeTypeId = null;
              onlyForRentalType = 'No';
              enterOtherExpenseNameController.clear();
            });
          },
        ),
        const SizedBox(height: 12),

        /// Amount
        Text(
          AppLocalizations.of(context)!.translate("amountText") ?? '',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        IncrementDecrementFieldDouble(
          labelText: "0.00",
          initialValue: personalUsePercentage,
          onChanged: (value) {
            setState(() {
              personalUsePercentage = value;
            });
          },
        ),
        const SizedBox(height: 12),

        /// Income or Expense Dropdown
        if (isIncome)
          GenericDropdown<int>(
            label:
                AppLocalizations.of(context)!.translate("incomeTypeText") ?? '',
            hint: "Choose Income Type",
            value: selectedIncomeTypeId,
            items:
                dynamicIncomeOptions
                    .map(
                      (opt) => DropdownMenuItem<int>(
                        value: opt.id,
                        child: Text(
                          opt.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              setState(() {
                selectedIncomeTypeId = val;
              });
            },
          )
        else
          GenericDropdown<String>(
            label: AppLocalizations.of(context)!.translate("expenseType") ?? '',
            hint: "Choose Expense Type",
            value: selectedExpenseType,
            items:
                expenseList
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          locale == 'fr' ? e.fr : e.en,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              setState(() {
                selectedExpenseType = val;
                onlyForRentalType = 'No'; // reset when changing type
              });
            },
          ),

        if (isIncome &&
            selectedIncomeTypeId != null &&
            selectedIncomeOption != null)
          buildAssociatedInfo(selectedIncomeOption.rawEntry),

        /// Expense-specific fields
        if (!isIncome) ...[
          const SizedBox(height: 12),

          // ✅ Only-for-rental dropdown
          if (showOnlyForRentalDropdown)
            GenericDropdown<String>(
              label:
                  AppLocalizations.of(context)!.translate("onlyRentalText") ??
                  '',
              hint: "Choose",
              value:
                  onlyForRentalOptions.contains(onlyForRentalType)
                      ? onlyForRentalType
                      : null,
              items:
                  onlyForRentalOptions
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t,
                          child: Text(
                            t,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    onlyForRentalType = val;
                  });
                }
              },
            ),

          // Other Expense Name
          if (normalizedExpenseType == 'other expenses' ||
              normalizedExpenseType == 'other (list)') ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.translate("otherExpenseName") ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: enterOtherExpenseNameController,
              hintText:
                  AppLocalizations.of(context)!.translate("enterExpenseName") ??
                  '',
              textInputType: TextInputType.name,
            ),
          ],
        ],

        const SizedBox(height: 20),

        /// File Upload (only for Expense)
        if (!isIncome)
          Consumer<AuthViewModel>(
            builder: (context, authProvider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.goldenOrangeColor,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.shade50,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 50,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                            context,
                          )!.translate("uploadFileText") ??
                          '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.pureGrayColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenOrangeColor,
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.photo_library,
                                      color: Colors.orange,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("galleryText") ??
                                          '',
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picked =
                                          await authProvider
                                              .pickImageFromGallery();
                                      setState(() {
                                        selectedImage = picked;
                                      });
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.orange,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("cameraText") ??
                                          '',
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picked =
                                          await authProvider
                                              .pickSingleImageFromCamera();
                                      setState(() {
                                        selectedImage = picked;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("chooseFileText") ??
                            '',
                      ),
                    ),
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Image.file(
                              selectedImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedImage!.path.split('/').last,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

        const SizedBox(height: 8),

        /// Action Buttons
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
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.translate("cancelText") ?? '',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
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
                  if (selectedDate == null) {
                    Utils.toastMessage("Please select a date");
                    return;
                  }
                  if (isIncome && selectedIncomeTypeId == null) {
                    Utils.toastMessage("Please choose an income type");
                    return;
                  }
                  if (!isIncome && selectedExpenseType == null) {
                    Utils.toastMessage("Please choose an expense type");
                    return;
                  }

                  if (isIncome) {
                    final Map<String, dynamic> incomeData = {
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                      'type': apiType,
                      'income_type_id': selectedIncomeTypeId,
                      'amount': personalUsePercentage,
                      'client_plans_id': widget.planId,
                    };
                    rentalVM.createEntriesApi(context, incomeData);
                  } else {
                    final Map<String, dynamic> expenseData = {
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                      'type': apiType,
                      'expense_type': selectedExpenseType,
                      'other_expense_name':
                          enterOtherExpenseNameController.text.toString(),
                      'only_for_rental':
                          showOnlyForRentalDropdown ? onlyForRentalType : null,
                      'amount': personalUsePercentage,
                      'client_plans_id': widget.planId,
                    };
                    rentalVM.createEntriesProofApi(
                      context,
                      expenseData,
                      selectedImage,
                    );
                  }
                },
                child:
                    rentalVM.isLoading
                        ? Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: AppColors.blackColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                        : Text(
                          AppLocalizations.of(context)!.translate("saveText") ??
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
      ],
    );
  }
}
