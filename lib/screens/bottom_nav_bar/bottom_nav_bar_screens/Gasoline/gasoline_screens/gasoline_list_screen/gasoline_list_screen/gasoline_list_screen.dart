import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/create_gasoline/create_gasoline_screens/add_receipt_scan_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/transaction_report/transaction_report_screen/transaction_report_screen.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/rental_property_view_model/rental_property_view_model.dart';
import '../../update_gasoline/update_gasoline_data_screen.dart';
import '../widget/gasoline_screen_widgets.dart';
import '../../view_gasoline/view_gasoline_detail_screen.dart';

class GasolineListScreen extends StatefulWidget {
  const GasolineListScreen({super.key});

  @override
  State<GasolineListScreen> createState() => _GasolineListScreenState();
}

class _GasolineListScreenState extends State<GasolineListScreen> {
  static const String ACTION_VIEW = "view";
  static const String ACTION_EDIT = "edit";
  static const String ACTION_DELETE = "delete";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GasolineViewModel>().getGasolineApi(context);
      // context.read<PricingPlansViewModel>().myPlansApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isGasReceiptsEnterprise = planNames.any(
      (n) => n.contains('gas receipts manager - business version'),
    );

    final isFreeGasPlan = planNames.any(
      (n) => n.contains('free version') || n.contains('basic'),
    );
    return Consumer<GasolineViewModel>(
      builder: (context, gasoline, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("gasolineText") ?? '',
            text2:
                AppLocalizations.of(context)!.translate("manageGasolineText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              final provider = context.read<RentalPropertyViewModel>();
              provider.getRentalPropertyPlanApi(context);
            }
          },
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              if (isFreeGasPlan && gasoline.gasolineList.length >= 10) {
                Utils.toastMessage(
                  AppLocalizations.of(
                        context,
                      )!.translate("gasRestrictionText") ??
                      '',
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddReceiptScanScreen()),
                );
              }
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
              ),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          buildGasolineFilterBar(context),
                          const SizedBox(height: 15),
                          buildForwardGasolineMultipleButton(context),
                          SizedBox(height: 5),
                          if (!isFreeGasPlan)
                            SizedBox(
                              width: double.infinity,
                              child: MaterialButton(
                                color: AppColors.goldenOrangeColor,
                                height: 40,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("transactionReportText") ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.whiteColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              TransactionReportScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          gasoline.isLoading
                              ? SizedBox(
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
                              : gasoline.gasolineList.isEmpty
                              ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("noGasolineText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                        height: Utils.setHeight(context) * 0.03,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: gasoline.gasolineList.length,
                                itemBuilder: (context, index) {
                                  final gasolineData =
                                      gasoline.gasolineList[index];
                                  final isSelected = selectedFileGasolineIds
                                      .contains(gasolineData.id);

                                  return Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(top: 20),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.65,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("merchantText") ?? ''}:",
                                                        " ${gasolineData.merchant}",
                                                      ),
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("totalText") ?? ''}:",
                                                        " ${gasolineData.total}",
                                                      ),
                                                      if (!isFreeGasPlan) ...[
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("taxText") ?? ''}:",
                                                          " ${gasolineData.tax}",
                                                        ),
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("beforeTaxText") ?? ''}:",
                                                          " ${gasolineData.beforeTaxAmount}",
                                                        ),
                                                      ],
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("dateText") ?? ''}:",
                                                        " ${gasolineData.dateRecieved}",
                                                      ),
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("refText") ?? ''}:",
                                                        " ${gasolineData.reference}",
                                                      ),
                                                      if (isGasReceiptsEnterprise) ...[
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("statusText") ?? ''}:",
                                                          " ${gasolineData.status}",
                                                        ),
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("uploadByText") ?? ''}:",
                                                          " ${gasolineData.uploadedBy}",
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  onSelected: (value) {
                                                    if (value == ACTION_VIEW) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => ViewGasolineDetailScreen(
                                                                gasolineData:
                                                                    gasolineData,
                                                              ),
                                                        ),
                                                      );
                                                    } else if (value ==
                                                        ACTION_EDIT) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => UpdateGasolineDataScreen(
                                                                data:
                                                                    gasolineData,
                                                              ),
                                                        ),
                                                      );
                                                    } else if (value ==
                                                        ACTION_DELETE) {
                                                      gasoline
                                                          .deleteGasolineApi(
                                                            context,
                                                            gasolineData.id ??
                                                                0,
                                                          )
                                                          .then((success) {
                                                            if (success) {
                                                              setState(() {
                                                                gasoline
                                                                    .gasolineList
                                                                    .removeAt(
                                                                      index,
                                                                    );
                                                              });
                                                            }
                                                          });
                                                    }
                                                  },

                                                  itemBuilder:
                                                      (context) => [
                                                        _popupItem(
                                                          ACTION_VIEW,
                                                          Icons.remove_red_eye,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "viewText",
                                                              ) ??
                                                              '',
                                                        ),
                                                        _popupItem(
                                                          ACTION_EDIT,
                                                          Icons.edit,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "editText",
                                                              ) ??
                                                              '',
                                                        ),
                                                        _popupItem(
                                                          ACTION_DELETE,
                                                          Icons.delete,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "deleteText",
                                                              ) ??
                                                              '',
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Checkbox
                                      Positioned(
                                        top: 25,
                                        right: 5,
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor:
                                              AppColors.goldenOrangeColor,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedFileGasolineIds.add(
                                                  gasolineData.id ?? 0,
                                                );
                                              } else {
                                                selectedFileGasolineIds.remove(
                                                  gasolineData.id ?? 0,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _popupItem(
    String value,
    IconData icon,
    String text, {
    Color color = Colors.black,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String label, String value) {
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
              value,
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
