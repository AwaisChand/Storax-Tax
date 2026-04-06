import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_style.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.btnText,
    this.onPressed,
    this.isLoading = false,
  });

  final String btnText;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldenOrangeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor:
            AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
          ),
        )
            : Text(
          btnText,
          textAlign: TextAlign.center,
          style: AppTextStyle.k25Bold700TextStyle.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
