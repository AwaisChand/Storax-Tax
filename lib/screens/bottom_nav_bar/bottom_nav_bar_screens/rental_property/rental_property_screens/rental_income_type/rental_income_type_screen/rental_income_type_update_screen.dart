import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_button.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/utils.dart';
import '../../rental_property_tab_screen/rental_property_tab_screen.dart';
import '../widget/increment_decrement_field_widget.dart';

class RentalIncomeTypeUpdateScreen extends StatefulWidget {
  const RentalIncomeTypeUpdateScreen({
    super.key,
    this.planId,
    this.information,
  });
  final int? planId;
  final IncomeTypesData? information;

  @override
  State<RentalIncomeTypeUpdateScreen> createState() =>
      _RentalIncomeTypeUpdateScreenState();
}

class _RentalIncomeTypeUpdateScreenState
    extends State<RentalIncomeTypeUpdateScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<TextEditingController> firstNameControllers = [];
  List<TextEditingController> lastNameControllers = [];

  int numberOfUnits = 1;

  @override
  void initState() {
    super.initState();

    // Prefill name
    if (widget.information?.name != null) {
      nameController.text = widget.information!.name!;
    }

    // Existing info list
    final existingInfoList = widget.information?.information ?? [];

    // Determine how many entries there are
    numberOfUnits = existingInfoList.isNotEmpty ? existingInfoList.length : 1;

    _initializeTenantFields(numberOfUnits);

    for (int i = 0; i < existingInfoList.length; i++) {
      final entry = existingInfoList[i];
      firstNameControllers[i].text = entry.firstName ?? '';
      lastNameControllers[i].text = entry.lastName ?? '';

      if (entry.isPrimary == 1) {
        emailController.text = entry.email ?? '';
      }
    }
  }

  void _initializeTenantFields(int count) {
    firstNameControllers = List.generate(count, (_) => TextEditingController());
    lastNameControllers = List.generate(count, (_) => TextEditingController());
  }

  void _updateTenantFields(int newCount) {
    setState(() {
      final oldCount = firstNameControllers.length;

      if (newCount > oldCount) {
        firstNameControllers.addAll(
          List.generate(newCount - oldCount, (_) => TextEditingController()),
        );
        lastNameControllers.addAll(
          List.generate(newCount - oldCount, (_) => TextEditingController()),
        );
      }
      // Do not remove controllers when shrinking to preserve previous input
      numberOfUnits = newCount;
    });
  }

  bool _isEntryEmpty(int i) {
    final first = firstNameControllers[i].text.trim();
    final last = lastNameControllers[i].text.trim();
    return first.isEmpty && last.isEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    for (var c in firstNameControllers) {
      c.dispose();
    }
    for (var c in lastNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProperty, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:AppLocalizations.of(context)!.translate("rIncomeText") ??
                '',
            text2: AppLocalizations.of(
              context,
            )!.translate("manageIncomeText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalPropertyTabScreen(),
                ),
              );            },
          ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("manageIncomeText") ??
                                '',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("incomeDText") ??
                                '',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          AppTextField(
                            controller: nameController,
                            hintText: "Name",
                            textInputType: TextInputType.name,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("tenText") ??
                                '',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          IncrementDecrementFieldWidget(
                            labelText: "Total number of tenants and subtenants",
                            initialValue: numberOfUnits,
                            onChanged: (value) {
                              _updateTenantFields(value);
                            },
                          ),
                          const SizedBox(height: 15),
                          AppTextField(
                            controller: emailController,
                            hintText:
                                AppLocalizations.of(
                                  context,
                                )!.translate("emailText") ??
                                '',
                            textInputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(numberOfUnits, (index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                  controller: firstNameControllers[index],
                                  hintText:
                                      "${AppLocalizations.of(context)!.translate("firstNameText") ?? ''}(${index + 1})",
                                  textInputType: TextInputType.name,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  controller: lastNameControllers[index],
                                  hintText:
                                      "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}(${index + 1})",
                                  textInputType: TextInputType.name,
                                ),
                                const SizedBox(height: 15),
                              ],
                            );
                          }),
                          const SizedBox(height: 20),
                          AppButton(
                            btnText: AppLocalizations.of(context)!.translate("saveText") ?? '',
                            isLoading: rentalProperty.otherLoading,
                            onPressed: () {
                              // Validate name
                              if (nameController.text.trim().isEmpty) {
                                Utils.toastMessage("Please enter Name");
                                return;
                              }

                              // Validate first & last names
                              for (int i = 0; i < numberOfUnits; i++) {
                                if (_isEntryEmpty(i)) {
                                  Utils.toastMessage(
                                    "Please enter First and Last Name for entry ${i + 1}",
                                  );
                                  return;
                                }
                              }

                              // Build "information" payload
                              final Map<String, dynamic> infoMap = {};
                              for (int i = 0; i < numberOfUnits; i++) {
                                if (_isEntryEmpty(i)) continue;

                                final entry = <String, dynamic>{
                                  'first_name':
                                      firstNameControllers[i].text.trim(),
                                  'last_name':
                                      lastNameControllers[i].text.trim(),
                                };

                                // Primary: first entry considered primary
                                if (i == 0 &&
                                    emailController.text.trim().isNotEmpty) {
                                  entry['email'] = emailController.text.trim();
                                }

                                infoMap[(i + 1).toString()] = entry;
                              }

                              final Map<String, dynamic> fields = {
                                'client_plans_id': widget.planId,
                                'name': nameController.text.trim(),
                                'no_of_information': infoMap.length,
                                'information': infoMap,
                              };

                              final int? incomeTypeId = widget.information?.id;
                              if (incomeTypeId == null) {
                                Utils.toastMessage("Income type ID missing");
                                return;
                              }

                              rentalProperty.updateIncomeTypeApi(
                                context: context,
                                id: incomeTypeId,
                                data: fields,
                              );
                            },
                          ),
                        ],
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
}
