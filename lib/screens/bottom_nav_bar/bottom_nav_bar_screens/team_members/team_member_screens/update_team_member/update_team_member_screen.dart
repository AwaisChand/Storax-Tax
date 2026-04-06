import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_all_team_member_model/get_all_team_member_model.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/team_member_view_model/team_member_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class UpdateTeamMemberScreen extends StatefulWidget {
  const UpdateTeamMemberScreen({super.key, required this.data});
  final TeamMemberData data;

  @override
  State<UpdateTeamMemberScreen> createState() => _UpdateTeamMemberScreenState();
}

class _UpdateTeamMemberScreenState extends State<UpdateTeamMemberScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isGasolineChecked = false;
  bool isBusinessTaxManagerChecked = false;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.data.firstName ?? '';
    lastNameController.text = widget.data.lastName ?? '';
    emailController.text = widget.data.email ?? '';

    // Convert teamFor to List<String> safely
    List<String> teams = [];
    final teamData = widget.data.teamFor;

    if (teamData is String) {
      // Try parsing JSON first
      try {
        final parsed =
            teamData.startsWith('[')
                ? List<String>.from(
                  teamData.replaceAll(RegExp(r'[\[\]\"]'), '').split(','),
                )
                : [teamData];
        teams = parsed.map((e) => e.trim()).toList();
      } catch (_) {
        teams = [teamData];
      }
    } else if (teamData is List) {
      teams = teamData!.map((e) => e.toString()).toList();
    }

    // Initialize checkboxes based on existing member's teams
    isBusinessTaxManagerChecked = teams.contains("Business Tax Manager");
    isGasolineChecked = teams.contains("Gasoline Enterprise");
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManagerAvailable = planNames.any(
      (n) => n.contains('business tax manager'),
    );

    final isGasolineAvailable = planNames.any(
      (n) => n.contains('gas receipts manager - business version'),
    );

    return Consumer<TeamMemberViewModel>(
      builder: (context, team, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("updateTeamText") ?? '',
            text2:
                AppLocalizations.of(context)!.translate("updateDescText") ?? '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pop(context);
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
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Utils.setHeight(context) * 0.1,
                  horizontal: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
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
                      SizedBox(height: 15),
                      AppTextField(
                        controller: lastNameController,
                        hintText:
                            AppLocalizations.of(
                              context,
                            )!.translate("lastNameText") ??
                            '',
                        textInputType: TextInputType.name,
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
                      SizedBox(height: 15),
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
                      SizedBox(height: 15),
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
                      const SizedBox(height: 20),
                      // Business Tax Manager
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
                      // Gasoline Enterprise
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
                            AppLocalizations.of(
                              context,
                            )!.translate("updateText") ??
                            '',
                        isLoading: team.isLoading,
                        onPressed: () {
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
                            "team_for": selectedTeams,
                          };

                          team.updateTeamMemberApi(
                            context,
                            widget.data.id!,
                            data,
                          );
                        },
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
}
