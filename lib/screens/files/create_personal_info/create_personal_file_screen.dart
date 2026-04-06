import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/files/create_personal_info/widget/increament_decreament_double_widget.dart';
import 'package:storatax/screens/files/create_personal_info/widget/increament_decreament_widget.dart';
import 'package:storatax/screens/files/create_personal_info/widget/table_header_widget.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import 'package:storatax/models/get_personal_info_model/get_personal_info_model.dart'
    as personal;

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';

class CreatePersonalFileScreen extends StatefulWidget {
  const CreatePersonalFileScreen({super.key});

  @override
  State<CreatePersonalFileScreen> createState() =>
      _CreatePersonalFileScreenState();
}

class _CreatePersonalFileScreenState extends State<CreatePersonalFileScreen> {
  final List<String> years = List.generate(7, (i) {
    final currentYear = DateTime.now().year;
    return '${currentYear - i}';
  });
  List<personal.Dependents> dependents = [];
  String? selectedYear;
  DateTime? selectedDate;
  bool personalInfoNoChange = false;
  bool spouseInfo = false;

  String selectedLanguage = "fr";
  String canadianCitizen = "Yes";
  String selectedProvince = "Ontario";
  String maritalStatus = "Single";
  String hasMaritalStatusChanged = "Yes";
  String rl19Value = "Yes";
  String estate = "No";
  String residence = "No";
  String taxReturn = "No";
  DateTime? maritalChangeDate;
  int ramq = 0;
  int pMonths = 0;
  double amount = 0.0;
  String ownsForeignProperty = "Yes";

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  // Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController homeAddressController = TextEditingController();
  final TextEditingController workPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController faxController = TextEditingController();
  final TextEditingController homePhoneController = TextEditingController();
  final TextEditingController maritalChangeDetailsController =
      TextEditingController();
  final TextEditingController commonLawPartnerController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year.toString();
    if (years.contains(currentYear)) {
      selectedYear = currentYear;
      selectedDate = DateTime.now();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<TaxManagerViewModel>();

      await provider.getPreviousInfoApi(context);
      final previous = provider.getPreviousInfoModel?.data;

      final currentYear = DateTime.now().year.toString();
      if (years.contains(currentYear)) {
        selectedYear = currentYear;
        selectedDate = DateTime.now();
      }
      if (previous == null) return;

      // 🔍 DEBUG: print dependents before mapping
      print("Fetched dependents: ${previous.dependents?.length}");
      previous.dependents?.forEach((d) {
        print(
          "Dependent -> name: ${d.name}, dob: ${d.dob}, disability: ${d.disability}",
        );
      });

      setState(() {
        selectedYear = previous.year ?? selectedYear;
        personalInfoNoChange = previous.noChange ?? false;

        firstNameController.text = previous.firstName ?? '';
        lastNameController.text = previous.lastName ?? '';
        homeAddressController.text = previous.homeAddress ?? '';
        workPhoneController.text = previous.workPhone ?? '';
        emailController.text = previous.email ?? '';
        faxController.text = previous.fax ?? '';
        homePhoneController.text = previous.homePhone ?? '';
        selectedLanguage =
            (previous.languageOfCorrespondence ?? "fr")
                    .toLowerCase()
                    .startsWith("f")
                ? "fr"
                : "en";
        canadianCitizen =
            (previous.canadianCitizen ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';
        selectedProvince = _mapCodeToProvince(previous.provinceOfResidence);
        maritalStatus = _capitalize(previous.maritalStatus ?? "Single");
        hasMaritalStatusChanged =
            (previous.maritalStatusChanged ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';

        if (previous.maritalChangeDate != null) {
          maritalChangeDate = DateTime.tryParse(previous.maritalChangeDate!);
        }

        maritalChangeDetailsController.text =
            previous.maritalChangeDetails ?? '';
        spouseInfo = previous.noSpouse ?? false;
        commonLawPartnerController.text = previous.spouseName ?? '';
        rl19Value =
            (previous.rl19 ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';
        estate =
            (previous.realEstateDisposition ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';
        residence =
            (previous.principalResidenceDisposition ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';
        taxReturn =
            (previous.firstTaxReturn ?? false)
                ? AppLocalizations.of(context)!.translate("yesText") ?? ''
                : AppLocalizations.of(context)!.translate("noText") ?? '';
        ramq = previous.ramqMonths ?? 0;
        pMonths = previous.privateInsuranceMonths ?? 0;
        amount = double.tryParse(previous.rl19Amount ?? '0.0') ?? 0.0;

        // 🔁 map dependents to personal.Dependents
        dependents =
            (previous.dependents ?? [])
                .map(
                  (d) => personal.Dependents(
                    name: d.name,
                    disability: d.disability,
                    dob: d.dob,
                    citizenship: d.citizenship,
                    months: d.months,
                    income: d.income,
                  ),
                )
                .toList();
      });
    });
  }

  String _mapCodeToProvince(String? code) {
    switch (code) {
      case 'QC':
        return 'Quebec';
      case 'ON':
        return 'Ontario';
      case 'BC':
        return 'British Columbia';
      case 'AB':
        return 'Alberta';
      case 'MB':
        return 'Manitoba';
      case 'NB':
        return 'New Brunswick';
      case 'NL':
        return 'Newfoundland and Labrador';
      case 'NS':
        return 'Nova Scotia';
      case 'PE':
        return 'Prince Edward Island';
      case 'SK':
        return 'Saskatchewan';
      case 'NT':
        return 'Northwest Territories';
      case 'NU':
        return 'Nunavut';
      case 'YT':
        return 'Yukon';
      default:
        return 'Ontario';
    }
  }

  InputDecoration buildInputDecoration(String hint, {bool disabled = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13),
      filled: true,
      fillColor: disabled ? Colors.grey.shade200 : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.blackColor, width: 0.8),
      ),
    );
  }

  Widget buildRadioGroup({
    required String title,
    required List<Map<String, String>> options,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              options.map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.goldenOrangeColor,

                    // ✅ UI label
                    title: Text(
                      option['label']!,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),

                    // ✅ stable value
                    value: option['value']!,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int rowCount = dependents.length > 3 ? dependents.length : 3;
    final maritalOptions = [
      "Single",
      "Married",
      "Divorced",
      "Separated",
      "Widowed",
      "Living common-law",
    ];

    final maritalLabels =
        maritalOptions.map((status) {
          switch (status) {
            case "Single":
              return AppLocalizations.of(context)!.translate("singleText") ??
                  '';
            case "Married":
              return AppLocalizations.of(context)!.translate("marriedText") ??
                  '';
            case "Divorced":
              return AppLocalizations.of(context)!.translate("divorcedText") ??
                  '';
            case "Separated":
              return AppLocalizations.of(context)!.translate("sepText") ?? '';
            case "Widowed":
              return AppLocalizations.of(context)!.translate("widText") ?? '';
            case "Living common-law":
              return AppLocalizations.of(context)!.translate("livingText") ??
                  '';
            default:
              return status;
          }
        }).toList();

    return Consumer<TaxManagerViewModel>(
      builder: (context, taxManager, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("incomeTaxInfoForm") ??
                '',
            showBackButton: true,
            onBackTap: () => Navigator.pop(context),
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
                child:
                    taxManager.isLoading
                        ? Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: AppColors.blackColor,
                              strokeWidth: 4,
                            ),
                          ),
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                            top: 30,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("taxYearText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                decoration: buildInputDecoration(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("selectYearText") ??
                                      '',
                                ),
                                value: selectedYear,
                                items:
                                    years
                                        .toSet()
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedYear = value;
                                    if (value != null) {
                                      final year = int.parse(value);
                                      final now = DateTime.now();
                                      selectedDate = DateTime(
                                        year,
                                        now.month,
                                        now.day,
                                      );
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Checkbox(
                                    value: personalInfoNoChange,
                                    activeColor: AppColors.goldenOrangeColor,
                                    onChanged: (bool? value) {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        personalInfoNoChange = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.translate(
                                            "personalInfoNoChangeText",
                                          ) ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // --- Personal Info Section ---
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("personalInformationText") ??
                                    '',
                              ),
                              const SizedBox(height: 15),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: firstNameController,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration(
                                          "${AppLocalizations.of(context)!.translate("firstNameText") ?? ''}*",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: lastNameController,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration(
                                          "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}*",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: TextFormField(
                                  controller: homeAddressController,
                                  keyboardType: TextInputType.streetAddress,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  decoration: buildInputDecoration(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("homeAddressText") ??
                                        '',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: workPhoneController,
                                        keyboardType: TextInputType.phone,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("workPhoneText") ??
                                              '',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration(
                                          "${AppLocalizations.of(context)!.translate("emailText") ?? ''}*",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: faxController,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration("Fax"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: homePhoneController,
                                        keyboardType: TextInputType.phone,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                        decoration: buildInputDecoration(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("homePhoneText") ??
                                              '',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("langCorresPondenceText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "fr",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("frenchText") ??
                                          '',
                                    },
                                    {
                                      "value": "en",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("englishText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: selectedLanguage.toLowerCase(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLanguage = value!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("canadianCText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: canadianCitizen,
                                  onChanged: (value) {
                                    setState(() {
                                      canadianCitizen = value!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("provinceResidenceText") ??
                                    '',
                              ),
                              const SizedBox(height: 8),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...[
                                      "Alberta",
                                      "British Columbia",
                                      "Manitoba",
                                      "New Brunswick",
                                      "Newfoundland and Labrador",
                                      "Nova Scotia",
                                      "Northwest Territories",
                                      "Nunavut",
                                      "Ontario",
                                      "Prince Edward Island",
                                      "Quebec",
                                      "Saskatchewan",
                                      "Yukon",
                                    ].map((province) {
                                      return RadioListTile<String>(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor:
                                            AppColors.goldenOrangeColor,
                                        title: Text(
                                          province,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color:
                                                personalInfoNoChange
                                                    ? Colors.grey
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                        value: province,
                                        groupValue: selectedProvince,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedProvince = value!;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("maritalStatusText") ??
                                    '',
                              ),
                              const SizedBox(height: 8),

                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 0,
                                  children: List.generate(
                                    maritalOptions.length,
                                    (index) {
                                      final value = maritalOptions[index];
                                      final label = maritalLabels[index];
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<String>(
                                            value: value,
                                            groupValue: maritalStatus,
                                            activeColor:
                                                AppColors.goldenOrangeColor,
                                            onChanged: (value) {
                                              setState(() {
                                                maritalStatus = value!;
                                              });
                                            },
                                          ),
                                          Text(
                                            label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("maritalStatusChanged") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: hasMaritalStatusChanged,
                                  onChanged: (value) {
                                    setState(() {
                                      hasMaritalStatusChanged = value!;
                                    });
                                  },
                                ),
                              ),

                              if (hasMaritalStatusChanged == "Yes") ...[
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("yesSpouseText") ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // --- Date Picker Field ---
                                IgnorePointer(
                                  ignoring: personalInfoNoChange,
                                  child: GestureDetector(
                                    onTap: () async {
                                      DateTime now = DateTime.now();
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: maritalChangeDate ?? now,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(now.year + 1),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          maritalChangeDate = picked;
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: buildInputDecoration(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("selectDateText") ??
                                              '',
                                        ),
                                        controller: TextEditingController(
                                          text:
                                              maritalChangeDate != null
                                                  ? "${maritalChangeDate!.day}-${maritalChangeDate!.month}-${maritalChangeDate!.year}"
                                                  : "",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // --- Description Box ---
                                IgnorePointer(
                                  ignoring: personalInfoNoChange,
                                  child: TextFormField(
                                    controller: maritalChangeDetailsController,
                                    maxLines: 4,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                    decoration: buildInputDecoration(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("provideDetailsText") ??
                                          '',
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("spouseInfoText") ??
                                    '',
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: spouseInfo,
                                    activeColor: AppColors.goldenOrangeColor,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        spouseInfo = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("noSpouseText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("spouseCommonLawText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blackColor,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // --- Description Box ---
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: TextFormField(
                                  controller: commonLawPartnerController,
                                  keyboardType: TextInputType.name,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  decoration: buildInputDecoration(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("commonLawText") ??
                                        '',
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("foreignPropertyText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: ownsForeignProperty,
                                  onChanged: (value) {
                                    setState(() {
                                      ownsForeignProperty = value!;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("qcPerscText") ??
                                    '',
                              ),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: IncrementDecrementFileWidget(
                                  labelText:
                                      "Drug Insurance: RAMQ (government) (months)",
                                  initialValue: ramq,
                                  onChanged: (value) {
                                    setState(() {
                                      ramq = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("privateMonthsText") ??
                                    '',
                              ),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: IncrementDecrementFileWidget(
                                  labelText: "Private (months)",
                                  initialValue: pMonths,
                                  onChanged: (value) {
                                    setState(() {
                                      pMonths = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("qcAdvancePaymentText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "RL-19: ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                  IgnorePointer(
                                    ignoring: personalInfoNoChange,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Radio<String>(
                                          value: "Yes",
                                          groupValue: rl19Value,
                                          activeColor:
                                              AppColors.goldenOrangeColor,
                                          onChanged: (value) {
                                            setState(() {
                                              rl19Value = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("yesText") ??
                                              '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                                personalInfoNoChange
                                                    ? Colors
                                                        .grey
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Radio<String>(
                                          value: "No",
                                          groupValue: rl19Value,
                                          activeColor:
                                              AppColors.goldenOrangeColor,
                                          onChanged: (value) {
                                            setState(() {
                                              rl19Value = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("noText") ??
                                              '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                                personalInfoNoChange
                                                    ? Colors.grey
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              _labelText(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("amountText") ??
                                    '',
                              ),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: IncrementDecrementFileDouble(
                                  labelText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("amountText") ??
                                      '',
                                  initialValue: amount,
                                  onChanged: (value) {
                                    setState(() {
                                      amount = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("realEstateText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: estate,
                                  onChanged: (value) {
                                    setState(() {
                                      estate = value!;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: 12),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("principleResText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: residence,
                                  onChanged: (value) {
                                    setState(() {
                                      residence = value!;
                                    });
                                  },
                                ),
                              ),

                              // Title and radio
                              SizedBox(height: 12),
                              IgnorePointer(
                                ignoring: personalInfoNoChange,
                                child: buildRadioGroup(
                                  title:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("firstTaxText") ??
                                      '',
                                  options: [
                                    {
                                      "value": "Yes",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("yesText") ??
                                          '',
                                    },
                                    {
                                      "value": "No",
                                      "label":
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("noText") ??
                                          '',
                                    },
                                  ],
                                  groupValue: taxReturn,
                                  onChanged: (value) {
                                    setState(() {
                                      taxReturn = value!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("dependantInfoText") ??
                                          '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        TableHeader(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("childNameText") ??
                                              '',
                                        ),
                                        TableHeader(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("disText") ??
                                              '',
                                        ),
                                        TableHeader(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("birthText") ??
                                              '',
                                        ),
                                        TableHeader(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("citizenshipText") ??
                                              '',
                                        ),
                                        TableHeader(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("monthLivedText") ??
                                              '',
                                        ),
                                        TableHeader(
                                          "${AppLocalizations.of(context)!.translate("incomeText") ?? ''} (CAD \$)",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    IgnorePointer(
                                      ignoring: personalInfoNoChange,
                                      child: Column(
                                        children: List.generate(rowCount, (i) {
                                          final dep =
                                              i < dependents.length
                                                  ? dependents[i]
                                                  : null;

                                          print(
                                            "Building DependentRow for index $i with data: ${dep?.name ?? 'empty'}",
                                          );

                                          return DependentRow(
                                            key: ValueKey(dep?.name ?? i),
                                            initialDependent: dep,
                                            onChanged: (dependentDataEdit) {
                                              if (i < dependents.length) {
                                                dependents[i] =
                                                    dependentDataEdit;
                                              } else {
                                                dependents.add(
                                                  dependentDataEdit,
                                                );
                                              }
                                            },
                                          );
                                        }),
                                      ),
                                    ),

                                    _labelText(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("sensitiveInfoText") ??
                                          '',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              AppButton(
                                onPressed: () {
                                  if (selectedYear == null) {
                                    Utils.toastMessage(
                                      AppLocalizations.of(context)!
                                          .translate("pleaseSelectYear") ??
                                          '',
                                    );
                                    return;
                                  }

                                  if (personalInfoNoChange) {
                                    final payload = {
                                      "year": selectedYear,
                                      "no_change": true,
                                    };

                                    debugPrint("📦 FINAL PAYLOAD => ${jsonEncode(payload)}");
                                    taxManager.createPersonalInfoApi(context, payload);
                                    return;
                                  }

                                  if (firstNameController.text.isEmpty ||
                                      lastNameController.text.isEmpty ||
                                      homeAddressController.text.isEmpty ||
                                      workPhoneController.text.isEmpty ||
                                      emailController.text.isEmpty) {
                                    Utils.toastMessage("Please fill all required fields");
                                    return;
                                  }

                                  final payload = {
                                    "year": selectedYear,
                                    "no_change": personalInfoNoChange,
                                    "first_name": firstNameController.text,
                                    "last_name": lastNameController.text,
                                    "home_address": homeAddressController.text,
                                    "work_phone": workPhoneController.text,
                                    "home_phone": homePhoneController.text,
                                    "fax": faxController.text,
                                    "email": emailController.text,

                                    // ✅ MUST MATCH POSTMAN
                                    "language_of_correspondence":
                                    sanitizeLanguage(selectedLanguage), // "english" / "french"

                                    "canadian_citizen": canadianCitizen == "Yes",
                                    "province_of_residence":
                                    _mapProvinceToCode(selectedProvince),
                                    "marital_status": maritalStatus.toLowerCase(),
                                    "marital_status_changed":
                                    hasMaritalStatusChanged == "Yes",
                                    "marital_change_date":
                                    maritalChangeDate?.toIso8601String(),
                                    "marital_change_details":
                                    maritalChangeDetailsController.text,
                                    "spouse_name":
                                    commonLawPartnerController.text,
                                    "ramq_months": ramq,
                                    "private_insurance_months": pMonths,
                                    "rl19": rl19Value == "Yes",
                                    "rl19_amount": amount,
                                    "real_estate_disposition":
                                    estate == "Yes",
                                    "principal_residence_disposition":
                                    residence == "Yes",
                                    "first_tax_return": taxReturn == "Yes",
                                    "dependents":
                                    dependents.map((d) => d.toJson()).toList(),
                                  };

                                  debugPrint("📦 FINAL PAYLOAD => ${jsonEncode(payload)}");

                                  // 🚀 ONLY ONE CALL
                                  taxManager.createPersonalInfoApi(context, payload);
                                },

                                btnText:
                                    AppLocalizations.of(
                                      context,
                                    )!.translate("saveText") ??
                                    '',
                                isLoading: taxManager.isLoading,
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.blackColor,
      ),
    );
  }
  String sanitizeLanguage(String? value) {
    if (value == null) return "english";

    switch (value.toLowerCase()) {
      case "en":
      case "english":
        return "english";
      case "fr":
      case "french":
        return "french";
      default:
        return "english";
    }
  }


  String _mapProvinceToCode(String province) {
    switch (province) {
      case "Ontario":
        return "ON";
      case "Quebec":
        return "QC";
      case "British Columbia":
        return "BC";
      case "Alberta":
        return "AB";
      case "Manitoba":
        return "MB";
      case "New Brunswick":
        return "NB";
      case "Newfoundland and Labrador":
        return "NL";
      case "Nova Scotia":
        return "NS";
      case "Prince Edward Island":
        return "PE";
      case "Saskatchewan":
        return "SK";
      case "Yukon":
        return "YT";
      case "Northwest Territories":
        return "NT";
      case "Nunavut":
        return "NU";
      default:
        return "ON";
    }
  }
}
