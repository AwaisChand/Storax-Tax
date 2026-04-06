import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/calendar_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/increment_decrement_input_field_km_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';

class PotentialDeductionScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const PotentialDeductionScreen({super.key, required this.quebecModel});

  @override
  State<PotentialDeductionScreen> createState() =>
      _PotentialDeductionScreenState();
}

class _PotentialDeductionScreenState extends State<PotentialDeductionScreen> {
  DateTime? _periodFrom;
  DateTime? _periodTo;
  DateTime? _dueDate;

  final TextEditingController _periodFromController = TextEditingController();
  final TextEditingController _periodToController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  double km1 = 0.00;
  double km2 = 0.00;

  @override
  void initState() {
    super.initState();

    // Prefill values from QuebecModel
    km1 = widget.quebecModel.onTripMileage;
    km2 = widget.quebecModel.onlineMileage;


    if (widget.quebecModel.periodFrom != null) {
      _periodFrom = DateTime.tryParse(widget.quebecModel.periodFrom);
      if (_periodFrom != null) {
        _periodFromController.text = Utils.formatDate(_periodFrom!);
      }
    }
    if (widget.quebecModel.periodTo != null) {
      _periodTo = DateTime.tryParse(widget.quebecModel.periodTo);
      if (_periodTo != null) {
        _periodToController.text = Utils.formatDate(_periodTo!);
      }
    }
    if (widget.quebecModel.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.quebecModel.dueDate);
      if (_dueDate != null) {
        _dueDateController.text = Utils.formatDate(_dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _periodFromController.dispose();
    _periodToController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime? date, String type) {
    setState(() {
      if (type == "from") {
        _periodFrom = date;
        _periodFromController.text = date != null ? Utils.formatDate(date) : "";
      } else if (type == "to") {
        _periodTo = date;
        _periodToController.text = date != null ? Utils.formatDate(date) : "";
      } else if (type == "due") {
        _dueDate = date;
        _dueDateController.text = date != null ? Utils.formatDate(date) : "";
      }
    });
  }

  // Function to show the review popup
  void _showReviewPopup(BuildContext context, QuebecViewModel quebec) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 10,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 60,
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.translate("revInfoTitleText") ??
                    '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.translate("revInfoSubText") ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: MaterialButton(
                      height: 40,
                      color: AppColors.goldenOrangeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        // 1️⃣ Close dialog immediately
                        Navigator.of(dialogContext).pop();

                        // 2️⃣ Build updated model safely
                        final updatedModel = widget.quebecModel.copyWith(
                          onTripMileage: km1,
                          onlineMileage: km2,
                          periodFrom: _periodFrom?.toIso8601String(),
                          periodTo: _periodTo?.toIso8601String(),
                          dueDate: _dueDate?.toIso8601String(),
                        );

                        debugPrint(
                          "Final Quebec API Payload: ${updatedModel.toJson()}",
                        );

                        // 3️⃣ Trigger API (no dialog context)
                        quebec.createQuebecApi(context, updatedModel.toJson());
                      },

                      child:
                          quebec.isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blackColor,
                                ),
                              )
                              : Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("yesSaveText") ??
                                    '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: AppColors.blackColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MaterialButton(
                      height: 40,
                      color: AppColors.goldenOrangeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                      child: Text(
                        AppLocalizations.of(context)!.translate("cancelText") ??
                            '',
                        style: GoogleFonts.poppins(
                          color:
                              AppColors
                                  .darkMidnightColor, // assuming dark text on light button
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuebecViewModel>(
      builder: (context, quebec, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text3:
                AppLocalizations.of(context)!.translate("docTitleText") ?? '',
            text1: 'UBER',
            text2:
                AppLocalizations.of(
                  context,
                )!.translate("taxSummaryPeriodText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.backgroundImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StaticNameYearInputField(
                        selectedYear: widget.quebecModel.year ?? "",
                        name: widget.quebecModel.name ?? "",
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   "Many of the items listed below may be tax deductible. For more information, we recommend that you seek guidance from a qualified tax site or service.",
                      //   style: GoogleFonts.poppins(
                      //     fontWeight: FontWeight.w400,
                      //     fontSize: 10,
                      //     color: AppColors.blackColor,
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("potentialDedText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: AppColors.darkMidnightColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // On Trip Mileage
                      _labelText(
                        AppLocalizations.of(
                              context,
                            )!.translate("tripMileageText") ??
                            '',
                      ),
                      const SizedBox(height: 4),
                      IncrementDecrementInputFieldKmWidget(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translate("tripMileageText") ??
                            '',
                        initialValue: km1,
                        onChanged: (value) {
                          setState(() {
                            km1 = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // Online Mileage
                      _labelText(
                        AppLocalizations.of(
                              context,
                            )!.translate("onlineMileageText") ??
                            '',
                      ),
                      const SizedBox(height: 4),
                      IncrementDecrementInputFieldKmWidget(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translate("onlineMileageText") ??
                            '',
                        initialValue: km2,
                        onChanged: (value) {
                          setState(() {
                            km2 = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Date fields
                      CalendarFieldWidget(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translate("periodFromText") ??
                            '',
                        controller: _periodFromController,
                        onDateSelected: (date) => _onDateSelected(date, "from"),
                      ),
                      const SizedBox(height: 15),
                      CalendarFieldWidget(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translate("periodToText") ??
                            '',
                        controller: _periodToController,
                        onDateSelected: (date) => _onDateSelected(date, "to"),
                      ),
                      const SizedBox(height: 15),
                      CalendarFieldWidget(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translate("dueDateText") ??
                            '',
                        controller: _dueDateController,
                        onDateSelected: (date) => _onDateSelected(date, "due"),
                      ),
                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                              AppLocalizations.of(
                                    context,
                                  )!.translate("prevText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
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
                              _showReviewPopup(context, quebec);
                            },
                            child:
                                quebec.isLoading
                                    ? Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    )
                                    : Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("saveText") ??
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
