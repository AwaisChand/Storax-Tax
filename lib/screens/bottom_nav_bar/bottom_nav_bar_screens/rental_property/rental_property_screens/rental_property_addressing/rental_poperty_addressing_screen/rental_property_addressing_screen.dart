import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_button.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/rental_property_view_model/rental_property_view_model.dart';
import '../widget/increment_decrement_double_widget.dart';
import '../widget/increment_decrement_int_widget.dart';

class RentalPropertyAddressingScreen extends StatefulWidget {
  const RentalPropertyAddressingScreen({super.key, required this.planId});
  final int planId;

  @override
  State<RentalPropertyAddressingScreen> createState() =>
      _RentalPropertyAddressingScreenState();
}

class _RentalPropertyAddressingScreenState
    extends State<RentalPropertyAddressingScreen> {
  final addressController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final suitController = TextEditingController();
  final otherPropertyTypeController = TextEditingController();

  double yourPercentage = 0.0;
  double personalUsePercentage = 0.0;
  int numberOfUnits = 0;
  int fairRentalDays = 0;
  int personalUseDays = 0;

  bool _hasAppliedResponse = false;
  String? selectedPropertyType = 'Single Family Residence';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalPropertyViewModel>().rentalAccountAddressSettingApi(
        context: context,
        planId: widget.planId,
      );
    });
  }

  void _applyApiData(dynamic apiData) {
    setState(() {
      numberOfUnits = apiData.numberOfUnits ?? 0;
      yourPercentage = _toDouble(apiData.yourPercentage) ?? 0.0;
      personalUsePercentage = _toDouble(apiData.personalUsePercentage) ?? 0.0;
      fairRentalDays = apiData.fairRentalDays ?? 0;
      personalUseDays = apiData.personalUseDays ?? 0;

      addressController.text = apiData.address ?? '';
      streetController.text = apiData.streetPoBox ?? '';
      cityController.text = apiData.city ?? '';
      provinceController.text = apiData.province ?? '';
      postalCodeController.text = apiData.postalCode ?? '';
      suitController.text = apiData.appartmentOrSuit ?? '';
      selectedPropertyType = apiData.typeOfProperty ?? '';

      otherPropertyTypeController.text = apiData.otherDescribe ?? '';
    });
  }

  void _clearFormState() {
    setState(() {
      numberOfUnits = 0;
      yourPercentage = 0.0;
      personalUsePercentage = 0.0;
      fairRentalDays = 0;
      personalUseDays = 0;

      addressController.clear();
      streetController.clear();
      cityController.clear();
      provinceController.clear();
      postalCodeController.clear();
      suitController.clear();
      otherPropertyTypeController.clear();
      selectedPropertyType = null;
    });
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  void dispose() {
    addressController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    suitController.dispose();
    otherPropertyTypeController.dispose();
    super.dispose();
  }

  final List<String> propertyTypes = [
    'Single Family Residence',
    'Multi-Family Residence',
    'Vacation/Short-Term Rental',
    'Commercial',
    'Land',
    'Royalties',
    'Self-Rental',
    'Other (describe)',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();
    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProvider, _) {
        final model = rentalProvider.accountSettingModelFor(widget.planId);
        final apiData = model?.data;

        if (!_hasAppliedResponse && model != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (model.status == 0) {
              _clearFormState();
            } else if (apiData != null) {
              _applyApiData(apiData);
            }
            _hasAppliedResponse = true;
          });
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.backgroundImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: Utils.setHeight(context) * 0.15,
                      padding: EdgeInsets.only(
                        top: Utils.setHeight(context) * 0.06,
                        right: 20,
                        left: 20,
                      ),
                      width: double.infinity,
                      color: AppColors.goldenOrangeColor,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("propertyAddressSettingsText") ??
                                  '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child:
                          rentalProvider.isLoading
                              ? SizedBox(
                                height: Utils.setHeight(context) * 0.7,
                                child: const Center(
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                    ),
                                  ),
                                ),
                              )
                              : model == null
                              ? Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (model.status == 0)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Text(
                                        AppLocalizations.of(context)!.translate(
                                              "enterAccDetailsText",
                                            ) ??
                                            '',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.goldenOrangeColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                "propertyAddressSettingsText",
                                              ) ??
                                              '',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  // Address Fields
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("addressNumText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: addressController,
                                    hintText:
                                        apiData?.address ??
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("addressNumText") ??
                                        '',
                                    textInputType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("streetText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: streetController,
                                    hintText:
                                        apiData?.streetPoBox ??
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("streetText") ??
                                        '',
                                    textInputType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("cityText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: cityController,
                                    hintText:
                                        apiData?.city ??
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("cityText") ??
                                        '',
                                    textInputType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    authProvider.user?.regCountry == 'ca'
                                        ? AppLocalizations.of(
                                              context,
                                            )!.translate("provinceText") ??
                                            ''
                                        : AppLocalizations.of(
                                              context,
                                            )!.translate("stateText") ??
                                            '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: provinceController,
                                    hintText:
                                        apiData?.province ??
                                        (authProvider.user?.regCountry == 'ca'
                                            ? 'Province'
                                            : 'State'),
                                    textInputType: TextInputType.text,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("postalCodeText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    controller: postalCodeController,
                                    hintText:
                                        apiData?.postalCode ??
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("postalCodeText") ??
                                        '',
                                    textInputType: TextInputType.text,
                                  ),
                                  if (authProvider.user?.regCountry ==
                                      'ca') ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("AptText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: suitController,
                                      hintText:
                                          apiData?.appartmentOrSuit ??
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("AptText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("percentageText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IncrementDecrementFieldDouble(
                                      labelText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("percentageText") ??
                                          '',
                                      initialValue: yourPercentage,
                                      onChanged: (value) {
                                        setState(() {
                                          yourPercentage = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("personalUseText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IncrementDecrementFieldDouble(
                                      labelText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("personalUseText") ??
                                          '',
                                      initialValue: personalUsePercentage,
                                      onChanged: (value) {
                                        setState(() {
                                          personalUsePercentage = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("NumOfUnits") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IncrementDecrementFieldInt(
                                      labelText: numberOfUnits.toString(),
                                      initialValue: numberOfUnits,
                                      onChanged: (value) {
                                        setState(() {
                                          numberOfUnits = value;
                                        });
                                      },
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 15),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("typeText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedPropertyType,
                                      items:
                                          propertyTypes
                                              .map(
                                                (type) => DropdownMenuItem(
                                                  value: type,
                                                  child: Text(
                                                    type,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          selectedPropertyType = v;
                                          if (v != 'Other (describe)') {
                                            otherPropertyTypeController.clear();
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.blackColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.blackColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 13,
                                        ),
                                      ),
                                      hint: Text(
                                        AppLocalizations.of(context)!.translate(
                                              "selectPropertyText",
                                            ) ??
                                            '',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    if (selectedPropertyType ==
                                        'Other (describe)') ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Other (describe)',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AppTextField(
                                        controller: otherPropertyTypeController,
                                        hintText:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("describeText") ??
                                            '',
                                        textInputType: TextInputType.text,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("fairRentalText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IncrementDecrementFieldInt(
                                      labelText: fairRentalDays.toString(),
                                      initialValue: fairRentalDays,
                                      onChanged: (value) {
                                        setState(() {
                                          fairRentalDays = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("personalUseDaysText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IncrementDecrementFieldInt(
                                      labelText: personalUseDays.toString(),
                                      initialValue: personalUseDays,
                                      onChanged: (value) {
                                        setState(() {
                                          personalUseDays = value;
                                        });
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  AppButton(
                                    isLoading: rentalProvider.otherLoading,
                                    btnText:
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("saveText") ??
                                        '',
                                    onPressed: () {
                                      // ===================== VALIDATION =====================
                                      if (authProvider.user?.regCountry ==
                                          'ca') {
                                        if (addressController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your address",
                                          );
                                          return;
                                        }
                                        if (streetController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your street or P.O. Box",
                                          );
                                          return;
                                        }
                                        if (cityController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your city",
                                          );
                                          return;
                                        }
                                        if (provinceController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your province",
                                          );
                                          return;
                                        }
                                        if (postalCodeController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your postal code",
                                          );
                                          return;
                                        }
                                        // if (suitController.text.trim().isEmpty) {
                                        //   Utils.toastMessage("Please enter your apartment or suite");
                                        //   return;
                                        // }
                                        // if (yourPercentage <= 0) {
                                        //   Utils.toastMessage("Your % Percentage should be more than 0");
                                        //   return;
                                        // }
                                        if (personalUsePercentage < 0) {
                                          Utils.toastMessage(
                                            "Personal Use % cannot be negative",
                                          );
                                          return;
                                        }
                                        if (numberOfUnits <= 0) {
                                          Utils.toastMessage(
                                            "Number of Units should be at least 1",
                                          );
                                          return;
                                        }
                                      } else {
                                        if (addressController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your address",
                                          );
                                          return;
                                        }
                                        if (streetController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your street or P.O. Box",
                                          );
                                          return;
                                        }
                                        if (cityController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your city",
                                          );
                                          return;
                                        }
                                        if (provinceController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your state/province",
                                          );
                                          return;
                                        }
                                        if (postalCodeController.text
                                            .trim()
                                            .isEmpty) {
                                          Utils.toastMessage(
                                            "Please enter your postal code",
                                          );
                                          return;
                                        }
                                        if (selectedPropertyType == null ||
                                            selectedPropertyType!.isEmpty) {
                                          Utils.toastMessage(
                                            "Please select property type",
                                          );
                                          return;
                                        }
                                        if (selectedPropertyType ==
                                                'Other (describe)' &&
                                            otherPropertyTypeController.text
                                                .trim()
                                                .isEmpty) {
                                          Utils.toastMessage(
                                            "Please describe the property type",
                                          );
                                          return;
                                        }
                                        if (fairRentalDays < 1) {
                                          Utils.toastMessage(
                                            "Fair Rental Days should be at least 1",
                                          );
                                          return;
                                        }
                                        if (personalUseDays < 0) {
                                          Utils.toastMessage(
                                            "Personal Use Days cannot be negative",
                                          );
                                          return;
                                        }
                                      }
                                      FocusScope.of(context).unfocus();
                                      // ===================== PREPARE DATA =====================
                                      Map<String, dynamic> fields;
                                      if (authProvider.user?.regCountry ==
                                          'ca') {
                                        fields = {
                                          'address':
                                              addressController.text.trim(),
                                          'street_po_box':
                                              streetController.text.trim(),
                                          'city': cityController.text.trim(),
                                          'province':
                                              provinceController.text.trim(),
                                          'postal_code':
                                              postalCodeController.text.trim(),
                                          'appartment_or_suit':
                                              suitController.text.trim(),
                                          'your_percentage': yourPercentage,
                                          'personal_use_percentage':
                                              personalUsePercentage,
                                          'number_of_units': numberOfUnits,
                                          'client_plans_id': widget.planId,
                                        };
                                      } else {
                                        fields = {
                                          'address':
                                              addressController.text.trim(),
                                          'street_po_box':
                                              streetController.text.trim(),
                                          'city': cityController.text.trim(),
                                          'province':
                                              provinceController.text.trim(),
                                          'postal_code':
                                              postalCodeController.text.trim(),
                                          'type_of_property':
                                              selectedPropertyType,
                                          'fair_rental_days': fairRentalDays,
                                          'personal_use_days': personalUseDays,
                                          'client_plans_id': widget.planId,
                                          'other_describe':
                                              otherPropertyTypeController.text
                                                  .trim(),
                                        };
                                      }

                                      // ===================== CALL API =====================
                                      rentalProvider
                                          .createOrUpdateAccountSettingApi(
                                            context,
                                            fields,
                                          );
                                    },
                                  ),
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
}
