import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';

Widget topButtonWidget(BuildContext context) {

  return Row(
    children: [
      SizedBox(
        width: Utils.setHeight(context) * 0.2,
        child: MaterialButton(
          color: AppColors.goldenOrangeColor,
          height: 40,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("creaBTicket") ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            context.pushNamed('create-ticket-system');

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => ViewReportScreen()),
            // );
          },
        ),
      ),
    ],
  );
}
