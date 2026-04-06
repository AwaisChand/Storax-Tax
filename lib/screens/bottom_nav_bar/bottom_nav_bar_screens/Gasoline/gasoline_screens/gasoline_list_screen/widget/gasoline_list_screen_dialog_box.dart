import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';

void showMultipleForwardGasolineDialog(
  BuildContext context,
  List<int> fileIds,
) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<GasolineViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("forwardMultipleGas") ?? '',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: emailController,
              hintText:
                  AppLocalizations.of(context)!.translate("recipientEmail") ??
                  '',
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: passwordController,
              hintText:
                  AppLocalizations.of(context)!.translate("passwordText") ?? '',
              textInputType: TextInputType.visiblePassword,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          MaterialButton(
            height: 40,
            color: AppColors.lightPinkColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.translate("cancelText") ?? '',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          MaterialButton(
            height: 40,
            color: AppColors.goldenOrangeColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                Utils.toastMessage("All fields are required.");
                return;
              } else {
                Map data = {
                  "email": email,
                  "password": password,
                  "entry_ids": fileIds,
                };
                provider.forwardMultipleGasolineFileApi(context, data, locale);
                Navigator.pop(context);
              }
            },
            child: Text(
              AppLocalizations.of(context)!.translate("forwardText") ?? '',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
