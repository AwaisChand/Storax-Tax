import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/calendar_field_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/increment_decrement_input_field_km_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';

class PotentialDeductionUpdateScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const PotentialDeductionUpdateScreen({super.key, required this.quebecModel});

  @override
  State<PotentialDeductionUpdateScreen> createState() =>
      _PotentialDeductionUpdateScreenState();
}

class _PotentialDeductionUpdateScreenState
    extends State<PotentialDeductionUpdateScreen> {
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
    km1 = widget.quebecModel.onTripMileage ?? 0.0;
    km2 = widget.quebecModel.onlineMileage ?? 0.0;

    if (widget.quebecModel.periodFrom != null) {
      _periodFrom = DateTime.tryParse(widget.quebecModel.periodFrom!);
      if (_periodFrom != null) {
        _periodFromController.text = Utils.formatDate(_periodFrom!);
      }
    }
    if (widget.quebecModel.periodTo != null) {
      _periodTo = DateTime.tryParse(widget.quebecModel.periodTo!);
      if (_periodTo != null) {
        _periodToController.text = Utils.formatDate(_periodTo!);
      }
    }
    if (widget.quebecModel.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.quebecModel.dueDate!);
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
      }
      if (type == "to") {
        _periodTo = date;
        _periodToController.text = date != null ? Utils.formatDate(date) : "";
      }
      if (type == "due") {
        _dueDate = date;
        _dueDateController.text = date != null ? Utils.formatDate(date) : "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuebecViewModel>(
      builder: (context, quebec, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text3: 'NOT AN OFFICIAL INVOICE OR TAX DOCUMENT',
            text1: 'UBER',
            text2: 'Tax summary for the period by\n(Taxation Year)',
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
                      const SizedBox(height: 8),
                      Text(
                        "Many of the items listed below may be tax deductible. For more information, we recommend that you seek guidance from a qualified tax site or service.",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "OTHER POTENTIAL\nDEDUCTIONS",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: AppColors.darkMidnightColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // On Trip Mileage
                      _labelText("On Trip Mileage"),
                      const SizedBox(height: 4),
                      IncrementDecrementInputFieldKmWidget(
                        labelText: 'On Trip Mileage',
                        initialValue: km1,
                        onChanged: (value) {
                          setState(() {
                            km1 = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // Online Mileage
                      _labelText("Online Mileage"),
                      const SizedBox(height: 4),
                      IncrementDecrementInputFieldKmWidget(
                        labelText: 'Online Mileage',
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
                        labelText: "Period From",
                        controller: _periodFromController,
                        onDateSelected: (date) => _onDateSelected(date, "from"),
                      ),
                      const SizedBox(height: 15),
                      CalendarFieldWidget(
                        labelText: "Period To",
                        controller: _periodToController,
                        onDateSelected: (date) => _onDateSelected(date, "to"),
                      ),
                      const SizedBox(height: 15),
                      CalendarFieldWidget(
                        labelText: "Due Date",
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
                              "Previous",
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
                              // Update QuebecModel with new values for final step
                              final updatedModel = widget.quebecModel.copyWith(
                                onTripMileage: km1,
                                onlineMileage: km2,
                                periodFrom: _periodFrom?.toIso8601String(),
                                periodTo: _periodTo?.toIso8601String(),
                                dueDate: _dueDate?.toIso8601String(),
                              );

                              debugPrint(
                                "Final Quebec API Payload: $updatedModel",
                              );

                              quebec.updateQuebecApi(
                                context: context,
                                id: widget.quebecModel.id ?? 0,
                                data: updatedModel.toJson(),
                              );
                            },
                            child:
                                quebec.isLoading
                                    ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    )
                                    : Text(
                                      "Update",
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
