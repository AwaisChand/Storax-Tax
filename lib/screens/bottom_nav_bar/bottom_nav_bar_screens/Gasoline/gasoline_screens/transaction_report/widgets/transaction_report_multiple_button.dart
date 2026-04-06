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

Widget buildForwardTransactionReportMultipleButton(BuildContext context) {
  final language = AppLocalizations.of(context)?.locale.languageCode;

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
            final provider = context.read<GasolineViewModel>();

            final pdfPath = await provider.getTransactionPdfReportApi(language);

            if (pdfPath != null) {
              final file = File(pdfPath);
              if (await file.exists()) {
                await Printing.layoutPdf(
                  name: "transaction_report.pdf",
                  onLayout: (_) async => file.readAsBytes(),
                );
              } else {
                Utils.toastMessage("PDF file not found.");
              }
            } else {
              Utils.toastMessage("Failed to generate PDF.");
            }
          },
        ),
      ),
      SizedBox(width: 10),
      SizedBox(
        width: Utils.setHeight(context) * 0.2,
        child: MaterialButton(
          color: AppColors.goldenOrangeColor,
          height: 40,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("emailReportText") ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            showTForwardDialog(context);
          },
        ),
      ),
    ],
  );
}

void showTForwardDialog(BuildContext context) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<GasolineViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("emailTransReportText") ?? '',
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
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.translate("encryptPassText") ?? '',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: AppColors.mediumGrayColor,
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            height: 40,
            color: AppColors.lightPinkColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.translate("cancelText") ?? '',
            ),
          ),
          MaterialButton(
            height: 40,
            color: AppColors.goldenOrangeColor,
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

              final fromDate = provider.fromTransDate;
              final toDate = provider.toTransDate;
              final month = provider.selectedTransMonth;
              final year = provider.selectedTransYear;

              // ✅ Convert DateTime to String
              final formattedFromDate = fromDate != null
                  ? DateFormat('yyyy-MM-dd').format(fromDate)
                  : null;

              final formattedToDate = toDate != null
                  ? DateFormat('yyyy-MM-dd').format(toDate)
                  : null;

              final formattedMonth = month != null
                  ? DateFormat('yyyy-MM').format(month)
                  : null;

              // ✅ Build payload
              final Map<String, dynamic> data = {
                "email": email,
                "password": password,
                "from_date": formattedFromDate,
                "to_date": formattedToDate,
                "month": formattedMonth,
                "year": year,
              };

              debugPrint("📧 Forward email payload: $data");

              provider.forwardEmailReportApi(context, data, locale);
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.translate("sendReportText") ?? '',
            ),
          ),
        ],
      );
    },
  );
}
