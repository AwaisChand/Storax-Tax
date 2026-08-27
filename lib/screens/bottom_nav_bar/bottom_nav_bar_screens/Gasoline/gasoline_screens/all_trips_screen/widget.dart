import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../view_models/trip_view_model/trip_view_model.dart';

Widget buildSelectTypeBtn({required VoidCallback onTap}) {
  return SizedBox(
    height: 26,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onTap,
      child: Text(
        "Select Type",
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget buildAllTripsFilter(BuildContext context, VoidCallback onReset) {
  return GestureDetector(
    onTap: () {
      showFilterDialog(context, onReset: onReset);
    },
    child: Container(
      width: Utils.setWidth(context)*0.9,
      height: 40,
      margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
      decoration: BoxDecoration(
        color: AppColors.goldenOrangeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.translate("filterText") ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          Image.asset(AppAssets.filterIcon, height: 15),
        ],
      ),
    ),
  );
}

Future showFilterDialog(BuildContext context, {VoidCallback? onReset}) async {
  final now = DateTime.now();

  final provider = Provider.of<TripViewModel>(context, listen: false);
  final authProvider = Provider.of<AuthViewModel>(context, listen: false).user;

  DateTime? fromDate = provider.fromDate;
  DateTime? toDate = provider.toDate;

  final fromController = TextEditingController(
    text: fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : "",
  );
  final toController = TextEditingController(
    text: toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : "",
  );

  // final languageCode = Localizations.localeOf(context).languageCode;

  final int? userId =
      (authProvider?.role == 'team') ? authProvider?.userId : authProvider?.id;

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(Icons.close, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromController,
                            readOnly: true,
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("fromDateText") ??
                                  '',
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  fromDate = picked;
                                  fromController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: toController,
                            readOnly: true,
                            decoration: _input(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("toDateText") ??
                                  '',
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  toDate = picked;
                                  toController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔥 RESET BUTTON FIXED
                        MaterialButton(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            provider.clearFilters();

                            provider.allTripsApi(perPage: '20', userId: userId);

                            onReset?.call();

                            Navigator.pop(dialogContext);
                          },
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("resetText") ??
                                '',
                          ),
                        ),

                        const SizedBox(width: 15),

                        MaterialButton(
                          color: AppColors.goldenOrangeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            if (fromDate != null && toDate != null) {
                              if (fromDate!.isAfter(toDate!)) {
                                Utils.toastMessage(
                                  "From date cannot be after To date.",
                                );
                                return;
                              }

                              provider.fromDate = fromDate;
                              provider.toDate = toDate;

                              provider.allTripsApi(
                                userId: userId,
                                fromDate: fromDate,
                                toDate: toDate,
                                perPage: '20',
                              );

                              Navigator.pop(dialogContext);
                            } else {
                              Utils.toastMessage("Please select both dates");
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate("filter") ??
                                '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

InputDecoration _input(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
