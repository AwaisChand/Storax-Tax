import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class ClientBillingToggle extends StatelessWidget {
  const ClientBillingToggle({super.key, this.onChanged});

  final Function(bool isYearly)? onChanged;

  @override
  Widget build(BuildContext context) {
    final pricingVM = context.watch<PricingPlansViewModel>();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, "Monthly", !pricingVM.isYearly),
          _buildOption(context, "Yearly", pricingVM.isYearly),

          const SizedBox(width: 10),

          if (pricingVM.isYearly)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  "Pay once per year — best value on every plan",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, bool isSelected) {
    final pricingVM = context.read<PricingPlansViewModel>();

    return GestureDetector(
      onTap: () {
        final newValue = title == "Yearly";

        if (pricingVM.isYearly == newValue) return;

        pricingVM.setBilling(newValue);

        onChanged?.call(newValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}