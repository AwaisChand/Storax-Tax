import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

import '../../res/app_assets.dart';
import '../../res/components/app_drawer.dart';
import '../../res/components/app_localization.dart';
import '../../utils/utils.dart';

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      final result = await context.read<PricingPlansViewModel>().myPlansApi(
        context,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        // Success UI logic
        Utils.toastMessage(result["message"]);
        final plans = result["data"];
      } else {
        // Error UI logic
        Utils.toastMessage(result["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Consumer<PricingPlansViewModel>(
      builder: (context, plans, _) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1: AppLocalizations.of(context)!.translate("myPlansText") ?? '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
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
                child:
                    plans.isLoading
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
                        : Column(
                          children: [
                            Expanded(
                              child:
                                  plans.myPlans.isEmpty
                                      ? Center(
                                        child: Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("noSubscribePlan") ??
                                              '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      )
                                      : ListView.builder(
                                        itemCount: plans.myPlans.length,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final myPlan = plans.myPlans[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 20,
                                              left: 20,
                                              top: 30,
                                            ),
                                            child: Material(
                                              elevation: 4.0,
                                              color: AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(15),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min, // Important: let Column shrink-wrap content
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            locale == "fr" ? myPlan.nameFr ?? "" : myPlan.name ?? "",
                                                            style: GoogleFonts.poppins(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        MaterialButton(
                                                          color: AppColors.goldenOrangeColor,
                                                          height: 45,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          onPressed: () async {
                                                            bool success = await plans.unSubscribePlanApi(
                                                              context,
                                                              myPlan.id!,
                                                            );

                                                            if (success) {
                                                              Utils.toastMessage(
                                                                "Plan unsubscribed successfully!",
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(context)!
                                                                .translate("unSubscribeText") ??
                                                                '',
                                                            style: GoogleFonts.poppins(
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 12,
                                                              color: AppColors.whiteColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "\$${myPlan.price}",
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          );
                                        },
                                      ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: AppButton(
                                btnText:
                                    AppLocalizations.of(
                                      context,
                                    )!.translate("subMorePlanText") ??
                                    '',
                                onPressed: () {
                                  context.pushNamed("morePlans");
                                },
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
