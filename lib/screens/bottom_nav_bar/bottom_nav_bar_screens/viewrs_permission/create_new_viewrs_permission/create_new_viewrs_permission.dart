import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/viewrs_view_model/viewrs_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../res/components/app_localization.dart';

class CreateNewViewrPermissionScreen extends StatelessWidget {
  CreateNewViewrPermissionScreen({super.key});

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewrsViewModel>(
      builder: (context, viewrs, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("addViewersText") ?? '',
            text2:
                AppLocalizations.of(context)!.translate("addVDescText") ?? '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              // background
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

              // form content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: Utils.setHeight(context) * 0.05),

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
                      const SizedBox(height: 30),

                      AppButton(
                        btnText:
                            AppLocalizations.of(
                              context,
                            )!.translate("saveText") ??
                            '',
                        isLoading: viewrs.isLoading,
                        onPressed: () {
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
                              "Password must be 8 characters long",
                            );
                          } else if (passwordController.text !=
                              confirmPasswordController.text) {
                            Utils.toastMessage("Password does not match");
                          } else {
                            Map data = {
                              "first_name": firstNameController.text,
                              "last_name": lastNameController.text,
                              'email': emailController.text,
                              "password": passwordController.text,
                              "password_confirmation":
                                  confirmPasswordController.text,
                            };
                            viewrs.createViewrsApi(context, data);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
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
