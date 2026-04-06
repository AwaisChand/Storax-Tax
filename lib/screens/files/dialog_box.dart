import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/components/app_localization.dart';
import '../../res/components/app_text_field.dart';
import '../../utils/app_colors.dart';
import '../../utils/utils.dart';
import '../../view_models/tax_manager_view_model/tax_manager_view_model.dart';

void showMultipleForwardDialog(BuildContext context, List<int> fileIds) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<TaxManagerViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("forwardMultipleFileText") ??
              '',
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
                  "file_ids": fileIds,
                  "language": locale
                };
                provider.forwardMultipleFileApi(context, data);
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

void showForwardDialog(BuildContext context, String fileName, int fileId) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<TaxManagerViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "${AppLocalizations.of(context)!.translate("forwardFileText") ?? ''}: $fileName",
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
              }

              Map data = {
                "email": email,
                "password": password,
                "file_id": fileId,
                "language": locale
              };
              provider.forwardFileApi(context, data);
              Navigator.pop(context);
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

void showPersonalForwardDialog(
  BuildContext context,
  String fileName,
  int fileId,
  int index,
) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<TaxManagerViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "${AppLocalizations.of(context)!.translate("forwardFileText") ?? ''}: $fileName",
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
              }

              Map data = {
                "email": email,
                "password": password,
                'language': locale,
              };
              provider.personalForwardFileApi(
                context,
                data,
                provider.personalInfo[index].id ?? 0,
              );
              Navigator.pop(context);
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
