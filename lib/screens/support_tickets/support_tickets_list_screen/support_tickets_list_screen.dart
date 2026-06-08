import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/support_tickets/view_support_ticket/view_support_ticket.dart';
import 'package:storatax/screens/support_tickets/widgets/top_button_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/ticket_support_view_model/ticket_support_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_drawer.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';
import '../../../view_models/rental_property_view_model/rental_property_view_model.dart';

class SupportTicketsListScreen extends StatefulWidget {
  const SupportTicketsListScreen({super.key});

  @override
  State<SupportTicketsListScreen> createState() =>
      _SupportTicketsListScreenState();
}

class _SupportTicketsListScreenState extends State<SupportTicketsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const String ACTION_VIEW = "view";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketSupportViewModel>().getAllTicketSupports(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Consumer<TicketSupportViewModel>(
      builder: (context, ticketSupport, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("supportingTicketsText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("descTicketText") ?? '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              try {
                final provider = context.read<RentalPropertyViewModel>();
                provider.getRentalPropertyPlanApi(context);
              } catch (e) {
                debugPrint("Drawer API error: $e");
              }
            }
          },
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        topButtonWidget(context),
                        const SizedBox(height: 20),

                        ticketSupport.isLoading
                            ? Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: ticketSupport.ticketSupport.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 20),
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
                                                      "${AppLocalizations.of(context)!.translate("featureText") ?? ''}:",
                                                      ticketSupport
                                                              .ticketSupport[index]
                                                              .feature ??
                                                          '',
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${AppLocalizations.of(context)!.translate("statusText") ?? ''}:",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Container(
                                                          height: 30,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                AppColors
                                                                    .goldenOrangeColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  15,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              locale == 'fr'
                                                                  ? ticketSupport
                                                                          .ticketSupport[index]
                                                                          .statusLabelFr ??
                                                                      ''
                                                                  : ticketSupport
                                                                          .ticketSupport[index]
                                                                          .statusLabel ??
                                                                      '',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    _rowWidget(
                                                      "${AppLocalizations.of(context)!.translate("assignedText") ?? ''}:",
                                                      ticketSupport
                                                              .ticketSupport[index]
                                                              .assignedTo ??
                                                          '',
                                                    ),
                                                    _rowWidget(
                                                      "${AppLocalizations.of(context)!.translate("lastReplyText") ?? ''}:",
                                                      ticketSupport
                                                              .ticketSupport[index]
                                                              .lastReplyAt ??
                                                          '',
                                                    ),
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
                                                            ) => ViewSupportTicket(
                                                              ticketSupport:
                                                                  ticketSupport
                                                                      .ticketSupport[index],
                                                            ),
                                                      ),
                                                    );
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
                                                    ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
