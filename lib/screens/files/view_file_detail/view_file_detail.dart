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
                          children: uploadsList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final upload = entry.value;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _openImageViewer(index),
                                  child: ClipRRect(
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

  void _openImageViewer(int initialIndex) {
    final urls =
        uploadsList
            .map((e) => e.filePath ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
    if (urls.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) {
          return _FullScreenImageViewer(
            imageUrls: urls,
            initialIndex: initialIndex.clamp(0, urls.length - 1),
          );
        },
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

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  if (widget.imageUrls.length > 1)
                    Text(
                      '${_index + 1} / ${widget.imageUrls.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}