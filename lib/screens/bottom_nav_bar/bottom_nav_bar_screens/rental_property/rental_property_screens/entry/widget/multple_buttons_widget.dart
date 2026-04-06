import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/components/app_text_field.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';

List<int> selectedEntryIds = [];

Widget buildMultipleButtons(BuildContext context, int planId) {
  final rentalProvider = context.watch<RentalPropertyViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Forward File button
      Expanded(
        flex: 2,
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
            if (selectedEntryIds.isEmpty) {
              Utils.toastMessage("Please select at least one file to forward.");
              return;
            }
            showMultipleForwardDialog(context, selectedEntryIds);
          },
        ),
      ),

      SizedBox(width: 8), // spacing
      // Export button
      Expanded(
        flex: 1,
        child: MaterialButton(
          onPressed: () async {
            rentalProvider.exportEntriesToCsv(context,rentalProvider.allEntries);
          },
          height: 30,
          color: AppColors.goldenOrangeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            AppLocalizations.of(context)!.translate("exportText") ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),

      SizedBox(width: 8),

      // Pdf button with year picker
      Expanded(
        flex: 1,
        child: MaterialButton(
          onPressed: () async {
            final int yearToUse =
                rentalProvider.selectedYear != null
                    ? int.parse(rentalProvider.selectedYear!)
                    : DateTime.now().year;

            final filePath = await rentalProvider.allRegularEntriesPrintApi(
              clientPlansId: planId,
              year: yearToUse,
              language: locale,
            );

            if (filePath != null) {
              await OpenFile.open(filePath);
            } else {
              Utils.toastMessage("Failed to generate report");
            }
          },

          height: 30,
          color: AppColors.goldenOrangeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child:
              rentalProvider.isLoading
                  ? Center(
                    child: SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator(
                        color: AppColors.blackColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : Text(
                    AppLocalizations.of(context)!.translate("pdfText") ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ),
        ),
      ),
    ],
  );
}

void showMultipleForwardDialog(BuildContext context, List<int> fileIds) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final provider = context.read<RentalPropertyViewModel>();
  final locale = Localizations.localeOf(context).languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(
                context,
              )!.translate("forwardMultipleEntriesText") ??
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
                  AppLocalizations.of(
                    context,
                  )!.translate("recipientEmail") ??
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
                provider.forwardMultipleEntriesApi(context, data, locale);
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
