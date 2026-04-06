import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class TotalValuesWidget extends StatelessWidget {
  final double value;

  const TotalValuesWidget({super.key, required this.value});

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
            'CA\$',
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
