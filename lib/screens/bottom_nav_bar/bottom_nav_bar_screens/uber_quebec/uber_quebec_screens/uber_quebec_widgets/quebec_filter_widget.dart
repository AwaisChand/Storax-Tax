import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../res/components/app_localization.dart';

Widget buildQuebecFilterBar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showFilterDialog(context);
    },
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.goldenOrangeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Text(
            AppLocalizations.of(context)!.translate("filterText") ?? '',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Image.asset(AppAssets.filterIcon, height: 15),
        ],
      ),
    ),
  );
}

Future showFilterDialog(BuildContext context) async {
  final now = DateTime.now();
  final currentYear = now.year;
  final List<String> past7Years = List.generate(
    7,
        (i) => (currentYear - i).toString(),
  );

  final provider = Provider.of<QuebecViewModel>(context, listen: false);

  String? selectedYear = provider.selectedYear ?? currentYear.toString();

  return showDialog(
    context: context,
    builder: (context) {
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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// Year Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedYear,
                            items: past7Years.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => selectedYear = val),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Year',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          height: 40,
                          color: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedYear = currentYear.toString(); // reset to current year
                            });
                            provider.clearFilters();
                            provider.gstQstReportingApi(context);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate("resetText") ?? '',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        MaterialButton(
                          height: 40,
                          color: AppColors.goldenOrangeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            final provider = Provider.of<QuebecViewModel>(
                              context,
                              listen: false,
                            );
                            provider.selectedYear = selectedYear;

                            provider.gstQstReportingApi(
                              context,
                              year: selectedYear,
                            );

                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate("filter") ?? '',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
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
