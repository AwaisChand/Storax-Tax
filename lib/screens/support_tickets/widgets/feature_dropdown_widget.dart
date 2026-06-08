import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/ticket_support_view_model/ticket_support_view_model.dart';

import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';

class CreateTicketForm extends StatefulWidget {
  const CreateTicketForm({super.key});

  @override
  State<CreateTicketForm> createState() => _CreateTicketFormState();
}

class _CreateTicketFormState extends State<CreateTicketForm> {
  String? selectedFeatureKey;

  final TextEditingController otherController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late List<Map<String, String>> features;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final t = AppLocalizations.of(context)!;

    features = [
      {"key": "feature1", "label": t.translate("feature1") ?? ""},
      {"key": "feature2", "label": t.translate("feature2") ?? ""},
      {"key": "feature3", "label": t.translate("feature3") ?? ""},
      {"key": "feature4", "label": t.translate("feature4") ?? ""},
      {"key": "feature5", "label": t.translate("feature5") ?? ""},
      {"key": "feature6", "label": t.translate("feature6") ?? ""},
      {"key": "feature7", "label": t.translate("feature7") ?? ""},
      {"key": "feature8", "label": t.translate("feature8") ?? ""},
      {"key": "feature9", "label": t.translate("feature9") ?? ""},
      {"key": "feature10", "label": t.translate("feature10") ?? ""},
    ];

    if (selectedFeatureKey != null &&
        !features.any((e) => e["key"] == selectedFeatureKey)) {
      selectedFeatureKey = null;
    }
  }

  String getSelectedFeatureLabel() {
    return features.firstWhere(
          (e) => e["key"] == selectedFeatureKey,
          orElse: () => {"key": "", "label": ""},
        )["label"] ??
        "";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();

    return Consumer<TicketSupportViewModel>(
      builder: (context, ticketSupport, _) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FEATURE DROPDOWN
                Text(
                  AppLocalizations.of(context)!.translate("featureText") ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFeatureKey,
                      isExpanded: true,
                      hint: Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("selectFeatureText") ??
                            "",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      items:
                          features.map((item) {
                            return DropdownMenuItem<String>(
                              value: item["key"],
                              child: Text(
                                item["label"] ?? "",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFeatureKey = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// OTHER FIELD
                if (selectedFeatureKey == "feature10") ...[
                  Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("otherFeatureText") ??
                        "",
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: otherController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                /// DESCRIPTION
                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// ATTACHMENTS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                            context,
                          )!.translate("attachmentsText") ??
                          "",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        await authProvider.pickMultipleImages();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child:  Row(
                          children: [
                            Icon(Icons.attach_file),
                            SizedBox(width: 10),
                            Text("Choose Files",style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (authProvider.pickedImages.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          authProvider.pickedImages.length,
                          (index) {
                            final file = authProvider.pickedImages[index];

                            return Stack(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(file.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      authProvider.removeImage(index);
                                    },
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                /// BUTTONS
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () async {
                          if (selectedFeatureKey == null) {
                            Utils.toastMessage("Please select a feature");
                            return;
                          }

                          if (selectedFeatureKey == "feature10" &&
                              otherController.text.isEmpty) {
                            Utils.toastMessage("Please enter other feature");
                            return;
                          }

                          if (descriptionController.text.isEmpty) {
                            Utils.toastMessage("Please enter description");
                            return;
                          }

                          final data = {
                            "feature": getSelectedFeatureLabel(),
                            "feature_other":
                                selectedFeatureKey == "feature10"
                                    ? otherController.text
                                    : "",
                            "description": descriptionController.text,
                          };

                          await context
                              .read<TicketSupportViewModel>()
                              .createTicketApi(
                                context,
                                data,
                                authProvider.pickedImages
                                    .map((x) => File(x.path))
                                    .toList(),
                              );
                        },
                        child:
                            ticketSupport.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                                : Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("submitTicketText") ??
                                      "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(
                                context,
                              )!.translate("cancelText") ??
                              "",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
