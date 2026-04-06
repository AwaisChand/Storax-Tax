import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import 'package:storatax/view_models/team_member_view_model/team_member_view_model.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';

class CreateTeamMemberScreen extends StatefulWidget {
  const CreateTeamMemberScreen({super.key});

  @override
  State<CreateTeamMemberScreen> createState() => _CreateTeamMemberScreenState();
}

class _CreateTeamMemberScreenState extends State<CreateTeamMemberScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ✅ Manage multiple team selections
  bool isGasolineChecked = false;
  bool isBusinessTaxManagerChecked = false;

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManagerAvailable = planNames.any(
      (n) => n.toLowerCase().contains('business tax manager'),
    );

    final isGasolineAvailable = planNames.any(
      (n) =>
          n.toLowerCase().contains('gas receipts manager - business version'),
    );
    return Consumer<TeamMemberViewModel>(
      builder: (context, team, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("addNewTeamMemberText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("fillDescText") ?? '',
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
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: firstNameController,
                      hintText:
                          AppLocalizations.of(
                            context,
                          )!.translate("firstNameText") ??
                          '',
                      textInputType: TextInputType.name,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: lastNameController,
                      hintText:
                          AppLocalizations.of(
                            context,
                          )!.translate("lastNameText") ??
                          '',
                      textInputType: TextInputType.name,
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
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: passwordController,
                      hintText:
                          AppLocalizations.of(
                            context,
                          )!.translate("passwordText") ??
                          '',
                      textInputType: TextInputType.visiblePassword,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: confirmPasswordController,
                      hintText:
                          AppLocalizations.of(
                            context,
                          )!.translate("confirmPasswordText") ??
                          '',
                      textInputType: TextInputType.visiblePassword,
                      isPassword: true,
                    ),
                    const SizedBox(height: 25),

                    // 🟡 Team For section
                    Text(
                      AppLocalizations.of(context)!.translate("teamForText") ??
                          '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Business Tax Manager (conditionally rendered)
                    if (isBusinessTaxManagerAvailable)
                      Row(
                        children: [
                          Checkbox(
                            value: isBusinessTaxManagerChecked,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                isBusinessTaxManagerChecked = value ?? false;
                              });
                            },
                          ),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("businessTaxManagerText") ??
                                '',
                          ),
                        ],
                      ),

                    // Gasoline Enterprise (conditionally rendered)
                    if (isGasolineAvailable)
                      Row(
                        children: [
                          Checkbox(
                            value: isGasolineChecked,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                isGasolineChecked = value ?? false;
                              });
                            },
                          ),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("gasolineEnterpriseText") ??
                                '',
                          ),
                        ],
                      ),

                    const SizedBox(height: 30),

                    AppButton(
                      btnText:
                          AppLocalizations.of(context)!.translate("saveText") ??
                          '',
                      isLoading: team.isLoading,
                      onPressed: () {
                        // ✅ Validation
                        if (firstNameController.text.isEmpty) {
                          Utils.toastMessage("Please enter your first name");
                        } else if (lastNameController.text.isEmpty) {
                          Utils.toastMessage("Please enter your last name");
                        } else if (emailController.text.isEmpty) {
                          Utils.toastMessage("Please enter your email");
                        } else if (passwordController.text.isEmpty) {
                          Utils.toastMessage("Please enter your password");
                        } else if (passwordController.text.length < 8) {
                          Utils.toastMessage(
                            "Password must be at least 8 characters long",
                          );
                        } else if (passwordController.text !=
                            confirmPasswordController.text) {
                          Utils.toastMessage("Passwords do not match");
                        } else {
                          // ✅ Collect selected teams in a list
                          List<String> selectedTeams = [];
                          if (isBusinessTaxManagerChecked) {
                            selectedTeams.add("Business Tax Manager");
                          }
                          if (isGasolineChecked) {
                            selectedTeams.add("Gasoline Enterprise");
                          }

                          if (selectedTeams.isEmpty) {
                            Utils.toastMessage(
                              "Please select at least one team",
                            );
                            return;
                          }

                          Map<String, dynamic> data = {
                            "first_name": firstNameController.text,
                            "last_name": lastNameController.text,
                            "email": emailController.text,
                            "password": passwordController.text,
                            "password_confirmation":
                                confirmPasswordController.text,
                            "team_for": selectedTeams, // ✅ Send as List<String>
                          };

                          team.createTeamMemberApi(context, data);
                        }
                      },
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
