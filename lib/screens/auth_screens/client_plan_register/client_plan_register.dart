import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/auth_screens/login_screen/login_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../res/components/app_text_field.dart';
import '../../plan_summary_screen/plan_summary_screen.dart';

class ClientPlanRegister extends StatefulWidget {
  const ClientPlanRegister({super.key, this.planId});
  final int? planId;

  @override
  State<ClientPlanRegister> createState() => _ClientPlanRegisterState();
}

class _ClientPlanRegisterState extends State<ClientPlanRegister> {
  double _passwordStrength = 0;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isAgreed = false;

  String _resolveCountryCode() {
    final countryCode =
        PlatformDispatcher.instance.locale.countryCode?.toLowerCase();
    if (countryCode == 'ca') {
      return 'ca';
    } else if (countryCode == 'us') {
      return 'us';
    } else {
      return 'us';
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Selected Plan ID: ${widget.planId}');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.registerBackgroundImg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
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
                        decoration: BoxDecoration(
                          color: AppColors.goldenOrangeColor,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_outlined,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("registerText") ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("regDescText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Utils.setHeight(context) * 0.04),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("First Name / Business Name"),
                            SizedBox(height: 5),
                            AppTextField(
                              controller: firstNameController,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("firstBusinessNameText") ??
                                  '',
                              textInputType: TextInputType.name,
                            ),
                            SizedBox(height: 12),
                            _label("Last Name(Optional)"),
                            SizedBox(height: 5),
                            AppTextField(
                              controller: lastNameController,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("lastBusinessNameText") ??
                                  '',
                              textInputType: TextInputType.name,
                            ),

                            SizedBox(height: 12),
                            _label("Email"),
                            SizedBox(height: 5),
                            AppTextField(
                              controller: emailController,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("emailText") ??
                                  '',
                              textInputType: TextInputType.name,
                            ),
                            SizedBox(height: 12),
                            _label(
                              "Password",
                              icon: Icons.info,
                              onTapped: () {
                                Utils.showPasswordInfoDialog(context);
                              },
                            ),
                            SizedBox(height: 5),
                            AppTextField(
                              controller: passwordController,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("newPasswordText") ??
                                  '',
                              textInputType: TextInputType.visiblePassword,
                              isPassword: true,
                              onChanged: (value) {
                                setState(() {
                                  _passwordStrength =
                                      Utils.calculatePasswordStrength(value);
                                });
                              },
                            ),
                            SizedBox(height: 5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (passwordController.text.isNotEmpty)
                                      Text(
                                        "Password strength: ${Utils.getStrengthText(_passwordStrength)}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Utils.getStrengthColor(
                                            _passwordStrength,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      "Minimum 8 Characters",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                if (passwordController.text.isNotEmpty)
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color:
                                          Colors.grey[200], // background gray
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            width:
                                                constraints.maxWidth *
                                                _passwordStrength, // fraction of parent
                                            decoration: BoxDecoration(
                                              color: Utils.getStrengthColor(
                                                _passwordStrength,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(width: 10),
                              ],
                            ),
                            SizedBox(height: 15),
                            _label("Confirm Password"),
                            SizedBox(height: 5),
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
                            Row(
                              children: [
                                Checkbox(
                                  value: isAgreed,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgreed = value!;
                                    });
                                  },
                                  activeColor: AppColors.goldenOrangeColor,
                                ),
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("agreeTermsAndPrivacy") ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: AppColors.darkMidnightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            AppButton(
                              btnText:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("registerText") ??
                                  '',
                              isLoading: auth.isLoading,
                              onPressed: () {
                                if (firstNameController.text.isEmpty) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("validationRegText1") ??
                                        '',
                                  );
                                } else if (emailController.text.isEmpty) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("validationRegText2") ??
                                        '',
                                  );
                                } else if (passwordController.text.isEmpty) {
                                  Utils.toastMessage("Please enter password");
                                } else if (passwordController.text.length < 8) {
                                  Utils.toastMessage(
                                    'Password must be 8 character long',
                                  );
                                } else if (confirmPasswordController
                                    .text
                                    .isEmpty) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("validationRegText4") ??
                                        '',
                                  );
                                } else if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(context)!.translate(
                                          "alertPasswordNotMatchText",
                                        ) ??
                                        '',
                                  );
                                } else if (isAgreed == false) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("validationRegText5") ??
                                        '',
                                  );
                                } else {
                                  Map data = {
                                    'plan_id': widget.planId.toString(),
                                    'first_name':
                                        firstNameController.text.toString(),
                                    'last_name':
                                        lastNameController.text.toString(),
                                    'email': emailController.text.toString(),
                                    'password':
                                        passwordController.text.toString(),
                                    'password_confirmation':
                                        confirmPasswordController.text
                                            .toString(),
                                    "country": _resolveCountryCode(),
                                  };
                                  auth.clientPlanRegApi(context, data, (
                                    userId,
                                  ) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PlanSummaryScreen(
                                              planId: widget.planId ?? 0,
                                              userId: userId,
                                            ),
                                      ),
                                    );
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 15),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("alreadyAcc") ??
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
                                        )!.translate("loginHereText") ??
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
                                                    (context) => LoginScreen(),
                                              ),
                                            );
                                          },
                                  ),
                                  TextSpan(
                                    text:
                                        AppLocalizations.of(
                                          context,
                                        )!.translate("accessDashboardText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _label(String text, {IconData? icon, VoidCallback? onTapped}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 4),
          InkWell(onTap: onTapped, child: Icon(icon, size: 15)),
        ],
      ],
    );
  }
}
