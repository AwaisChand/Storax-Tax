import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/trip_view_model/trip_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';

Widget buildMultipleTripReportButtons(BuildContext context, String tabMode) {
  final tripVM = context.watch<TripViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MaterialButton(
          color: AppColors.goldenOrangeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onPressed: () async {
            if (!Utils.validateCustomDate(tabMode: tabMode, vm: tripVM)) return;

            String? formattedFromDate;
            String? formattedToDate;

            if (tabMode.toLowerCase() == 'custom') {
              formattedFromDate = DateFormat(
                'yyyy-MM-dd',
              ).format(tripVM.fromDate!);
              formattedToDate = DateFormat('yyyy-MM-dd').format(tripVM.toDate!);
            }

            debugPrint("TAB MODE => $tabMode");
            debugPrint("FROM DATE => ${tripVM.fromDate}");
            debugPrint("TO DATE => ${tripVM.toDate}");
            debugPrint("FORMATTED FROM => $formattedFromDate");
            debugPrint("FORMATTED TO => $formattedToDate");
            final String? downloadedPath = await tripVM.exportToPdfReportApi(
              fromDate: formattedFromDate,
              toDate: formattedToDate,
              language: locale,
              tabMode: tabMode,
            );

            if (downloadedPath != null && context.mounted) {
              Utils.toastMessage("PDF Trip Report downloaded successfully!");
              await OpenFile.open(downloadedPath);
            }
          },
          child:
              tripVM.exportLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    AppLocalizations.of(context)!.translate("expToPdfText") ??
                        '',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.whiteColor,
                    ),
                  ),
        ),

        const SizedBox(width: 6),

        /// 📧 SMALL EMAIL BUTTON
        SizedBox(
          width: 90,
          height: 36,
          child: MaterialButton(
            padding: EdgeInsets.zero,
            color: AppColors.goldenOrangeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              if (!Utils.validateCustomDate(tabMode: tabMode, vm: tripVM))
                return;

              showForwardTripReportDialog(context, tabMode);
            },
            child:
                tripVM.forwardTripLoading
                    ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      AppLocalizations.of(
                            context,
                          )!.translate("emailReportText") ??
                          '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
        ),

        const SizedBox(width: 6),

        SizedBox(
          width: 70,
          height: 36,
          child: MaterialButton(
            padding: EdgeInsets.zero,
            color: AppColors.goldenOrangeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () async {
              if (!Utils.validateCustomDate(tabMode: tabMode, vm: tripVM))
                return;

              String? formattedFromDate;
              String? formattedToDate;

              if (tabMode.toLowerCase() == 'custom') {
                formattedFromDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(tripVM.fromDate!);
                formattedToDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(tripVM.toDate!);
              }

              final String? downloadedPath = await tripVM.printTripReportApi(
                fromDate: formattedFromDate,
                toDate: formattedToDate,
                language: locale,
                tabMode: tabMode,
              );

              if (downloadedPath != null && context.mounted) {
                final file = File(downloadedPath);

                if (await file.exists()) {
                  final bytes = await file.readAsBytes();

                  await Printing.layoutPdf(
                    name: "Trip Report",
                    onLayout: (format) async => bytes,
                  );
                } else {
                  Utils.toastMessage("File not found");
                }
              }
            },
            child:
                tripVM.printTripLoading
                    ? const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      AppLocalizations.of(context)!.translate("printText") ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor,
                      ),
                    ),
          ),
        ),
      ],
    ),
  );
}

void showForwardTripReportDialog(BuildContext context, String tabMode) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<TripViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate("emailReportText") ?? '',
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
                  AppLocalizations.of(context)!.translate("emailText") ?? '',
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
                  "filter": tabMode,
                  "email": email,
                  "password": password,
                };
                provider.reportTripForwardApi(context, data, locale);
                debugPrint("Forward Trip Data: $data");
                Navigator.pop(context);
              }
            },
            child:
                provider.forwardTripLoading
                    ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      AppLocalizations.of(context)!.translate("forwardText") ??
                          '',
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
