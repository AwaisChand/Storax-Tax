import 'package:flutter/material.dart';
import 'package:storatax/utils/utils.dart';

import '../../../../../../../utils/app_colors.dart';

class StaticNameYearInputField extends StatelessWidget {
  final String name;
  final String selectedYear;

  const StaticNameYearInputField({
    super.key,
    required this.name,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.blackColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
      ),
      child: Row(
        children: <Widget>[
          // Static Name Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 15,
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),

          // Vertical Divider
          Container(
            height: Utils.setHeight(context) * 0.06,
            width: 1.0,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.blackColor.withOpacity(0.2),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),

          // Static Year Display
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              selectedYear,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}