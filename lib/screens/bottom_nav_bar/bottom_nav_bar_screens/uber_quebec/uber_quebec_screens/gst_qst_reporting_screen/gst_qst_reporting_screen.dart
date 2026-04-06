import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/gst_qst_reporting_screen/widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/scan_quebec/scan_quebec_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/uber_quebec_widgets/quebec_filter_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/view_form_screens/view_rides_gross_screen.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../models/quebec_model/quebec_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';

class GstQstReportingScreen extends StatefulWidget {
  const GstQstReportingScreen({super.key});

  @override
  State<GstQstReportingScreen> createState() => _GstQstReportingScreenState();
}

class _GstQstReportingScreenState extends State<GstQstReportingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuebecViewModel>().gstQstReportingApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const String actionView = 'view';
  static const String actionGross = 'gross_report';
  static const String printActionGross = 'print_gross_report';
  static const String forwardActionGrossReport = 'forward_gross_report';
  static const String actionGstQst = 'gst_qst_report';
  static const String printActionGstQst = 'print_gst_qst_report';
  static const String forwardActionGstQst = 'forward_gst_qst_report';

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)?.locale.languageCode;
    return Consumer<QuebecViewModel>(
      builder: (context, quebec, _) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("uberTitleText") ?? '',
            text2:
                AppLocalizations.of(context)!.translate("manageDescText") ?? '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanQuebecScreen()),
              );
            },
            child: Icon(Icons.add, size: 40),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        buildQuebecFilterBar(context),
                        const SizedBox(height: 15),
                        if (quebec.isLoading)
                          SizedBox(
                            height: Utils.setHeight(context) * 0.5,
                            child: Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color: AppColors.blackColor,
                                  strokeWidth: 4,
                                ),
                              ),
                            ),
                          )
                        else if (quebec.data.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("noQuebecText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  height: Utils.setHeight(context) * 0.03,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quebec.data.length,
                            itemBuilder: (context, index) {
                              final quebecData = quebec.data[index];

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.65,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("nameText") ?? ''}:",
                                                " ${quebecData.name}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("periodFromText") ?? ''}:",
                                                " ${quebecData.periodFrom}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("periodToText") ?? ''}:",
                                                " ${quebecData.periodTo}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("dueDateText") ?? ''}:",
                                                quebecData.dueDate,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == actionView) {
                                              final model = QuebecModel(
                                                id: quebecData.id,
                                                name: quebecData.name ?? '',
                                                year: quebecData.year ?? '',
                                                grossUberRidesFares:
                                                    quebecData
                                                        .grossUberRidesFares!
                                                        .toDouble(),
                                                bookingFee:
                                                    quebecData.bookingFee!
                                                        .toDouble(),
                                                mtqDues:
                                                    quebecData.mtqDues!
                                                        .toDouble(),
                                                airportFee:
                                                    quebecData.airportFee!
                                                        .toDouble(),
                                                splitFare:
                                                    quebecData.splitFare!
                                                        .toDouble(),
                                                miscellaneous:
                                                    quebecData.miscellaneous!
                                                        .toDouble(),
                                                tolls:
                                                    quebecData.tolls!
                                                        .toDouble(),
                                                tips:
                                                    quebecData.tips!.toDouble(),
                                                gstCollectedFromRiders:
                                                    quebecData
                                                        .gstCollectedFromRiders!
                                                        .toDouble(),
                                                qstCollectedFromRiders:
                                                    quebecData
                                                        .qstCollectedFromRiders!
                                                        .toDouble(),
                                                otherTaxableIncome:
                                                    double.tryParse(
                                                      quebecData
                                                              .otherTaxableIncome
                                                              ?.toString() ??
                                                          '',
                                                    ) ??
                                                    0.0,
                                                section1Total:
                                                    quebecData.section1Total!
                                                        .toDouble(),
                                                serviceFee:
                                                    quebecData.serviceFee!
                                                        .toDouble(),
                                                otherAmounts:
                                                    quebecData.otherAmounts!
                                                        .toDouble(),
                                                feeDiscount:
                                                    quebecData.feeDiscount!
                                                        .toDouble(),
                                                gstPaidToUber:
                                                    quebecData.gstPaidToUber!
                                                        .toDouble(),
                                                qstPaidToUber:
                                                    quebecData.qstPaidToUber!
                                                        .toDouble(),
                                                section2Total:
                                                    quebecData.section2Total!
                                                        .toDouble(),
                                                uberGstRegistrationNumber:
                                                    quebecData
                                                        .uberGstRegistrationNumber ??
                                                    '',
                                                uberQstRegistrationNumber:
                                                    quebecData
                                                        .uberQstRegistrationNumber ??
                                                    '',
                                                suppliesExcludingGstQst:
                                                    quebecData
                                                        .suppliesExcludingGstQst!
                                                        .toDouble(),
                                                gstRemittedByUber:
                                                    quebecData
                                                        .gstRemittedByUber!
                                                        .toDouble(),
                                                qstRemittedByUber:
                                                    quebecData
                                                        .qstRemittedByUber!
                                                        .toDouble(),
                                                gstCollectedFromRidersSec3:
                                                    quebecData
                                                        .gstCollectedFromRidersSec3!
                                                        .toDouble(),
                                                qstCollectedFromRidersSec3:
                                                    quebecData
                                                        .qstCollectedFromRidersSec3!
                                                        .toDouble(),
                                                yourGstNumberSec3:
                                                    quebecData
                                                        .yourGstNumberSec3 ??
                                                    '',
                                                yourQstNumberSec3:
                                                    quebecData
                                                        .yourQstNumberSec3 ??
                                                    '',
                                                grossUberEatsFare:
                                                    quebecData
                                                        .grossUberEatsFare!
                                                        .toDouble(),
                                                eatsTips:
                                                    quebecData.eatsTips!
                                                        .toDouble(),
                                                gstCollectedFromUber:
                                                    quebecData
                                                        .gstCollectedFromUber!
                                                        .toDouble(),
                                                qstCollectedFromUber:
                                                    quebecData
                                                        .qstCollectedFromUber!
                                                        .toDouble(),
                                                section4Total:
                                                    quebecData.section4Total!
                                                        .toDouble(),
                                                yourGstNumberSec4:
                                                    quebecData
                                                        .yourGstNumberSec4 ??
                                                    '',
                                                yourQstNumberSec4:
                                                    quebecData
                                                        .yourQstNumberSec4 ??
                                                    '',
                                                quickAccountingMethod6085:
                                                    quebecData
                                                        .quickAccountingMethod6085!
                                                        .toDouble(),
                                                gstCollectedFromUberSec5:
                                                    quebecData
                                                        .gstCollectedFromUberSec5!
                                                        .toDouble(),
                                                qstCollectedFromUberSec5:
                                                    quebecData
                                                        .qstCollectedFromUberSec5!
                                                        .toDouble(),
                                                section5Total:
                                                    quebecData.section5Total!
                                                        .toDouble(),
                                                uberGstRegistrationNumberSec5:
                                                    quebecData
                                                        .uberGstRegistrationNumberSec5 ??
                                                    '',
                                                uberQstRegistrationNumberSec5:
                                                    quebecData
                                                        .uberQstRegistrationNumberSec5 ??
                                                    '',
                                                onTripMileage:
                                                    quebecData.onTripMileage!
                                                        .toDouble(),
                                                onlineMileage:
                                                    quebecData.onlineMileage!
                                                        .toDouble(),
                                                otherIncomeMiscellaneous:
                                                    quebecData.otherIncomeMis!
                                                        .toDouble(),
                                                periodFrom:
                                                    quebecData.periodFrom ?? '',
                                                periodTo:
                                                    quebecData.periodTo ?? '',
                                                dueDate:
                                                    quebecData.dueDate ?? '',
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ViewRidesGrossScreen(
                                                            quebecModel: model,
                                                          ),
                                                ),
                                              );
                                            } else if (value == actionGstQst) {
                                              final filePath = await quebec
                                                  .generateGstQstReportApi(
                                                    id: quebecData.id ?? 0,
                                                    language: language ?? '',
                                                  );

                                              if (filePath != null) {
                                                await OpenFile.open(filePath);
                                              } else {
                                                Utils.toastMessage(
                                                  "Failed to generate GST/QST report",
                                                );
                                              }
                                            } else if (value ==
                                                printActionGstQst) {
                                              final filePath = await quebec
                                                  .generateGstQstReportApi(
                                                    id: quebecData.id ?? 0,
                                                    language: language ?? '',
                                                  );

                                              if (filePath != null) {
                                                await Printing.layoutPdf(
                                                  onLayout:
                                                      (_) async =>
                                                          File(
                                                            filePath,
                                                          ).readAsBytes(),
                                                );
                                              } else {
                                                Utils.toastMessage(
                                                  "Failed to generate GST/QST report",
                                                );
                                              }
                                            } else if (value ==
                                                forwardActionGstQst) {
                                              showForwardGSTQSTReportDialog(
                                                context,
                                                quebecData.id ?? 0,
                                              );
                                            } else if (value == actionGross) {
                                              final filePath = await quebec
                                                  .generateGrossIncomeReportApi(
                                                    id: quebecData.id ?? 0,
                                                    language: language ?? '',
                                                  );

                                              if (filePath != null) {
                                                await OpenFile.open(filePath);
                                              } else {
                                                Utils.toastMessage(
                                                  "Failed to generate gross income report",
                                                );
                                              }
                                            } else if (value ==
                                                printActionGross) {
                                              final filePath = await quebec
                                                  .generateGrossIncomeReportApi(
                                                    id: quebecData.id ?? 0,
                                                    language: language ?? '',
                                                  );

                                              if (filePath != null) {
                                                await Printing.layoutPdf(
                                                  onLayout:
                                                      (_) async =>
                                                          File(
                                                            filePath,
                                                          ).readAsBytes(),
                                                );
                                              } else {
                                                Utils.toastMessage(
                                                  "Failed to generate Gross Income report",
                                                );
                                              }
                                            } else if (value ==
                                                forwardActionGrossReport) {
                                              showForwardGrossIncomeDialog(
                                                context,
                                                quebecData.id ?? 0,
                                              );
                                            }
                                          },

                                          itemBuilder:
                                              (context) => [
                                                _popupItem(
                                                  actionView,
                                                  Icons.visibility,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "viewText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  actionGross,
                                                  Icons.report,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "genGrossText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  printActionGross,
                                                  Icons.print,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "printGrossText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  forwardActionGrossReport,
                                                  Icons.forward,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "forwardGrossReportText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  actionGstQst,
                                                  Icons.report,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "genReportText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  printActionGstQst,
                                                  Icons.print,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "printReportText",
                                                      ) ??
                                                      '',
                                                ),
                                                _popupItem(
                                                  forwardActionGstQst,
                                                  Icons.forward,
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "forwardReportText",
                                                      ) ??
                                                      '',
                                                ),
                                              ],

                                          icon: const Icon(Icons.more_vert),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _popupItem(
    String action,
    IconData icon,
    String text, {
    Color color = Colors.black,
  }) {
    return PopupMenuItem<String>(
      value: action, // ✅ stable key
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              (value == null || value.trim().isEmpty) ? "" : value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
