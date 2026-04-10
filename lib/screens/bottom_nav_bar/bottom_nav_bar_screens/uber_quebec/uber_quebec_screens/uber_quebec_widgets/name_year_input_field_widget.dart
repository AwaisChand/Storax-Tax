import 'package:flutter/material.dart';
import 'package:storatax/utils/utils.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../res/components/app_localization.dart';

class NameYearInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? selectedYear;
  final Function(String?) onYearChanged;
  final List<String> years;

  const NameYearInputField({
    super.key,
    required this.controller,
    required this.selectedYear,
    required this.onYearChanged,
    required this.years,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blackColor, width: 0.5),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)!.translate("enterNameText") ??
                    '',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 15,
                ),
              ),
            ),
          ),

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
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    years.contains(selectedYear) ? selectedYear : years.first,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16.0),
                onChanged: onYearChanged,
                items:
                    years.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
