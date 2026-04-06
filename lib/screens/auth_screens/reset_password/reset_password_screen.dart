import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../res/components/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email});
  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  double _passwordStrength = 0;

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

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
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image(
                            image: AssetImage(AppAssets.appLogo),
                            fit: BoxFit.fill,
                            height: Utils.setHeight(context) * 0.16,
                          ),
                        ),
                        SizedBox(height: 22),
                        Center(
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("resetPasswordText") ??
                                '',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
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

                        SizedBox(height: 15),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: Colors.grey[200], // background gray
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
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
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
                        SizedBox(height: 30),
                        AppButton(
                          btnText:
                              AppLocalizations.of(
                                context,
                              )!.translate("resetBtnText") ??
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
                                'Password must be 8 character long',
                              );
                            } else if (confirmPasswordController.text.isEmpty) {
                              Utils.toastMessage("Please re-enter password");
                            } else if (passwordController.text !=
                                confirmPasswordController.text) {
                              Utils.toastMessage(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("alertPasswordNotMatchText") ??
                                    '',
                              );
                            } else {
                              Map data = {
                                'email': emailController.text.toString(),
                                'password': passwordController.text.toString(),
                                'password_confirmation':
                                    confirmPasswordController.text.toString(),
                              };
                              auth.resetPasswordApi(context, data);
                            }
                          },
                        ),
                      ],
                    ),
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
