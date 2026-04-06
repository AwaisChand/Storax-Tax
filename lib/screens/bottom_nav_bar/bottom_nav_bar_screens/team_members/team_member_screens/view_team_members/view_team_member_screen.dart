import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/team_members/team_member_screens/update_team_member/update_team_member_screen.dart';
import 'package:storatax/view_models/team_member_view_model/team_member_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';

class ViewTeamMembersScreen extends StatefulWidget {
  const ViewTeamMembersScreen({super.key});

  @override
  State<ViewTeamMembersScreen> createState() => _ViewTeamMembersScreenState();
}

class _ViewTeamMembersScreenState extends State<ViewTeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teamVM = context.read<TeamMemberViewModel>();
      final result = await teamVM.getAllTeamMemberApi();
      Utils.toastMessage(result["message"]);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamMemberViewModel>(
      builder: (context, team, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("teamMembersText") ??
                '',
            text2:
                AppLocalizations.of(
                  context,
                )!.translate("manageTeamMembersText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              context.pushNamed("createTeam");
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
                        if (team.isLoading)
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
                        else if (team.allData.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("noTeamMembersText") ??
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
                            itemCount: team.allData.length,
                            itemBuilder: (context, index) {
                              final teamData = team.allData[index];
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
                                                " ${teamData.firstName}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}:",
                                                " ${teamData.lastName}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("emailText") ?? ''}:",
                                                " ${teamData.email}",
                                              ),
                                              _rowWidget(
                                                "${AppLocalizations.of(context)!.translate("teamForText") ?? ''}:",
                                                " ${teamData.teamFor}",
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
                                                  builder: (context) => UpdateTeamMemberScreen(
                                                    data: teamData,
                                                  ),
                                                ),
                                              );
                                            } else if (value == "delete") {
                                              team.deleteTeamMemberApi(context, teamData.id ?? 0).then((success) {
                                                if (success) {
                                                  setState(() {
                                                    team.allData.removeAt(index);
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            _popupItem(
                                              icon: Icons.edit,
                                              text: AppLocalizations.of(context)!.translate("editText") ?? '',
                                              value: "edit", // internal value
                                            ),
                                            _popupItem(
                                              icon: Icons.delete,
                                              text: AppLocalizations.of(context)!.translate("deleteText") ?? '',
                                              color: Colors.red,
                                              value: "delete", // internal value
                                            ),
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

  PopupMenuItem<String> _popupItem({
    required IconData icon,
    required String text,
    String? value,
    Color color = Colors.black,
  }) {
    return PopupMenuItem<String>(
      value: value ?? text, // use internal value if provided
      child: Row(
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
