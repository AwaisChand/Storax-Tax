import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/viewrs_model/get_all_viewrs_model.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/viewrs_view_model/viewrs_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../res/components/app_localization.dart';

class UpdateViewrPermissionScreen extends StatefulWidget {
  UpdateViewrPermissionScreen({super.key, required this.data});
  final Data data;

  @override
  State<UpdateViewrPermissionScreen> createState() =>
      _UpdateViewrPermissionScreenState();
}

class _UpdateViewrPermissionScreenState
    extends State<UpdateViewrPermissionScreen> {
  final firstNameController = TextEditingController();

  final lastNameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    firstNameController.text = widget.data.firstName ?? '';
    lastNameController.text = widget.data.lastName ?? '';
    emailController.text = widget.data.email ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewrsViewModel>(
      builder: (context, viewrs, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("updateViewersText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("updateVDescText") ??
                '',
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
                      SizedBox(height: 30),
                      AppButton(
                        btnText:
                            AppLocalizations.of(
                              context,
                            )!.translate("updateText") ??
                            '',
                        isLoading: viewrs.isLoading,
                        onPressed: () {
                          Map data = {
                            "first_name": firstNameController.text,
                            "last_name": lastNameController.text,
                            "email": emailController.text,
                            "password": passwordController.text,
                            "password_confirmation":
                                confirmPasswordController.text,
                          };
                          viewrs.updateViewrsApi(
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
