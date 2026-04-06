import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/gst_qst_reporting_screen/gst_qst_reporting_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/routes/routes_name.dart';
import 'package:storatax/utils/utils.dart';

import '../../../../../../res/app_assets.dart';

class FormSubmittedScreen extends StatelessWidget {
  const FormSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Image(
                                  image: AssetImage(AppAssets.circleImg),
                                  fit: BoxFit.cover,
                                  height: Utils.setHeight(context) * 0.2,
                                ),
                              ),
                              Positioned(
                                top: Utils.setHeight(context) * 0.06,
                                right: Utils.setHeight(context) * 0.158,
                                child: Image(
                                  image: AssetImage(AppAssets.checkIcon),
                                  fit: BoxFit.cover,
                                  height: Utils.setHeight(context) * 0.09,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Utils.setHeight(context) * 0.07),
                          Text(
                            "Form Submitted Successfully",
                            style: GoogleFonts.poppins(
                              color: AppColors.midNightColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: AppButton(
                      btnText: "View",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context)=> GstQstReportingScreen())
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
