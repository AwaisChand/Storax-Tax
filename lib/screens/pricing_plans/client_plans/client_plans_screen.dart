import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/auth_screens/client_plan_register/client_plan_register.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';

class ClientPlansScreen extends StatefulWidget {
  const ClientPlansScreen({super.key, this.planId});
  final int? planId;

  @override
  State<ClientPlansScreen> createState() => _ClientPlansScreenState();
}

class _ClientPlansScreenState extends State<ClientPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PricingPlansViewModel>();
      provider.getClientPlansApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Consumer<PricingPlansViewModel>(
      builder: (context, clientPlan, _) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(
              top: Utils.setHeight(context) * 0.08,
              right: 20,
              left: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(
                                context,
                              )!.translate("pricingPlanText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child:
                      clientPlan.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            itemCount: clientPlan.clientPlans.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final clientPlanDetail =
                                  clientPlan.clientPlans[index];

                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    right: 20,
                                    left: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppColors.mediumGrayColor,
                                      width: 0.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /// Plan Name
                                      Text(
                                        locale == 'fr'
                                            ? (clientPlanDetail.nameFr ??
                                                clientPlanDetail.name ??
                                                '')
                                            : (clientPlanDetail.name ?? ''),
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      /// Price
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '\$${clientPlanDetail.price}',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '/ ${AppLocalizations.of(context)!.translate("yearText1") ?? ''}',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        locale == 'fr'
                                            ? clientPlanDetail.taglineFr ?? ''
                                            : clientPlanDetail.tagline ?? '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.mediumGrayColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),

                                      /// Feature List
                                      ...clientPlanDetail.features?.map((
                                            feature,
                                          ) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: _featureRowWidget(
                                                locale == 'fr'
                                                    ? (feature.translatedName ??
                                                        feature.name ??
                                                        '')
                                                    : (feature.name ?? ''),
                                                feature.included ?? false,
                                              ),
                                            );
                                          }).toList() ??
                                          [],

                                      SizedBox(height: 20),

                                      /// Get Started Button
                                      AppButton(
                                        btnText:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("getStartedText") ??
                                            '',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ClientPlanRegister(
                                                        planId:
                                                            clientPlanDetail.id,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),

                                      SizedBox(height: 10),

                                      /// Taxes Note
                                      Center(
                                        child: Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("taxCalculated") ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featureRowWidget(String text, bool isIncluded) {
    return Row(
      children: [
        Image(
          image: AssetImage(
            isIncluded ? AppAssets.tickIcon : AppAssets.crossIcon,
          ),
          fit: BoxFit.cover,
          height: 15,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
