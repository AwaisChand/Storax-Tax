import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/entry_screens/add_entry_screen.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../entry/entry_screens/all_regular_entry_screen.dart';
import '../entry/entry_screens/graphic_entry_screen.dart';
import '../property_owner_screen/property_owner_screen.dart';
import '../rental_income_type/rental_income_type_screen/rental_income_type_list_screen.dart';
import '../rental_property_addressing/rental_poperty_addressing_screen/rental_property_addressing_screen.dart';

enum RentalAction { address, owner, incomeType, addEntry, allEntries, database }

class RentalPropertyTabScreen extends StatefulWidget {
  const RentalPropertyTabScreen({super.key});

  @override
  State<RentalPropertyTabScreen> createState() =>
      _RentalPropertyTabScreenState();
}

class _RentalPropertyTabScreenState extends State<RentalPropertyTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RentalPropertyViewModel>();
      provider.getRentalPropertyPlanApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final rentalTypes = [
      {
        "action": RentalAction.address,
        "label":
            AppLocalizations.of(
              context,
            )!.translate("propertyAddressSettingsText") ??
            '',
      },
      {
        "action": RentalAction.owner,
        "label":
            AppLocalizations.of(context)!.translate("propertyOwnerText") ?? '',
      },
      {
        "action": RentalAction.incomeType,
        "label":
            AppLocalizations.of(context)!.translate("incomeTypeText") ?? '',
      },
      {
        "action": RentalAction.addEntry,
        "label": AppLocalizations.of(context)!.translate("addEntryText") ?? '',
      },
      {
        "action": RentalAction.allEntries,
        "label":
            AppLocalizations.of(context)!.translate("allRegEntriesText") ?? '',
      },
      {
        "action": RentalAction.database,
        "label": AppLocalizations.of(context)!.translate("databaseText") ?? '',
      },
    ];
    final locale = Localizations.localeOf(context).languageCode;

    return Consumer<RentalPropertyViewModel>(
      builder: (context, rentalProvider, _) {
        final rentals = rentalProvider.getRentalPropertyPlanData;
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("rentalPropertyText") ??
                '',
            text2:
                AppLocalizations.of(
                  context,
                )!.translate("rentalPropertyPlansText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          body: Stack(
            children: [
              // background
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

              // content
              if (rentalProvider.isLoading)
                Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.blackColor,
                    ),
                  ),
                )
              else if (rentals.isEmpty)
                Center(
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("noRentalFoundText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    final rental = rentals[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale == 'fr'
                                  ? rental.nameFr ?? ''
                                  : rental.nameEn ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // rental type options
                            Column(
                              children:
                                  rentalTypes.map((item) {
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        item["label"] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      onTap: () {
                                        switch (item["action"]) {
                                          case RentalAction.address:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        RentalPropertyAddressingScreen(
                                                          planId: rental.id!,
                                                        ),
                                              ),
                                            );
                                            break;

                                          case RentalAction.owner:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => PropertyOwnerScreen(
                                                      planId: rental.id!,
                                                    ),
                                              ),
                                            );
                                            break;

                                          case RentalAction.incomeType:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        RentalIncomeTypeListScreen(
                                                          planId: rental.id!,
                                                        ),
                                              ),
                                            );
                                            break;

                                          case RentalAction.addEntry:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => AddEntryScreen(
                                                      planId: rental.id,
                                                    ),
                                              ),
                                            );
                                            break;

                                          case RentalAction.allEntries:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        AllRegularEntryScreen(
                                                          planId: rental.id!,
                                                        ),
                                              ),
                                            );
                                            break;

                                          case RentalAction.database:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => GraphicEntryScreen(
                                                      planId: rental.id!,
                                                    ),
                                              ),
                                            );
                                            break;
                                        }
                                      },
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
