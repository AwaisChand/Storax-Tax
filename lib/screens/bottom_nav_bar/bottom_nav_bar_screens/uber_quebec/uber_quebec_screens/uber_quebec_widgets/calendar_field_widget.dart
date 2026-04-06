import 'package:flutter/material.dart';

import '../../../../../../utils/app_colors.dart';

class CalendarFieldWidget extends StatelessWidget {
  final ValueChanged<DateTime?> onDateSelected;
  final String labelText;
  final TextEditingController controller;

  const CalendarFieldWidget({
    super.key,
    required this.onDateSelected,
    required this.controller,
    this.labelText = 'Select Date',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2101),
        );

        if (selectedDate != null) {
          controller.text =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        }
        onDateSelected(selectedDate);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.goldenOrangeColor,
            ),
          ),
        ),
      ),
    );
  }
}