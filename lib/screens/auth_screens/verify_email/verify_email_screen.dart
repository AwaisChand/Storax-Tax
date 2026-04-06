import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../res/components/app_text_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.fromLogin});
  final bool? fromLogin;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
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
                child: Padding(
                  padding: EdgeInsets.only(
                    top: Utils.setHeight(context) * 0.15,
                    right: 20,
                    left: 20,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Image(
                          image: AssetImage(AppAssets.appLogo),
                          fit: BoxFit.fill,
                          height: Utils.setHeight(context) * 0.16,
                        ),
                      ),
                      SizedBox(height: 22),
                      Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("verifyEmailText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      AppTextField(
                        controller: emailController,
                        hintText: "Email",
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 30),
                      Spacer(),
                      AppButton(
                        btnText:
                            AppLocalizations.of(
                              context,
                            )!.translate("verifyEmailText") ??
                            '',
                        isLoading: auth.isLoading,
                        onPressed: () {
                          if (emailController.text.isEmpty) {
                            Utils.toastMessage(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("alertVerifyEmailText") ??
                                  '',
                            );
                          } else {
                            Map data = {
                              'email': emailController.text.toString(),
                            };
                            auth.verifyEmailApi(
                              context,
                              data,
                              fromLogin: widget.fromLogin!,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
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
