import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/screens/plan_summary_screen/more_plan_summary_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import 'package:storatax/view_models/team_member_view_model/team_member_view_model.dart';

import '../../../models/my_plans_model/my_plans_model.dart';
import '../../../res/components/app_drawer.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_text_style.dart';
import '../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../bottom_nav_bar/bottom_nav_bar.dart';

class GetMorePlansScreen extends StatefulWidget {
  const GetMorePlansScreen({super.key});

  @override
  State<GetMorePlansScreen> createState() => _GetMorePlansScreenState();
}

class _GetMorePlansScreenState extends State<GetMorePlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PricingPlansViewModel>();
      provider.getMorePlansApi(context);
    });
  }

  Future<void> _showCouponDialog(
    BuildContext context,
    int planId,
    PricingPlansViewModel pricingVM,
  ) async {
    debugPrint("🟢 STEP 1: Opening coupon dialog");

    final navigator = Navigator.of(context, rootNavigator: true);

    final couponController = TextEditingController();

    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text("Enter Coupon Code"),
              content: AppTextField(
                controller: couponController,
                hintText: "Enter Coupon Code",
                textInputType: TextInputType.text,
              ),
              actions: [
                // ---------- SKIP ----------
                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            debugPrint("🟡 STEP 2A: Skip pressed");
                            Navigator.pop(dialogContext, {"skip": true});
                          },
                  child: Text(
                    "Skip",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),

                // ---------- APPLY ----------
                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            debugPrint("🟡 STEP 2B: Apply pressed");

                            final code = couponController.text.trim();
                            debugPrint("🔹 Entered coupon: $code");

                            if (code.isEmpty) {
                              debugPrint("🔴 Coupon empty");
                              Utils.toastMessage(
                                "Please enter a coupon or click Skip",
                              );
                              return;
                            }

                            setState(() => isLoading = true);
                            debugPrint("⏳ STEP 3: Calling verifyCouponApi");

                            final apiResult = await pricingVM.verifyCouponApi(
                              code,
                              planId,
                            );

                            debugPrint("🟢 STEP 4: API Result => $apiResult");

                            setState(() => isLoading = false);

                            if (apiResult["success"] == true) {
                              debugPrint("✅ STEP 5: Coupon valid");

                              if (dialogContext.mounted) {
                                debugPrint(
                                  "🟢 STEP 6: Closing dialog with result",
                                );

                                Navigator.pop(dialogContext, {
                                  'id': apiResult["id"],
                                  'code': apiResult["couponCode"],
                                  'discountedPrice':
                                      (apiResult["discounted_price"] as num)
                                          .toDouble(),
                                  'discountAmount':
                                      (apiResult["discount_amount"] as num)
                                          .toDouble(),
                                  'discountValue':
                                      apiResult["discount_value"] as int,
                                });
                              }
                            } else {
                              debugPrint("❌ STEP 5: Coupon invalid");
                              Utils.toastMessage(
                                apiResult["message"] ??
                                    "Coupon verification failed",
                              );
                            }
                          },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (isLoading) SizedBox(width: 8),
                      Text(
                        "Apply",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- CANCEL ----------
                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            debugPrint("🟡 STEP 2C: Cancel pressed");
                            Navigator.pop(dialogContext);
                          },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    debugPrint("🟢 STEP 7: Dialog closed");
    debugPrint("📦 STEP 8: Dialog result => $result");

    if (result == null) {
      debugPrint("🔴 STEP 9: Result is NULL, stopping navigation");
      return;
    }

    debugPrint("🟢 STEP 10: Navigating to MorePlanSummaryScreen");

    if (result["skip"] == true) {
      debugPrint("➡️ STEP 11A: Navigating via SKIP");

      navigator.push(
        MaterialPageRoute(
          builder:
              (_) => MorePlanSummaryScreen(
                planId: planId,
                couponId: null,
                discountedPrice: null,
                discountAmount: null,
                code: null,
                discountedValue: null,
              ),
        ),
      );
    } else {
      debugPrint("➡️ STEP 11B: Navigating via APPLY");
      debugPrint("🧾 Coupon data passed => $result");

      navigator.push(
        MaterialPageRoute(
          builder:
              (_) => MorePlanSummaryScreen(
                planId: planId,
                couponId: result['id'] as int?,
                discountedPrice: result['discountedPrice'] as double?,
                discountAmount: result['discountAmount'] as double?,
                code: result['code'] as String?,
                discountedValue: result['discountValue'] as int?,
              ),
        ),
      );
    }

    debugPrint("🟢 STEP 12: Navigation push executed");
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    late BuildContext safeContext;
    safeContext = context;
    return Consumer<PricingPlansViewModel>(
      builder: (context, morePlans, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("pricingPlanText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("subscribePlanText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          body: Padding(
            padding: EdgeInsets.only(
              top: Utils.setHeight(context) * 0.08,
              right: 20,
              left: 20,
            ),
            child: Column(
              children: [
                Expanded(
                  child:
                      morePlans.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            itemCount: morePlans.morePlans.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final plan = morePlans.morePlans[index];

                              return Card(
                                child: Container(
                                  height: Utils.setHeight(context) * 0.99,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
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
                                    children: [
                                      Text(
                                        locale == 'fr'
                                            ? (plan.nameFr ?? plan.name ?? '')
                                            : (plan.name ?? ''),
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 5),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '\$${plan.price}',
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
                                            ? plan.taglineFr ?? ''
                                            : plan.tagline ?? '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.mediumGrayColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      ...(plan.features ?? []).map((feature) {
                                        final isClientAccess =
                                            feature.name?.toUpperCase() ==
                                            "CLIENTS ACCESS";
                                        final label =
                                            isClientAccess
                                                ? "${feature.name} (${feature.clientsLimit ?? 0})"
                                                : feature.name ?? '';
                                        final featureText =
                                            locale == 'fr'
                                                ? feature.translationName
                                                : feature.name ?? '';

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _featureRowWidget(
                                            featureText ?? '',
                                            feature.included ?? false,
                                          ),
                                        );
                                      }),
                                      Spacer(),
                                      plan.isPurchased == false
                                          ? AppButton(
                                            btnText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "getStartedText",
                                                ) ??
                                                '',
                                            onPressed: () async {
                                              final pricingVM =
                                                  context
                                                      .read<
                                                        PricingPlansViewModel
                                                      >();
                                              final teamVM =
                                                  context
                                                      .read<
                                                        TeamMemberViewModel
                                                      >();
                                              final gasolineVM =
                                                  context
                                                      .read<
                                                        GasolineViewModel
                                                      >();

                                              // Find current Enterprise plan if exists
                                              MyPlans? currentEnterprisePlan;
                                              try {
                                                currentEnterprisePlan = pricingVM
                                                    .myPlans
                                                    .firstWhere(
                                                      (p) => (p.name ?? "")
                                                          .toLowerCase()
                                                          .contains(
                                                            "gas receipts manager - business version",
                                                          ),
                                                    );
                                              } catch (_) {
                                                currentEnterprisePlan = null;
                                              }

                                              final newPlanName =
                                                  (plan.name ?? "")
                                                      .toLowerCase();
                                              final isNewPlanPro = newPlanName
                                                  .contains(
                                                    "unlimited version (pro)",
                                                  );
                                              final isNewPlanFree = newPlanName
                                                  .contains("free version");

                                              bool hasTeamMembers = false;

                                              // Only check team members if downgrading Enterprise → Pro
                                              if (currentEnterprisePlan !=
                                                      null &&
                                                  isNewPlanPro) {
                                                await teamVM
                                                    .getAllTeamMemberApi();
                                                hasTeamMembers =
                                                    teamVM.allData.isNotEmpty;
                                              }

                                              // BLOCK Enterprise → Pro if team members exist
                                              if (currentEnterprisePlan !=
                                                      null &&
                                                  isNewPlanPro &&
                                                  hasTeamMembers) {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "Downgrade Blocked",
                                                        style:
                                                            GoogleFonts.montserrat(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                      content: Text(
                                                        "To downgrade from Gasoline Enterprise to Gasoline Pro, please delete all team members first.",
                                                        style:
                                                            GoogleFonts.montserrat(
                                                              fontSize: 15,
                                                            ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    dialogContext,
                                                                  ).pop(),
                                                          child: const Text(
                                                            "OK",
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return; // Stop execution
                                              }

                                              // HANDLE Free Plan
                                              if (isNewPlanFree) {
                                                _showFreePlanDialog(
                                                  planId: plan.id ?? 0,
                                                  pricingVM: pricingVM,
                                                  teamVM: teamVM,
                                                  gasolineVM: gasolineVM,
                                                  context: context,
                                                );
                                                return;
                                              }

                                              // HANDLE Paid Plan
                                              _showCouponDialog(
                                                context,
                                                plan.id ?? 0,
                                                pricingVM,
                                              );
                                            },
                                          )
                                          : Container(
                                            width: double.infinity,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.redColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                AppLocalizations.of(
                                                      context,
                                                    )!.translate(
                                                      "activatedText",
                                                    ) ??
                                                    '',
                                                style: AppTextStyle
                                                    .k25Bold700TextStyle
                                                    .copyWith(
                                                      color:
                                                          AppColors.whiteColor,
                                                    ),
                                              ),
                                            ),
                                          ),

                                      const SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("taxesText") ??
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
            text,
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

  Future<void> _showFreePlanDialog({
    required BuildContext context,
    required int planId,
    required PricingPlansViewModel pricingVM,
    required TeamMemberViewModel teamVM,
    required GasolineViewModel gasolineVM,
  }) async {
    final router = GoRouter.of(context);

    if (!context.mounted) return;

    // 🔹 CHECK IF USER HAS ANY GASOLINE PLAN
    final hasGasolinePlan = pricingVM.myPlans.any((p) {
      final name = (p.name ?? "").toLowerCase();
      return name.contains("gas receipts manager");
    });

    // 🔹 SHOW CONFIRM DIALOG ONLY IF DOWNGRADING
    if (hasGasolinePlan) {
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(
                "Confirm Downgrade",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "You are moving from a higher plan to the ",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    TextSpan(
                      text: "Free Version",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ".\n\n"),
                    TextSpan(
                      text: "⚠️ You will lose access to:\n",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: "• Reports\n",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    TextSpan(
                      text: "• Forward Files Feature\n",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    const TextSpan(text: ".\n\n"),
                    TextSpan(
                      text: "Do you want to continue?",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text("Proceed"),
                ),
              ],
            ),
      );

      if (proceed != true || !context.mounted) return;
    }

    // 🔹 CHECK ENTERPRISE PLAN ONLY IF GASOLINE PLAN EXISTS
    if (hasGasolinePlan) {
      final hasEnterprisePlan = pricingVM.myPlans.any((p) {
        final name = (p.name ?? "").toLowerCase();
        return name.contains("enterprise") ||
            name.contains("gas receipts manager - business version");
      });

      if (hasEnterprisePlan) {
        // 1️⃣ TEAM MEMBER CHECK
        try {
          await teamVM.getAllTeamMemberApi();
        } catch (_) {}

        if (teamVM.allData.isNotEmpty) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (_) => AlertDialog(
                  title: Text(
                    "Downgrade Blocked",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  content: Text(
                    "To downgrade from Gasoline Enterprise to Gasoline Free,\n"
                    "please delete all team members first.",
                    style: GoogleFonts.montserrat(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
          return;
        }

        // 2️⃣ FILE LIMIT CHECK
        final now = DateTime.now();
        final filesThisMonth =
            gasolineVM.gasolineList.where((e) {
              if (e.date == null) return false;
              final parsed = DateTime.tryParse(e.date!);
              return parsed != null &&
                  parsed.month == now.month &&
                  parsed.year == now.year;
            }).length;

        if (filesThisMonth > 10) {
          Utils.toastMessage(
            "To downgrade from Enterprise to Free, please reduce files to 10 or less.",
          );
          return;
        }
      }
    }

    // 🔹 FETCH GASOLINE DATA IN BACKGROUND
    unawaited(gasolineVM.getGasolineApi(context));

    // ✅ ACTIVATE FREE PLAN
    final success = await pricingVM.freePlanSubscribeApi({"plan_id": planId});
    if (!success) return;

    await pricingVM.myPlansApi(context);

    router.goNamed("bottomNavBar");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newContext = router.routerDelegate.navigatorKey.currentContext;
      BottomNavBar.of(newContext!)?.switchTab(0);
    });

    Utils.toastMessage("Free plan activated successfully 🎉");
  }
}
