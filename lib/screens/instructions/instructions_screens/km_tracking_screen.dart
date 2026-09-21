import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/instructions_view_model/instructions_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';

class KmTrackingInstructionScreen extends StatefulWidget {
  const KmTrackingInstructionScreen({super.key});

  @override
  State<KmTrackingInstructionScreen> createState() =>
      _KmTrackingInstructionScreenState();
}

class _KmTrackingInstructionScreenState
    extends State<KmTrackingInstructionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructionsViewModel>().getInstructionsApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Consumer<InstructionsViewModel>(
      builder: (context, getInstructions, _) {
        final kmInstruction = getInstructions.instructions
            .where((e) => e.slug == "km-tracking")
            .toList();
        final fallbackTitle =
            AppLocalizations.of(context)!.translate("kmTitleText") ?? '';
        final appBarTitle = kmInstruction.isNotEmpty
            ? kmInstruction.first.localizedTitle(locale)
            : fallbackTitle;

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1: "Instructions",
            text2: appBarTitle.isNotEmpty ? appBarTitle : fallbackTitle,
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
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
                child: getInstructions.isLoading
                    ? Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: AppColors.blackColor,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: kmInstruction.length,
                              itemBuilder: (context, index) {
                                final instruction = kmInstruction[index];

                                final steps = locale == 'fr'
                                    ? instruction.steps?.fr ?? []
                                    : instruction.steps?.en ?? [];

                                return Column(
                                  children: steps.map((step) {
                                    final isHighlight =
                                        (step.question ?? '')
                                            .toUpperCase()
                                            .contains('IMPORTANT') ||
                                        (step.question ?? '')
                                            .toLowerCase()
                                            .contains('quick reminder') ||
                                        (step.question ?? '')
                                            .toLowerCase()
                                            .contains('rappel');

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: isHighlight
                                              ? AppColors.goldenOrangeColor
                                              : AppColors.blackColor,
                                          width: isHighlight ? 1.2 : 0.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              step.question ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              step.answer ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
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
}
