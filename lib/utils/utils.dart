import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:storatax/utils/app_colors.dart';

import '../res/app_assets.dart';

class Utils {
  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      textColor: AppColors.whiteColor,
      backgroundColor: AppColors.blackColor,
    );
  }
  //  set height

  static setHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return height;
  }

  // set width

  static setWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width;
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  static bool isValidPassword(String password) {
    // Minimum 8 chars, at least 1 uppercase, 1 lowercase, 1 number, 1 special char
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    double strength = 0;

    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    return strength.clamp(0, 1);
  }

  static Color getStrengthColor(double strength) {
    if (strength < 0.4) return Colors.red;
    if (strength < 0.75) return Colors.pinkAccent;
    return Colors.green;
  }

  /// Returns text based on password strength (0.0 to 1.0)
  static String getStrengthText(double strength) {
    if (strength < 0.4) return "Weak";
    if (strength < 0.75) return "Good";
    return "Strong";
  }

  static showPasswordInfoDialog(context) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Password requirements",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "At least 8 characters",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Include an uppercase letter (A–Z)",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Include a lowercase letter (a–z)",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Include a number (0–9)",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Include a special character (e.g. !@#\$)",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAppBar(
      BuildContext context,
      String text1,
      String text2, [
        String? receiptText,
        VoidCallback? onTap,
      ]) {
    return Container(
      height: Utils.setHeight(context) * 0.15,
      padding: EdgeInsets.only(
        top: Utils.setHeight(context) * 0.04,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(color: AppColors.goldenOrangeColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios_new_outlined),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text1,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      text2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Receipt text (optional)
          if (receiptText != null && receiptText.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Text(
                receiptText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    String title = "Scan Failed",
    required String message,
  }) {
    if (context == null) return;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.orangeAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "OK",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // static String publishKey =
  //     "pk_live_51QWhgzAX1dkfLpyeIbA3me7rYfvXcQUxUnzWwCDvgc2DFG1n2vn0y7kxew5cBlDHT8DD4DFL1iq7pnI5hGHvdVhs00MPf4A5l6";


}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text1;
  final String? text2;
  final String? text3;
  final String? receiptText;
  final VoidCallback? onReceiptTap;
  final VoidCallback? drawerTapped;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.text1,
    this.text2,
    this.text3,
    this.receiptText,
    this.onReceiptTap,
    this.drawerTapped,
    this.onBackTap,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 15,
        right: 15,
        bottom: 12,
      ),
      decoration: BoxDecoration(color: AppColors.goldenOrangeColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Icon + Column of texts
          Row(
            children: [
              InkWell(
                onTap: showBackButton ? onBackTap : drawerTapped,
                child: Image(
                  image: AssetImage(
                    showBackButton ? AppAssets.backIcon : AppAssets.menuIcon,
                  ),
                  fit: BoxFit.cover,
                  height: 18,
                ),
              ),
              const SizedBox(width: 20),

              // ✅ Use SizedBox with constrained width
              SizedBox(
                width: screenWidth * 0.55, // adjust as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((text3 ?? '').isNotEmpty)
                      Text(
                        text3!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                        ),
                      ),
                    Text(
                      text1,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.blackColor,
                      ),
                    ),
                    if ((text2 ?? '').isNotEmpty)
                      Text(
                        text2!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: AppColors.blackColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Receipt text (optional)
          if (receiptText != null && receiptText!.isNotEmpty)
            GestureDetector(
              onTap: onReceiptTap,
              child: Text(
                receiptText!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
        ],
      ),
    );
  }


}
