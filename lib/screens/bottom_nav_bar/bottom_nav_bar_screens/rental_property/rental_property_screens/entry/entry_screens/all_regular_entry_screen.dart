import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/entry_screens/update_entry_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/filter_entries_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_property_tab_screen/rental_property_tab_screen.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/rental_property_view_model/rental_property_view_model.dart';
import '../widget/multple_buttons_widget.dart';
import 'add_entry_screen.dart';

class AllRegularEntryScreen extends StatefulWidget {
  const AllRegularEntryScreen({super.key, required this.planId});
  final int planId;

  @override
  State<AllRegularEntryScreen> createState() => _AllRegularEntryScreenState();
}

class _AllRegularEntryScreenState extends State<AllRegularEntryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalPropertyViewModel>().getAllRegularEntriesApi(
        context: context,
        planId: widget.planId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final auth = context.read<AuthViewModel>();
    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProvider, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("allRegularEntriesText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalPropertyTabScreen(),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEntryScreen(planId: widget.planId),
                ),
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
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            buildEntriesFilterBar(context, widget.planId),
                            const SizedBox(height: 15),
                            buildMultipleButtons(context, widget.planId),
                            const SizedBox(height: 15),
                            rentalProvider.otherLoading
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
                                : rentalProvider.allEntries.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 50),
                                    child: Text(
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("noRegEntriesText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                          height:
                                              Utils.setHeight(context) * 0.03,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: rentalProvider.allEntries.length,
                                  itemBuilder: (context, index) {
                                    final allRegulaEntriesData =
                                        rentalProvider.allEntries[index];
                                    final isSelected = selectedEntryIds
                                        .contains(allRegulaEntriesData.id);
                                    return Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
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
                                                          "Date:",
                                                          allRegulaEntriesData
                                                              .date,
                                                        ),
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("expenseText") ?? ''}:",
                                                          (() {
                                                            final expenseType =
                                                                locale == 'fr'
                                                                    ? allRegulaEntriesData
                                                                        .expenseTypeFr
                                                                    : allRegulaEntriesData
                                                                        .expenseType;

                                                            final isOtherExpense =
                                                                (auth.user?.regCountry ==
                                                                        'ca' &&
                                                                    allRegulaEntriesData
                                                                            .expenseType ==
                                                                        'Other expenses') ||
                                                                (auth.user?.regCountry ==
                                                                        'us' &&
                                                                    allRegulaEntriesData
                                                                            .expenseType ==
                                                                        'Other (list)');

                                                            final hasOtherName =
                                                                allRegulaEntriesData
                                                                        .otherExpenseName !=
                                                                    null &&
                                                                allRegulaEntriesData
                                                                    .otherExpenseName!
                                                                    .isNotEmpty;

                                                            if (isOtherExpense &&
                                                                hasOtherName) {
                                                              return "$expenseType - ${allRegulaEntriesData.otherExpenseName}";
                                                            }

                                                            return expenseType ??
                                                                '';
                                                          })(),
                                                        ),

                                                        if (allRegulaEntriesData
                                                                    .expenseType ==
                                                                'Other expenses (BusAuto)' ||
                                                            allRegulaEntriesData
                                                                    .expenseType ==
                                                                'Other expenses' ||
                                                            allRegulaEntriesData
                                                                    .expenseType ==
                                                                'Repairs' ||
                                                            allRegulaEntriesData
                                                                    .expenseType ==
                                                                'Repairs and maintenance' ||
                                                            allRegulaEntriesData
                                                                    .expenseType ==
                                                                'Other (list)')
                                                          _rowWidget(
                                                            "${AppLocalizations.of(context)!.translate("onlyRentalText") ?? ''}:",
                                                            allRegulaEntriesData
                                                                .onlyForRental,
                                                          ),

                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("incomeTypeText") ?? ''}:",
                                                          allRegulaEntriesData
                                                              .incomeTypeName
                                                              ?.toString(),
                                                        ),
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("amountText") ?? ''}:",
                                                          allRegulaEntriesData
                                                              .amount
                                                              ?.toString(),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${AppLocalizations.of(context)!.translate("proofText") ?? ''}: ",
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            allRegulaEntriesData
                                                                            .proof !=
                                                                        null &&
                                                                    allRegulaEntriesData
                                                                        .proof!
                                                                        .isNotEmpty
                                                                ? MaterialButton(
                                                                  onPressed: () async {
                                                                    // Updated URL to directly point to S3
                                                                    final proofUrl =
                                                                        Uri.parse(
                                                                          "https://storatax.s3.amazonaws.com/${allRegulaEntriesData.proof}",
                                                                        );

                                                                    if (await canLaunchUrl(
                                                                      proofUrl,
                                                                    )) {
                                                                      await launchUrl(
                                                                        proofUrl,
                                                                        mode:
                                                                            LaunchMode.externalApplication,
                                                                      );
                                                                    } else {
                                                                      Utils.toastMessage(
                                                                        "Could not open link",
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    height: 30,
                                                                    width: 60,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          AppColors
                                                                              .goldenOrangeColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        AppLocalizations.of(
                                                                              context,
                                                                            )!.translate(
                                                                              "viewText",
                                                                            ) ??
                                                                            '',
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              AppColors.whiteColor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : Text(
                                                                  'N/A',
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == "edit") {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => UpdateEntryScreen(
                                                                  planId:
                                                                      widget
                                                                          .planId,
                                                                  allRegularEntriesData:
                                                                      allRegulaEntriesData,
                                                                ),
                                                          ),
                                                        );
                                                      } else if (value ==
                                                          "delete") {
                                                        rentalProvider
                                                            .deleteEntriesApi(
                                                              context,
                                                              allRegulaEntriesData
                                                                      .id ??
                                                                  0,
                                                            )
                                                            .then((success) {
                                                              if (success) {
                                                                setState(() {
                                                                  rentalProvider
                                                                      .allEntries
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
                                                            Icons.edit,
                                                            AppLocalizations.of(
                                                                  context,
                                                                )!.translate(
                                                                  "editText",
                                                                ) ??
                                                                '',
                                                            value: "edit",
                                                          ),
                                                          _popupItem(
                                                            Icons.delete,
                                                            AppLocalizations.of(
                                                                  context,
                                                                )!.translate(
                                                                  "deleteText",
                                                                ) ??
                                                                '',
                                                            color: Colors.red,
                                                            value: "delete",
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
                                          top: 0,
                                          right: 5,
                                          child: Checkbox(
                                            value: isSelected,
                                            activeColor:
                                                AppColors.goldenOrangeColor,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedEntryIds.add(
                                                    allRegulaEntriesData.id!,
                                                  );
                                                } else {
                                                  selectedEntryIds.remove(
                                                    allRegulaEntriesData.id,
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
    String? value,
  }) {
    return PopupMenuItem<String>(
      value: value ?? text,
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

  Widget _rowWidget(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

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
