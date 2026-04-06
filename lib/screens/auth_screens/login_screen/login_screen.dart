import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/auth_screens/tax_professional_register/tax_professional_register.dart';
import 'package:storatax/screens/auth_screens/verify_email/verify_email_screen.dart';
import 'package:storatax/screens/pricing_plans/client_plans/client_plans_screen.dart';
import 'package:storatax/screens/pricing_plans/tax_professional_plans/tax_professional_plans_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../res/components/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
                        AppLocalizations.of(context)!.translate("signInText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      AppTextField(
                        controller: emailController,
                        hintText:
                            AppLocalizations.of(
                              context,
                            )!.translate("emailText") ??
                            '',
                        textInputType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 30),
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
                      SizedBox(height: 6),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      VerifyEmailScreen(fromLogin: false),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("forgotPasswordText") ??
                                '',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppColors.goldenOrangeColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      AppButton(
                        btnText:  AppLocalizations.of(context)!.translate("signInText") ??
                            '',
                        isLoading: auth.isLoading,
                        onPressed: () {
                          if (emailController.text.isEmpty) {
                            Utils.toastMessage(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("alertEmailText") ??
                                  '',
                            );
                          } else if (passwordController.text.isEmpty) {
                            Utils.toastMessage(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("alertPasswordText") ??
                                  '',
                            );
                          } else if (passwordController.text.length < 8) {
                            Utils.toastMessage(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("8DigitPassText") ??
                                  '',
                            );
                          } else {
                            Map data = {
                              'email': emailController.text.toString(),
                              'password': passwordController.text.toString(),
                            };
                            auth.loginApi(context, data);
                          }
                        },
                      ),
                      SizedBox(height: 25),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          children: [
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("notAccountText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("taxProfessionalText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.goldenOrangeColor,
                                ),
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder:
                                      //         (context) =>
                                      //             TaxProfessionalScreen(),
                                      //   ),
                                      // );
                                    },
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("orText") ??
                                  '',
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("clientText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.goldenOrangeColor,
                                ),
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ClientPlansScreen(),
                                        ),
                                      );
                                    },
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("descText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("hereText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.goldenOrangeColor,
                                ),
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder:
                                      //         (context) =>
                                      //             TaxProfessionalRegister(),
                                      //   ),
                                      // );
                                    },
                            ),
                          ],
                        ),
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
