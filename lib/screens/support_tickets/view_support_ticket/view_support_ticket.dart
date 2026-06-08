import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/ticket_support_view_model/ticket_support_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/ticket_support_model/ticket_support_model.dart';
import '../../../res/app_assets.dart';
import '../../../res/components/app_drawer.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';
import '../../../view_models/rental_property_view_model/rental_property_view_model.dart';

class ViewSupportTicket extends StatefulWidget {
  const ViewSupportTicket({super.key, required this.ticketSupport});
  final TicketSupport ticketSupport;

  @override
  State<ViewSupportTicket> createState() => _ViewSupportTicketState();
}

class _ViewSupportTicketState extends State<ViewSupportTicket> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final ticketProvider = context.watch<TicketSupportViewModel>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: CustomAppBar(
        text1:
            "${AppLocalizations.of(context)!.translate("ticketText")} ${widget.ticketSupport.id}",
        text2:
            locale == 'fr'
                ? widget.ticketSupport.featureFr ?? ''
                : widget.ticketSupport.feature ?? '',
        // showBackButton: true,
        // onBackTap: () => Navigator.pop(context),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            right: 20,
            left: 20,
            top: 20,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Status Summary Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blackColor, width: 0.5),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: [
                    _rowWidget("${AppLocalizations.of(
                      context,
                    )!.translate("statusText")}:",
                    "${widget.ticketSupport.status}"),
                    const SizedBox(height: 5),
                    _rowWidget(
                      "${AppLocalizations.of(
                        context,
                      )!.translate("assignedText")}:",
                      "${widget.ticketSupport.assignedTo}",
                    ),
                    const SizedBox(height: 5),
                    _rowWidget(
                      "${AppLocalizations.of(
                        context,
                      )!.translate("createdText")}:",
                      "${widget.ticketSupport.createdAt}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Attachments Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blackColor, width: 0.5),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                            context,
                          )!.translate("attachmentsText") ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.ticketSupport.attachments != null &&
                        widget.ticketSupport.attachments!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            widget.ticketSupport.attachments!.map((file) {
                              return InkWell(
                                onTap: () {
                                  if (file.url != null) openUrl(file.url!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    file.originalName ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      )
                    else
                      Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("noAttachmentsText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- CONVERSATION BOX ---
              Text(
                "Conversation",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("conversationDescText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.ticketSupport.messages != null &&
                        widget.ticketSupport.messages!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.ticketSupport.messages!.length,
                        itemBuilder: (context, index) {
                          final msg = widget.ticketSupport.messages![index];
                          // Match role based on API response values ('client' vs rest)
                          final isClient = msg.role == 'client';

                          return Align(
                            alignment:
                                isClient
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: Utils.setWidth(context) * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isClient
                                        ? AppColors.goldenOrangeColor
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    isClient
                                        ? null
                                        : Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${msg.userName} (${msg.roleLabel})",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isClient
                                                  ? Colors.white
                                                  : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        msg.createdAt ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color:
                                              isClient
                                                  ? Colors.white70
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg.message ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color:
                                          isClient
                                              ? Colors.white
                                              : AppColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Text(
                          "No messages yet.",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- REPLY BOX ---
              Text(
                AppLocalizations.of(context)!.translate("replyText") ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _replyController,
                maxLines: 4,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  // hintText: "Type your message here...",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFF39C12),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Send Reply Button
              SizedBox(
                width: 140,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    final text = _replyController.text.trim();

                    if (text.isEmpty) {
                      Utils.toastMessage("Please enter a ticket reply here");
                      return;
                    }

                    // 👇 Create local message
                    final newMessage = Messages(
                      message: text,
                      role: "client",
                      roleLabel: "Client",
                      userName: "You",
                      createdAt: DateTime.now().toString(),
                    );

                    setState(() {
                      widget.ticketSupport.messages?.add(newMessage);
                    });

                    _replyController.clear();

                    ticketProvider.replyTicketApi(context, {
                      "message": text,
                    }, widget.ticketSupport.id ?? 0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child:
                      ticketProvider.isLoading
                          ? Center(
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          )
                          : Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("sendReplyText") ??
                                '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
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
