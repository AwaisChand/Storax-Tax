import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_income_type/rental_income_type_screen/rental_income_type_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_income_type/rental_income_type_screen/rental_income_type_update_screen.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../rental_property_tab_screen/rental_property_tab_screen.dart';

class RentalIncomeTypeListScreen extends StatefulWidget {
  const RentalIncomeTypeListScreen({super.key, this.planId});

  final int? planId;

  @override
  State<RentalIncomeTypeListScreen> createState() =>
      _RentalIncomeTypeListScreenState();
}

class _RentalIncomeTypeListScreenState
    extends State<RentalIncomeTypeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalPropertyViewModel>().getIncomeTypesApi(
        context: context,
        planId: widget.planId ?? 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProperty, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:AppLocalizations.of(context)!.translate("rIncomeText") ??
                '',
            text2: AppLocalizations.of(
              context,
            )!.translate("manageIncomeText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalPropertyTabScreen(),
                ),
              );            },
          ),
          floatingActionButton: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.add, size: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            RentalIncomeTypeScreen(planId: widget.planId),
                  ),
                );
              },
            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          rentalProperty.otherLoading
                              ? SizedBox(
                                height: Utils.setHeight(context),
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
                              : rentalProperty.data.isEmpty
                              ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("noIncomeTypesText") ??
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
                                itemCount: rentalProperty.data.length,
                                itemBuilder: (context, index) {
                                  final incomeData = rentalProperty.data[index];

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // File Details
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
                                                    " ${incomeData.name}",
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Menu
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                switch (value) {
                                                  case 'view':
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (_) =>
                                                              _buildInfoDialog(
                                                                context,
                                                                incomeData,
                                                              ),
                                                    );
                                                    break;
                                                  case 'edit':
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => RentalIncomeTypeUpdateScreen(
                                                              information:
                                                                  incomeData,
                                                              planId:
                                                                  widget.planId,
                                                            ),
                                                      ),
                                                    );
                                                    break;
                                                  case 'delete':
                                                    rentalProperty
                                                        .deleteIncomeTypesApi(
                                                          context,
                                                          incomeData.id ?? 0,
                                                        )
                                                        .then((success) {
                                                          if (success) {
                                                            setState(() {
                                                              rentalProperty
                                                                  .data
                                                                  .removeAt(
                                                                    index,
                                                                  );
                                                            });
                                                          }
                                                        });
                                                    break;
                                                }
                                              },
                                              icon: const Icon(Icons.more_vert),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: const BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              itemBuilder:
                                                  (context) => [
                                                    _localizedPopupItem(
                                                      value: 'view',
                                                      icon:
                                                          Icons.remove_red_eye,
                                                      text:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.translate(
                                                            "viewText",
                                                          ) ??
                                                          '',
                                                    ),
                                                    _localizedPopupItem(
                                                      value: 'edit',
                                                      icon: Icons.edit,
                                                      text:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.translate(
                                                            "editText",
                                                          ) ??
                                                          '',
                                                    ),
                                                    _localizedPopupItem(
                                                      value: 'delete',
                                                      icon: Icons.delete,
                                                      text:
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
    IconData icon,
    String text, {
    Color color = Colors.black,
  }) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
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

  PopupMenuItem<String> _localizedPopupItem({
    required String value,
    required IconData icon,
    required String text,
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

  Widget _buildInfoDialog(BuildContext context, IncomeTypesData incomeData) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- TITLE + CLOSE ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Information for: ${incomeData.name}",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ---------- INFO LIST ----------
            Column(
              children: List.generate(incomeData.information!.length, (index) {
                final info = incomeData.information?[index];

                String display =
                    "${info?.firstName ?? ''} ${info?.lastName ?? ''}";
                if (info?.email != null) display += " - ${info?.email}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Info Text
                      Expanded(
                        child: Text(
                          display,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      /// ---------- PRIMARY BADGE ----------
                      if (info?.isPrimary == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldenOrangeColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Primary",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
