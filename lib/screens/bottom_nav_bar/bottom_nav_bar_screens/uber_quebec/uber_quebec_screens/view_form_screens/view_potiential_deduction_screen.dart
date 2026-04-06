import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../uber_quebec_widgets/static_name_year_input_field.dart';
import '../uber_quebec_widgets/static_values_widget.dart';

class ViewPotentialDeductionScreen extends StatefulWidget {
  final QuebecModel quebecModel;

  const ViewPotentialDeductionScreen({super.key, required this.quebecModel});

  @override
  State<ViewPotentialDeductionScreen> createState() =>
      _ViewPotentialDeductionScreenState();
}

class _ViewPotentialDeductionScreenState
    extends State<ViewPotentialDeductionScreen> {
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

    _periodFrom = DateTime.tryParse(widget.quebecModel.periodFrom);
    if (_periodFrom != null) {
      _periodFromController.text = Utils.formatDate(_periodFrom!);
    }
    _periodTo = DateTime.tryParse(widget.quebecModel.periodTo);
    if (_periodTo != null) {
      _periodToController.text = Utils.formatDate(_periodTo!);
    }
    _dueDate = DateTime.tryParse(widget.quebecModel.dueDate);
    if (_dueDate != null) {
      _dueDateController.text = Utils.formatDate(_dueDate!);
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
                        selectedYear: widget.quebecModel.year,
                        name: widget.quebecModel.name,
                      ),
                      const SizedBox(height: 8),
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

                      _valuesViewsWidget(
                        AppLocalizations.of(
                              context,
                            )!.translate("tripMileageText") ??
                            '',
                        widget.quebecModel.onTripMileage,
                      ),
                      const SizedBox(height: 10),
                      _valuesViewsWidget(
                        AppLocalizations.of(
                              context,
                            )!.translate("onlineMileageText") ??
                            '',
                        widget.quebecModel.onlineMileage,
                      ),
                      const SizedBox(height: 15),
                      _dateViewWidget(
                        AppLocalizations.of(
                              context,
                            )!.translate("periodFromText") ??
                            '',
                        widget.quebecModel.periodFrom,
                      ),

                      const SizedBox(height: 15),
                      _dateViewWidget(
                        AppLocalizations.of(
                              context,
                            )!.translate("periodToText") ??
                            '',
                        widget.quebecModel.periodTo,
                      ),

                      const SizedBox(height: 15),
                      _dateViewWidget(
                        AppLocalizations.of(
                              context,
                            )!.translate("dueDateText") ??
                            '',
                        widget.quebecModel.dueDate,
                      ),

                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("lastDetailsText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          AppLocalizations.of(context)!.translate("prevText") ??
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _valuesViewsWidget(String label, double values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        StaticKmValues(value: values, text: 'Km'),
      ],
    );
  }

  Widget _dateViewWidget(String label, String? dateValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            dateValue ?? "mm/dd/yyy",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
