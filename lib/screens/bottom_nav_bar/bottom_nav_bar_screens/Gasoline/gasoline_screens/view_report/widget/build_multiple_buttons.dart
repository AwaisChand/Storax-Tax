import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';

Widget buildForwardGasolineReportMultipleButton(BuildContext context) {
  final provider = context.watch<GasolineViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  return Row(
    children: [
      SizedBox(
        width: Utils.setHeight(context) * 0.2,
        child: MaterialButton(
          color: AppColors.goldenOrangeColor,
          height: 40,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("printText") ?? '',
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () async {
            final year = provider.selectedGraphYear;
            final month = provider.selectedGraphMonth != null
                ? DateFormat('yyyy-MM').format(provider.selectedGraphMonth!)
                : '';
            final fromDate =
                provider.fromDate != null
                    ? DateFormat('yyyy-MM-dd').format(provider.fromGraphDate!)
                    : null;
            final toDate =
                provider.toDate != null
                    ? DateFormat('yyyy-MM-dd').format(provider.toGraphDate!)
                    : null;

            final pdfPath = await provider.printReportApi(
              year: year,
              month: month,
              fromDate: fromDate,
              toDate: toDate,
              language: locale,
            );

            if (pdfPath != null) {
              final file = File(pdfPath);
              if (await file.exists()) {
                await Printing.layoutPdf(
                  onLayout: (_) async => await file.readAsBytes(),
                  name: "Personal_Info.pdf",
                );
              } else {
                Utils.toastMessage("PDF file not found.");
              }
            } else {
              Utils.toastMessage("Failed to load PDF file.");
            }
          },
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: Utils.setHeight(context) * 0.2,
        child: MaterialButton(
          color: AppColors.goldenOrangeColor,
          height: 40,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("forwardFileText") ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            showGForwardDialog(context);
          },
        ),
      ),
    ],
  );
}

void showGForwardDialog(BuildContext context) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<GasolineViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("forwardFileText") ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
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
            color: AppColors.lightPinkColor,
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.translate("cancelText") ?? '',
            ),
          ),
          MaterialButton(
            color: AppColors.goldenOrangeColor,
            onPressed: () {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                Utils.toastMessage("All fields are required.");
                return;
              }

              // ✅ SAME FILTER LOGIC AS PRINT
              final year =
                  provider.selectedGraphYear ?? DateTime.now().year.toString();

              final month =
                  provider.selectedGraphMonth != null
                      ? DateFormat('yyyy-MM').format(provider.selectedGraphMonth!)
                      : null;

              final fromDate =
                  provider.fromGraphDate != null
                      ? DateFormat('yyyy-MM-dd').format(provider.fromGraphDate!)
                      : null;

              final toDate =
                  provider.toGraphDate != null
                      ? DateFormat('yyyy-MM-dd').format(provider.toGraphDate!)
                      : null;

              final data = {
                "email": email,
                "password": password,
                "year": year,
                "month": month,
                "from_date": fromDate,
                "to_date": toDate,
              };

              debugPrint("📤 Forward report data: $data");

              provider.reportForwardApi(context, data, locale);
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.translate("forwardText") ?? '',
            ),
          ),
        ],
      );
    },
  );
}
