import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';

Future<String?> showTrackingModeDialogWidget(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 15,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("chooseTrackingModeText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                /// ================= AUTO =================
                InkWell(
                  onTap: () {
                    setDialogState(() => Utils.selectedMode = 'auto');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("autoText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("autoDescText") ??
                                    '',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'auto',
                          groupValue: Utils.selectedMode,
                          activeColor: AppColors.goldenOrangeColor,
                          onChanged: (value) {
                            setDialogState(() => Utils.selectedMode = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(),

                /// ================= MANUAL =================
                InkWell(
                  onTap: () {
                    setDialogState(() => Utils.selectedMode = 'manual');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.touch_app_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("manualText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("manualDescText") ??
                                    '',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'manual',
                          groupValue: Utils.selectedMode,
                          activeColor: AppColors.goldenOrangeColor,
                          onChanged: (value) {
                            setDialogState(() => Utils.selectedMode = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// ================= BUTTONS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        AppLocalizations.of(context)!.translate("cancelText") ??
                            '',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenOrangeColor,
                      ),
                      onPressed: () {
                        if (Utils.selectedMode == null ||
                            Utils.selectedMode!.isEmpty) {
                          Utils.toastMessage("Please select a tracking mode");
                          return;
                        }

                        // Simply return the selected string mode back to MultipleRowButton
                        Navigator.pop(dialogContext, Utils.selectedMode);
                      },
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("confirmText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showActiveTrackingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<GasolineViewModel>(
            builder: (context, vm, _) {
              final trackingData = vm.activeTripModel?.data;
              String duration =
                  vm.activeTripModel?.data?.currentDuration ?? "0 min";
              if (duration.startsWith('-')) {
                duration = "0 min";
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tracking mode: ${trackingData?.trackingMode}",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        "Tracking is active",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your trips are being tracked automatically.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Distance",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${trackingData?.currentDistance}",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 0.5,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Duration",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              duration,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 16),

                  Text(
                    "Trips today",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${trackingData?.tripsToday}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
