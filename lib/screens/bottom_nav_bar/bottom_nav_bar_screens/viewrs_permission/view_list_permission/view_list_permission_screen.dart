import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/viewrs_permission/update_viewrs/update_viewrs_screen.dart';
import 'package:storatax/view_models/viewrs_view_model/viewrs_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../res/components/app_localization.dart';
import '../../../../../utils/app_colors.dart';

class ViewListPermissionScreen extends StatefulWidget {
  const ViewListPermissionScreen({super.key});

  @override
  State<ViewListPermissionScreen> createState() =>
      _ViewListPermissionScreenState();
}

class _ViewListPermissionScreenState extends State<ViewListPermissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewrsViewModel>().getAllViewrsApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewrsViewModel>(
      builder: (context, viewrs, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("viewersTitleText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("manageViewersText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              context.pushNamed("createViewrs");
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
                        const SizedBox(height: 15),
                        if (viewrs.isLoading)
                          SizedBox(
                            height: Utils.setHeight(context) * 0.6,
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
                        else if (viewrs.allViewrs.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("noViewersText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewrs.allViewrs.length,
                            itemBuilder: (context, index) {
                              final viewrsList = viewrs.allViewrs[index];
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
                                                "${AppLocalizations.of(context)!.translate("firstNameText") ?? ''}:",
                                                " ${viewrsList.firstName}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}:",
                                                " ${viewrsList.lastName}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("emailText") ?? ''}:",
                                                " ${viewrsList.email}",
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
                                                  builder: (context) => UpdateViewrPermissionScreen(
                                                    data: viewrsList,
                                                  ),
                                                ),
                                              );
                                            } else if (value == "delete") {
                                              viewrs.deleteViewrsApi(context, viewrsList.id ?? 0).then((success) {
                                                if (success) {
                                                  setState(() {
                                                    viewrs.allViewrs.removeAt(index);
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            _popupItem(Icons.edit, AppLocalizations.of(context)!.translate("editText") ?? '', value: "edit"),
                                            _popupItem(Icons.delete, AppLocalizations.of(context)!.translate("deleteText") ?? '', color: Colors.red, value: "delete"),
                                          ],
                                        )
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
      IconData icon,
      String text, {
        Color color = Colors.black,
        required String value,
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
