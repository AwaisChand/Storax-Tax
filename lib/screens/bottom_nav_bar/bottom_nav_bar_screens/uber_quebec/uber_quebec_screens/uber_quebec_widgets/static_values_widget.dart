import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class StaticValuesWidget extends StatelessWidget {
  final double value;
  final String currencyText;

  const StaticValuesWidget(
      {super.key, required this.value, required this.currencyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blackColor, width: 0.5),
      ),
      child: Row(
        children: [
          Text(
            currencyText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(2),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class StaticKmValues extends StatelessWidget {
  final double value;
  final String text;

  const StaticKmValues({super.key, required this.value, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blackColor, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value.toStringAsFixed(2),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor,
            ),
          ),
        ],
      )
    );
  }
}
