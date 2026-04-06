import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/utils/app_colors.dart';
import '../../res/helper.dart';
import '../../utils/utils.dart';
import '../../view_models/auth_view_model/auth_view_model.dart';
import '../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class PlanSummaryScreen extends StatefulWidget {
  const PlanSummaryScreen({super.key, required this.planId, this.userId});
  final int planId;
  final String? userId;

  @override
  State<PlanSummaryScreen> createState() => _PlanSummaryScreenState();
}

class _PlanSummaryScreenState extends State<PlanSummaryScreen> {
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
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(
              top: Utils.setHeight(context) * 0.08,
              right: 20,
              left: 20,
            ),
            child:
                planDetail.isLoading
                    ? Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: AppColors.blackColor,
                      strokeWidth: 4,
                    ),
                  ),
                )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          "Try ${planDetail.planDetailModel?.plan?.name}",
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
                          "Then \$${planDetail.planDetailModel?.plan?.price} per year",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.darkMidnightColor,
                          ),
                        ),
                        SizedBox(height: Utils.setHeight(context) * 0.08),
                        _rowWidget(
                          "${planDetail.planDetailModel?.plan?.name}",
                          "15 Days Free",
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "${planDetail.planDetailModel?.plan?.details}",
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "\$${planDetail.planDetailModel?.plan?.price}/ year after",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.mediumGrayColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _dividerWidget(),
                        const SizedBox(height: 15),
                        _rowWidget(
                          "Subtotal",
                          "\$${planDetail.planDetailModel?.plan?.price}",
                        ),
                        const SizedBox(height: 15),
                        _rowWidget("Tax", "\$0.00"),
                        const SizedBox(height: 15),
                        _dividerWidget(),
                        const SizedBox(height: 15),
                        _rowWidget(
                          "Total after trial",
                          "\$${planDetail.planDetailModel?.plan?.price}",
                        ),
                        _rowWidget("Total due today", "\$0.00"),
                        const Spacer(),
                        AppButton(
                          btnText: _isProcessingPayment ? "Processing..." : "Start Trial",
                          isLoading: _isProcessingPayment,
                          onPressed: _isProcessingPayment
                              ? null // 🔒 disable button while processing
                              : () async {
                            setState(() => _isProcessingPayment = true);

                            try {
                              final provider = context.read<PricingPlansViewModel>();

                              // ✅ Get current plan
                              final plan = provider.planDetailModel?.plan;
                              if (plan == null) {
                                Utils.toastMessage("Plan data not loaded");
                                return;
                              }


                              // 🚀 Start subscription flow
                              await startSubscriptionFlow(
                                context,
                                widget.userId!,
                                plan.id!,
                                provider,
                              );
                            } catch (e, s) {
                              Utils.toastMessage("Payment failed");
                              debugPrint("❌ Payment error: $e\n$s");
                            } finally {
                              if (mounted) {
                                setState(() => _isProcessingPayment = false);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
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
