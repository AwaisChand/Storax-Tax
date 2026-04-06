import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_button.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/rental_property_view_model/rental_property_view_model.dart';
import '../../../../../../res/components/app_localization.dart';

class PropertyOwnerScreen extends StatefulWidget {
  const PropertyOwnerScreen({super.key, required this.planId});
  final int planId;

  @override
  State<PropertyOwnerScreen> createState() => _PropertyOwnerScreenState();
}

class _PropertyOwnerScreenState extends State<PropertyOwnerScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final suitController = TextEditingController();

  bool _hasAppliedResponse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalPropertyViewModel>().propertyOwnerApi(
        context: context,
        planId: widget.planId,
      );
    });
  }

  void _applyApiData(dynamic apiData) {
    firstNameController.text = apiData.firstName ?? '';
    lastNameController.text = apiData.lastName ?? '';
    addressController.text = apiData.address ?? '';
    streetController.text = apiData.streetPoBox ?? '';
    cityController.text = apiData.city ?? '';
    provinceController.text = apiData.province ?? '';
    postalCodeController.text = apiData.postalCode ?? '';
    suitController.text = apiData.appartmentOrSuit ?? '';
  }

  void _clearFormState() {
    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    streetController.clear();
    cityController.clear();
    provinceController.clear();
    postalCodeController.clear();
    suitController.clear();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    suitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();

    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProvider, _) {
        final model = rentalProvider.propertyOwnerModel(widget.planId);
        final apiData = model?.data;

        if (!_hasAppliedResponse && model != null && apiData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _applyApiData(apiData);
            _hasAppliedResponse = true;
          });
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.backgroundImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (rentalProvider.isLoading)
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.blackColor,
                  ),
                )
              else
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                        color: AppColors.goldenOrangeColor,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                Icons.arrow_back_ios_new_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("propertyOwnerText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child:
                            rentalProvider.isLoading
                                ? SizedBox(
                                  height: Utils.setHeight(context) * 0.7,
                                  child: const Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                      ),
                                    ),
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.goldenOrangeColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                "propertyOwnerDetails",
                                              ) ??
                                              '',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // First Name
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("firstNameText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: firstNameController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("firstNameText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // Last Name
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("lastNameText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: lastNameController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("lastNameText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // Address
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("addressNumText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: addressController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("addressNumText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // Street
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("streetText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: streetController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("streetText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // City
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("cityText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: cityController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("cityText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // Province / State
                                    Text(
                                      authProvider.user?.regCountry == 'ca'
                                          ? AppLocalizations.of(
                                                context,
                                              )!.translate("provinceText") ??
                                              ''
                                          : AppLocalizations.of(
                                                context,
                                              )!.translate("stateText") ??
                                              '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: provinceController,
                                      hintText:
                                          authProvider.user?.regCountry == 'ca'
                                              ? AppLocalizations.of(
                                                    context,
                                                  )!.translate(
                                                    "provinceText",
                                                  ) ??
                                                  ''
                                              : AppLocalizations.of(
                                                    context,
                                                  )!.translate("stateText") ??
                                                  '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("postalCodeText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: postalCodeController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("postalCodeText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 12),

                                    // Apartment / Suite
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("AptText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: suitController,
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("AptText") ??
                                          '',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 20),

                                    // Save Button
                                    AppButton(
                                      isLoading: rentalProvider.isSaving,
                                      btnText:
                                          AppLocalizations.of(
                                            context,
                                          )!.translate("saveText") ??
                                          '',
                                      onPressed: () {
                                        final hasData =
                                            _hasAppliedResponse &&
                                            model != null &&
                                            apiData != null;

                                        if (!hasData) {
                                          // Validate only if no existing data
                                          if (firstNameController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your first name",
                                            );
                                            return;
                                          } else if (lastNameController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your last name",
                                            );
                                            return;
                                          } else if (addressController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your address",
                                            );
                                            return;
                                          } else if (streetController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your street address",
                                            );
                                            return;
                                          } else if (cityController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your city",
                                            );
                                            return;
                                          } else if (provinceController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your province",
                                            );
                                            return;
                                          } else if (postalCodeController
                                              .text
                                              .isEmpty) {
                                            Utils.toastMessage(
                                              "Please enter your postal code",
                                            );
                                            return;
                                          }
                                        }

                                        Map fields = {
                                          'first_name':
                                              firstNameController.text,
                                          'last_name': lastNameController.text,
                                          'address': addressController.text,
                                          'street_po_box':
                                              streetController.text,
                                          'city': cityController.text,
                                          'province': provinceController.text,
                                          'postal_code':
                                              postalCodeController.text,
                                          'appartment_or_suit':
                                              suitController.text,
                                          'client_plans_id': widget.planId,
                                        };
                                        FocusScope.of(context).unfocus();
                                        rentalProvider
                                            .createOrUpdatePropertyOwnerApi(
                                              context,
                                              fields,
                                            )
                                            .then((_) {
                                              context
                                                  .read<
                                                    RentalPropertyViewModel
                                                  >()
                                                  .propertyOwnerApi(
                                                    context: context,
                                                    planId: widget.planId,
                                                  );
                                            });
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
