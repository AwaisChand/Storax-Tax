import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_button.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/utils.dart';
import '../../rental_property_tab_screen/rental_property_tab_screen.dart';
import '../widget/increment_decrement_field_widget.dart';

class RentalIncomeTypeScreen extends StatefulWidget {
  const RentalIncomeTypeScreen({super.key, this.planId});
  final int? planId;

  @override
  State<RentalIncomeTypeScreen> createState() => _RentalIncomeTypeScreenState();
}

class _RentalIncomeTypeScreenState extends State<RentalIncomeTypeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<TextEditingController> firstNameControllers = [];
  List<TextEditingController> lastNameControllers = [];

  int numberOfUnits = 1;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _initializeTenantFields(1); // start with 1 tenant
  }

  void _initializeTenantFields(int count) {
    firstNameControllers = List.generate(
      count,
      (index) => TextEditingController(),
    );
    lastNameControllers = List.generate(
      count,
      (index) => TextEditingController(),
    );
  }

  void _updateTenantFields(int newCount) {
    setState(() {
      int oldCount = firstNameControllers.length;

      if (newCount > oldCount) {
        // Add new controllers
        firstNameControllers.addAll(
          List.generate(
            newCount - oldCount,
            (index) => TextEditingController(),
          ),
        );
        lastNameControllers.addAll(
          List.generate(
            newCount - oldCount,
            (index) => TextEditingController(),
          ),
        );
      } else if (newCount < oldCount) {
        // Remove excess controllers
        firstNameControllers.removeRange(newCount, oldCount);
        lastNameControllers.removeRange(newCount, oldCount);
      }

      numberOfUnits = newCount;
    });
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
            text1: AppLocalizations.of(context)!.translate("rIncomeText") ?? '',
            text2:
                AppLocalizations.of(context)!.translate("manageIncomeText") ??
                '',
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
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
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
                          SizedBox(height: 15),
                          AppTextField(
                            controller: emailController,
                            hintText:
                                AppLocalizations.of(
                                  context,
                                )!.translate("emailText") ??
                                '',
                            textInputType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 20),

                          ...List.generate(numberOfUnits, (index) {
                            return Column(
                              children: [
                                AppTextField(
                                  controller: firstNameControllers[index],
                                  hintText:
                                      "${AppLocalizations.of(context)!.translate("firstNameText") ?? ''}(${index + 1})",
                                  textInputType: TextInputType.name,
                                ),
                                SizedBox(height: 10),
                                AppTextField(
                                  controller: lastNameControllers[index],
                                  hintText:
                                      "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}(${index + 1})",
                                  textInputType: TextInputType.name,
                                ),
                                SizedBox(height: 15),
                              ],
                            );
                          }),
                          SizedBox(height: 20),
                          AppButton(
                            btnText:
                                AppLocalizations.of(
                                  context,
                                )!.translate("saveText") ??
                                '',
                            isLoading: rentalProperty.otherLoading,
                            onPressed: () {
                              // Validate Name
                              if (nameController.text.trim().isEmpty) {
                                Utils.toastMessage("Please enter Name");
                                return;
                              }

                              if (emailController.text.trim().isEmpty) {
                                Utils.toastMessage("Please enter Email");
                                return;
                              }

                              // Validate all first & last name fields
                              for (int i = 0; i < numberOfUnits; i++) {
                                if (firstNameControllers[i].text
                                    .trim()
                                    .isEmpty) {
                                  Utils.toastMessage(
                                    "Please enter First Name (${i + 1})",
                                  );
                                  return;
                                }
                                if (lastNameControllers[i].text
                                    .trim()
                                    .isEmpty) {
                                  Utils.toastMessage(
                                    "Please enter Last Name (${i + 1})",
                                  );
                                  return;
                                }
                              }

                              final Map<String, dynamic> info = {};
                              for (int i = 0; i < numberOfUnits; i++) {
                                info[(i + 1).toString()] = {
                                  'first_name':
                                      firstNameControllers[i].text.trim(),
                                  'last_name':
                                      lastNameControllers[i].text.trim(),
                                  // Only include email for the first tenant
                                  if (i == 0 &&
                                      emailController.text.trim().isNotEmpty)
                                    'email': emailController.text.trim(),
                                };
                              }

                              final Map<String, dynamic> fields = {
                                'client_plans_id': widget.planId,
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'no_of_information': numberOfUnits,
                                'information': info,
                              };

                              rentalProperty.createIncomeTypesApi(
                                context,
                                fields,
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
