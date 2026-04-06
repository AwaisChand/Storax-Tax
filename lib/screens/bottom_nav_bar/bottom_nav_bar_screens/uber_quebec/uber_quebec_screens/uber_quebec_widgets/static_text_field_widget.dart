import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class StaticTextField extends StatelessWidget {
  final String text;
  final String? currencyText;

  const StaticTextField({super.key, required this.text, this.currencyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blackColor, width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.blackColor),
      ),
    );
  }
}
