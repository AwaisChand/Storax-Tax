import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, this.email, this.fromLogin});

  final String? email;
  final bool? fromLogin;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final emailController = TextEditingController();
  // 🔥 changed from 4 -> 6
  final otpControllers = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
  }

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
                      const SizedBox(height: 22),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate("verifyOtpText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.blackColor,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          emailController.text,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// 🔥 Now showing 6 fields instead of 4
                      AppTextField(
                        controller: otpControllers,
                        hintText: AppLocalizations.of(
                          context,
                        )!.translate("placeholderOtpText") ??
                            '',
                        textInputType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      AppButton(
                        btnText: AppLocalizations.of(
                          context,
                        )!.translate("verifyOtpText") ??
                            '',
                        isLoading: auth.isLoading,
                        onPressed: () {
                          String otp = otpControllers.text.toString();
                          if (emailController.text.isEmpty) {
                            Utils.toastMessage(
                              AppLocalizations.of(
                                context,
                              )!.translate("alertForOtpText") ??
                                  '',
                            );
                          } else if (otp.isEmpty || otp.length != 6) {
                            Utils.toastMessage(
                                AppLocalizations.of(
                                  context,
                                )!.translate("alertOtpCodeText") ??
                                    '',
                            );
                          } else {
                            Map data = {
                              'email': emailController.text.toString(),
                              'two_factor_code': otp,
                            };
                            auth.verifyOtpApi(
                              context,
                              data,
                              fromLogin: widget.fromLogin ?? false,
                            );
                          }
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            if (emailController.text.isEmpty) {
                              Utils.toastMessage(
                                AppLocalizations.of(
                                  context,
                                )!.translate("alertResendOtpText") ??
                                    '',
                              );
                            } else {
                              Map data = {
                                'email': emailController.text.toString(),
                              };
                              auth.resendOtpApi(context, data);
                            }
                          },
                          child:
                              auth.resendLoading
                                  ? const Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                  : Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate("resendOtpText") ??
                                    '',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
