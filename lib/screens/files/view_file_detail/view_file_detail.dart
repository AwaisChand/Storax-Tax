import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_file_model/get_file_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';

class ViewFileDetail extends StatefulWidget {
  const ViewFileDetail({
    super.key,
    required this.fileData,
    required this.uploads,
  });

  final FileData fileData;
  final List<Uploads>? uploads;

  @override
  State<ViewFileDetail> createState() => _ViewFileDetailState();
}

class _ViewFileDetailState extends State<ViewFileDetail> {
  late List<Uploads> uploadsList;

  @override
  void initState() {
    super.initState();
    uploadsList = widget.uploads ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaxManagerViewModel>();

    return Scaffold(
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
            child: Column(
              children: [
                /// Header
                Container(
                  height: Utils.setHeight(context) * 0.15,
                  padding: EdgeInsets.only(
                    top: Utils.setHeight(context) * 0.06,
                    right: 20,
                    left: 20,
                  ),
                  width: double.infinity,
                  decoration:
                   BoxDecoration(color: AppColors.goldenOrangeColor),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back_ios_new_outlined),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate("taxesDetailsText") ??
                                  '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .translate("viewDetailsText") ??
                                  '',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// Card
                Container(
                  width: double.infinity,
                  margin:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                    Border.all(color: AppColors.blackColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate("taxManagerInfoText") ??
                            '',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      _rowWidget(
                        "${AppLocalizations.of(context)!
                            .translate("taxManagerName") ?? ''}:",
                        widget.fileData.fileName ?? '',
                      ),
                      _rowWidget(
                        "${AppLocalizations.of(context)!
                            .translate("cateText") ?? ''}:",
                        widget.fileData.category ?? '',
                      ),
                      _rowWidget(
                        "${AppLocalizations.of(context)!
                            .translate("yearText") ?? ''}:",
                        widget.fileData.year ?? '',
                      ),
                      _rowWidget("Date:", widget.fileData.date ?? ''),
                      _rowWidget(
                        "${AppLocalizations.of(context)!
                            .translate("commentsText") ?? ''}:",
                        widget.fileData.comments ?? '',
                      ),

                      const SizedBox(height: 15),

                      /// Download
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .translate("downFileText") ??
                                '',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          InkWell(
                            onTap: () {
                              provider.generateAndOpenPDF(
                                fileName: widget.fileData.fileName ?? '',
                                category: widget.fileData.category ?? '',
                                comments: widget.fileData.comments ?? '',
                                filePaths: widget.fileData.uploads
                                    ?.map((e) => e.filePath ?? '')
                                    .toList(),
                              );
                            },
                            child: const Icon(Icons.download),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// Uploaded Files
                      if (uploadsList.isNotEmpty) ...[
                        Text(
                          "Uploaded Files",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: uploadsList.map((upload) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: upload.filePath ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child:
                                            CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),

                                /// Delete Button
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      bool success = await provider
                                          .deleteUploadedFileApi(
                                        context,
                                        upload.id ?? 0,
                                      );

                                      if (success) {
                                        setState(() {
                                          uploadsList.remove(upload);
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: GoogleFonts.poppins(
              textStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                textStyle:
                const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}