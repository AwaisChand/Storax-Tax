import 'dart:io';

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

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  File? pickedImage;
  String? selectedIndex;

  final List<String> forCanada = [
    'Alberta',
    'British Columbia',
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Northwest Territories',
    'Nova Scotia',
    'Nunavut',
    'Ontario',
    'Quebec',
    'Prince Edward Island',
    'Saskatchewan',
    'Yukon',
  ];

  final List<String> forOtherCountry = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'District Of Columbia',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AuthViewModel>();

      // ⭐ API returns string message
      final msg = await provider.getUserProfileApi(context);

      if (msg != null) {
        Utils.toastMessage(msg); // ⭐ Show toast HERE
      }

      final profile = provider.data;
      if (profile != null) {
        setState(() {
          firstNameController.text = profile.firstName;
          lastNameController.text = profile.lastName;
          emailController.text = profile.email;
          selectedIndex = profile.province;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, userProfile, _) {
        final List<String> provinceList =
            userProfile.user?.regCountry == "ca" ? forCanada : forOtherCountry;
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
                                                  "userProfileText",
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
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              Utils.setHeight(context) * 0.08,
                                          backgroundColor: Colors.grey.shade200,
                                          child: ClipOval(
                                            child: _buildProfileImage(
                                              userProfile,
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () async {
                                              final image =
                                                  await userProfile
                                                      .pickImageFromGallery();
                                              if (image != null) {
                                                setState(() {
                                                  pickedImage =
                                                      image; // local picked image
                                                });
                                              }
                                            },
                                            child: const CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "${userProfile.data?.firstName ?? ''} ${userProfile.data?.lastName ?? ''}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 23,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(
                                              context,
                                            )!.translate("descProfileText") ??
                                            '',
                                        textAlign: TextAlign.center,
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
                                AppTextField(
                                  controller: firstNameController,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("firstNameText") ??
                                      '',
                                  textInputType: TextInputType.name,
                                ),
                                SizedBox(height: 20),
                                AppTextField(
                                  controller: lastNameController,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("lastNameText") ??
                                      '',
                                  textInputType: TextInputType.name,
                                ),
                                SizedBox(height: 20),
                                AppTextField(
                                  controller: emailController,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("emailText") ??
                                      '',
                                  textInputType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      provinceList.contains(selectedIndex)
                                          ? selectedIndex
                                          : null,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText:
                                        userProfile.user?.regCountry == 'ca'
                                            ? AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "selectProvinceText",
                                                ) ??
                                                ''
                                            : AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "selectStateText",
                                                ) ??
                                                '',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.mediumGrayColor
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  items:
                                      provinceList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedIndex = newValue;
                                    });
                                  },
                                ),
                                SizedBox(height: 8),
                                if (userProfile.user?.regCountry
                                        .toLowerCase() ==
                                    "ca")
                                  Text(
                                    buildTaxText(
                                      hst: userProfile.data?.hst?.toDouble(),
                                      gst: userProfile.data?.gst?.toDouble(),
                                      pst: userProfile.data?.pst?.toDouble(),
                                      isSelected:
                                          selectedIndex != null &&
                                          selectedIndex!.isNotEmpty,
                                    ),
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: AppColors.midNightColor,
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 10),
                                AppButton(
                                  btnText:
                                      AppLocalizations.of(
                                        context,
                                      )!.translate("saveText") ??
                                      '',
                                  isLoading: userProfile.isLoading,
                                  onPressed: () {
                                    Map<String, dynamic> fields = {
                                      'first_name': firstNameController.text,
                                      'last_name': lastNameController.text,
                                      'email': emailController.text,
                                      'province': selectedIndex ?? '',
                                    };

                                    userProfile.updateProfileApi(
                                      context,
                                      fields,
                                      pickedImage,
                                      onInvalidAvatar: () {
                                        setState(() {
                                          pickedImage = null;
                                        });
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: MaterialButton(
                                    height: 50,
                                    color: AppColors.lightPinkColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onPressed: () {
                                      userProfile.deleteApi(context);
                                    },
                                    child:
                                        userProfile.deleteLoading
                                            ? Center(
                                              child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.redColor,
                                                    ),
                                              ),
                                            )
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image(
                                                  image: AssetImage(
                                                    AppAssets.deleteIcon,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  height: 15,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "deleteText",
                                                      ) ??
                                                      '',
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.redColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                                SizedBox(height: 10),
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

  Widget _buildProfileImage(AuthViewModel userProfile) {
    // 1️⃣ Local picked image
    if (pickedImage != null) {
      return Image.file(
        pickedImage!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // 2️⃣ Backend image (handle 403 / error)
    final avatarUrl = userProfile.data?.avatar;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        placeholder:
            (context, url) =>
                Image.asset(AppAssets.profileImg, fit: BoxFit.cover),
        errorWidget:
            (context, url, error) =>
                Image.asset(AppAssets.profileImg, fit: BoxFit.cover),
      );
    }

    // 3️⃣ Default placeholder
    return Image.asset(AppAssets.profileImg, fit: BoxFit.cover);
  }

  String buildTaxText({
    double? gst,
    double? hst,
    double? pst,
    required bool isSelected,
  }) {
    if (!isSelected) {
      return "${AppLocalizations.of(context)!.translate("gst/hstText") ?? ''}: %, ${AppLocalizations.of(context)!.translate("pstText") ?? ''}: %";
    }

    // After selection:
    String pstText = pst != null ? "$pst%" : "N/A";
    String hstText = hst != null ? "$hst%" : "N/A";
    String gstText = gst != null ? "$gst%" : "N/A";

    if (hst != null) {
      return "${AppLocalizations.of(context)!.translate("hstText") ?? ''}: $hstText, ${AppLocalizations.of(context)!.translate("pstText") ?? ''}: $pstText";
    } else if (gst != null) {
      return "${AppLocalizations.of(context)!.translate("gstText") ?? ''}: $gstText, ${AppLocalizations.of(context)!.translate("pstText") ?? ''}: $pstText";
    } else {
      return "${AppLocalizations.of(context)!.translate("gst/hstText") ?? ''}: N/A, ${AppLocalizations.of(context)!.translate("pstText") ?? ''}: $pstText";
    }
  }
}
