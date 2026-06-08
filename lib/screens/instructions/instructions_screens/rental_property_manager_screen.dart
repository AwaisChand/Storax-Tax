import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/instructions_view_model/instructions_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';

class RentalPropertyManagerScreen extends StatefulWidget {
  const RentalPropertyManagerScreen({super.key});

  @override
  State<RentalPropertyManagerScreen> createState() =>
      _RentalPropertyManagerScreenState();
}

class _RentalPropertyManagerScreenState extends State<RentalPropertyManagerScreen> {
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
        final gasInstruction = getInstructions.instructions
            .where((e) => e.slug == "rental-property")
            .toList();
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1: "Instructions",
            text2:
            AppLocalizations.of(context)!.translate("rentalTitleText") ?? '',
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
                child:
                getInstructions.isLoading
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
                        itemCount: gasInstruction.length,
                        itemBuilder: (context, index) {
                          final instruction = gasInstruction[index];

                          final sections = locale == 'fr'
                              ? instruction.sections?.fr ?? []
                              : instruction.sections?.en ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sections.map((section) {
                              final steps = section.steps ?? [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🔹 SECTION TITLE
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      section.title ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// 🔹 STEPS
                                  ...steps.map((step) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: AppColors.blackColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// ✅ TEXT
                                          Text(
                                            step.text ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          /// ✅ IMAGE (ONLY IF EXISTS)
                                          if (step.screenshotUrl != null &&
                                              step.screenshotUrl!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  step.screenshotUrl!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
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
