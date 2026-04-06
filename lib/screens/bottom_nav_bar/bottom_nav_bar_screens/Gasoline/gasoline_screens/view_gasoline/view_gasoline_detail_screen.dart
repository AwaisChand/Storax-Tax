import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storatax/models/get_gasoline_list_model/get_gasoline_list_model.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/utils.dart';

class ViewGasolineDetailScreen extends StatelessWidget {
  const ViewGasolineDetailScreen({super.key, required this.gasolineData});

  final Data gasolineData;

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar Section
                Container(
                  height: Utils.setHeight(context) * 0.15,
                  padding: EdgeInsets.only(
                    top: Utils.setHeight(context) * 0.06,
                    right: 20,
                    left: 20,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.goldenOrangeColor),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back_ios_new_outlined),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("gasDetailsText") ??
                                '',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("descViewGasText") ??
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
                    ],
                  ),
                ),

                // Receipt Title
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Text(
                    AppLocalizations.of(context)!.translate("receiptText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: gasolineData.image ?? "",
                      height: Utils.setHeight(context) * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: Utils.setHeight(context) * 0.3,
                            color: Colors.grey.shade300,
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: Utils.setHeight(context) * 0.3,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                    ),
                  ),
                ),

                // Gasoline Info
                Flexible(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: Utils.setHeight(context) * 0.3,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.blackColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("gasInfoText") ??
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
                            "${AppLocalizations.of(context)!.translate("merchantText") ?? ''}:",
                            gasolineData.merchant,
                          ),
                          const SizedBox(height: 10),
                          _rowWidget(
                            "${AppLocalizations.of(context)!.translate("totalText") ?? ''}:",
                            gasolineData.total.toString(),
                          ),
                          const SizedBox(height: 10),
                          _rowWidget(
                            "${AppLocalizations.of(context)!.translate("taxText") ?? ''}:",
                            gasolineData.tax.toString(),
                          ),
                          const SizedBox(height: 10),
                          _rowWidget(
                            "${AppLocalizations.of(context)!.translate("beforeTaxText") ?? ''}:",
                            gasolineData.beforeTaxAmount.toString(),
                          ),
                          const SizedBox(height: 10),
                          _rowWidget(
                            "${AppLocalizations.of(context)!.translate("dateText") ?? ''}:",
                            gasolineData.dateRecieved,
                          ),
                          const SizedBox(height: 10),
                          _rowWidget(
                            "${AppLocalizations.of(context)!.translate("refText") ?? ''}:",
                            gasolineData.reference,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String text1, text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(width: 15),
        Flexible(
          child: Text(
            text2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
