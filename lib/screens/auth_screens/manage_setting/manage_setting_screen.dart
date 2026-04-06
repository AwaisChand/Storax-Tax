import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';

class ManageSettingScreen extends StatefulWidget {
  const ManageSettingScreen({super.key});

  @override
  State<ManageSettingScreen> createState() => _ManageSettingScreenState();
}

class _ManageSettingScreenState extends State<ManageSettingScreen> {
  double _passwordStrength = 0;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AuthViewModel>();
      final msg = await provider.getUserProfileApi(context);

      if (msg != null) {
        Utils.toastMessage(msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, userProfile, _) {
        return Scaffold(
          // resizeToAvoidBottomInset: false,
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
                    top: Utils.setHeight(context) * 0.07,
                    right: 20,
                    left: 20,
                  ),
                  child:
                      userProfile.isLoading
                          ? Center(
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: AppColors.blackColor,
                              ),
                            ),
                          )
                          : SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                                  context,
                                                )!.translate("profileText") ??
                                                '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 23,
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "userPasswordText",
                                                ) ??
                                                '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColors.darkGrayColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Utils.setHeight(context) * 0.05,
                                ),
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: Utils.setHeight(context) * 0.08,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage:
                                          userProfile.data?.avatar != null
                                              ? CachedNetworkImageProvider(
                                                userProfile.data!.avatar,
                                              )
                                              : const AssetImage(
                                                    AppAssets.profileImg,
                                                  )
                                                  as ImageProvider,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "${userProfile.data?.firstName} ${userProfile.data?.lastName}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 23,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.translate(
                                              "updatePasswordText",
                                            ) ??
                                            '',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppColors.darkGrayColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                _label("Current Password"),
                                SizedBox(height: 5),
                                AppTextField(
                                  controller: currentPasswordController,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("currentPasswordText") ??
                                      '',
                                  textInputType: TextInputType.visiblePassword,
                                  isPassword: true,
                                ),
                                SizedBox(height: 13),
                                _label(
                                  "New Password",
                                  icon: Icons.info,
                                  onTapped: () {
                                    Utils.showPasswordInfoDialog(context);
                                  },
                                ),
                                SizedBox(height: 5),
                                AppTextField(
                                  controller: newPasswordController,
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
                                          Utils.calculatePasswordStrength(
                                            value,
                                          );
                                    });
                                  },
                                ),
                                SizedBox(height: 5),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (newPasswordController
                                            .text
                                            .isNotEmpty)
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
                                    if (newPasswordController
                                        .text
                                        .isNotEmpty)
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
                                SizedBox(height: 13),
                                _label("Confirm Password"),
                                SizedBox(height: 5),
                                AppTextField(
                                  controller: confirmPasswordController,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("confirmPasswordText") ??
                                      '',
                                  textInputType: TextInputType.emailAddress,
                                  isPassword: true,
                                ),
                                SizedBox(height: 30),
                                AppButton(
                                  btnText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("saveText") ??
                                      '',
                                  isLoading: userProfile.settings,
                                  onPressed: () {
                                    if (currentPasswordController
                                        .text
                                        .isEmpty) {
                                      Utils.toastMessage(
                                        'Please Enter Current Password',
                                      );
                                    } else if (newPasswordController
                                        .text
                                        .isEmpty) {
                                      Utils.toastMessage(
                                        'Please Enter New password',
                                      );
                                    } else if (newPasswordController
                                            .text
                                            .length <
                                        8) {
                                      Utils.toastMessage(
                                        'Password must be 8 character long',
                                      );
                                    } else if (confirmPasswordController
                                        .text
                                        .isEmpty) {
                                      Utils.toastMessage(
                                        'Please re-enter password',
                                      );
                                    } else if (newPasswordController.text !=
                                        confirmPasswordController.text) {
                                      Utils.toastMessage(
                                        'Password does not match',
                                      );
                                    } else {
                                      Map data = {
                                        'current_password':
                                            currentPasswordController.text,
                                        'new_password':
                                            newPasswordController.text,
                                        'email': confirmPasswordController.text,
                                        'new_password_confirmation':
                                            confirmPasswordController.text
                                                .toString(),
                                      };

                                      userProfile.updateSettingsApi(
                                        context,
                                        data,
                                      );
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
