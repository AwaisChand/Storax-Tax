import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import '../../res/helper.dart';
import '../../utils/utils.dart';
import '../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class MorePlanSummaryScreen extends StatefulWidget {
  const MorePlanSummaryScreen({
    super.key,
    required this.planId,
    this.couponId,
    this.discountedPrice,
    this.discountAmount,
    this.code,
    this.discountedValue,
  });

  final int planId;
  final int? couponId;
  final double? discountedPrice;
  final double? discountAmount;
  final String? code;
  final int? discountedValue;

  @override
  State<MorePlanSummaryScreen> createState() => _MorePlanSummaryScreenState();
}

class _MorePlanSummaryScreenState extends State<MorePlanSummaryScreen> {
  bool _isProcessingPayment = false;
  Map<String, dynamic>? paymentIntentData;
  String? customerId;
  String? paymentMethodId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricingPlansViewModel>().getPlanDetailApi(
        context,
        widget.planId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PricingPlansViewModel>(
      builder: (context, planDetail, _) {
        final plan = planDetail.planDetailModel?.plan;
        final originalPrice = plan?.price ?? 0.0;
        final discountedPrice = widget.discountedPrice ?? originalPrice;
        final discountAmount = widget.discountAmount ?? 0.0;
        final couponCode = widget.code;
        final discountedValue = widget.discountedValue;
        final id = widget.couponId;

        debugPrint("📋 PlanID: ${widget.planId}");
        debugPrint("🏷 Coupon Code: $couponCode");
        debugPrint("💲 Discounted Price: $discountedPrice");
        debugPrint("💰 Discount Amount: $discountAmount");
        debugPrint("💰 Discount Value: $discountedValue");
        debugPrint("💰 Coupon Id: $id");

        return Scaffold(
          body:
              planDetail.isLoading
                  ?  Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.blackColor,
                    strokeWidth: 4,
                  ),
                ),
              )
                  : Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: Utils.setHeight(context) * 0.08,
                          right: 20,
                          left: 20,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            bottom: 100,
                          ), // space for button
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Plan Summary",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Try ${plan?.name ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "15 Days Free",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Then \$${originalPrice.toStringAsFixed(2)} per year",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.darkMidnightColor,
                                ),
                              ),
                              SizedBox(height: Utils.setHeight(context) * 0.08),
                              _rowWidget("${plan?.name}", "15 Days Free"),
                              const SizedBox(height: 15),
                              Text(
                                "${plan?.details}",
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  "\$${originalPrice.toStringAsFixed(2)}/ year after",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.mediumGrayColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _dividerWidget(),
                              const SizedBox(height: 15),

                              // Pricing Summary Rows
                              _rowWidget(
                                "Subtotal",
                                "\$${originalPrice.toStringAsFixed(2)}",
                              ),
                              SizedBox(height: 5),
                              if (discountAmount > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightPinkColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.discount,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            couponCode ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (discountedValue != null) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              "(${discountedValue.toString()}%)",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    AppColors.mediumGrayColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "-\$${discountAmount.toStringAsFixed(2)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.mediumGrayColor,
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 15),
                              _rowWidget("Tax", "\$0.00"),
                              const SizedBox(height: 15),
                              _dividerWidget(),
                              const SizedBox(height: 15),

                              _rowWidget(
                                "Total after trial",
                                "\$${discountedPrice.toStringAsFixed(2)}",
                              ),
                              _rowWidget("Total due today", "\$0.00"),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: AppButton(
                          btnText: _isProcessingPayment ? "Processing..." : "Start Trial",
                          isLoading: _isProcessingPayment,
                          onPressed: _isProcessingPayment
                              ? null
                              : () async {
                            setState(() => _isProcessingPayment = true);

                            try {
                              final provider = context.read<PricingPlansViewModel>();
                              final authProvider = context.read<AuthViewModel>();

                              final plan = provider.planDetailModel?.plan;
                              if (plan == null) {
                                Utils.toastMessage("Plan data not loaded");
                                return;
                              }

                              final userId = authProvider.user?.id;
                              if (userId == null) {
                                Utils.toastMessage("User not found");
                                return;
                              }

                              // 🚀 CALL SAVE SUBSCRIPTION FLOW
                              await saveSubscriptionFlow(
                                context,
                                userId,
                                plan.id!,
                                widget.couponId,
                                provider,
                              );

                            } catch (e, s) {
                              debugPrint("❌ BUTTON ERROR: $e\n$s");
                              Utils.toastMessage("Something went wrong");
                            } finally {
                              if (mounted) setState(() => _isProcessingPayment = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _dividerWidget() => const Divider(thickness: 0.3);

  Widget _rowWidget(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          text2,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
