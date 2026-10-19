import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/instructions_model/instructions_model.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/instructions_view_model/instructions_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../utils/utils.dart';

class InstructionDetailScreen extends StatefulWidget {
  const InstructionDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<InstructionDetailScreen> createState() =>
      _InstructionDetailScreenState();
}

class _InstructionDetailScreenState extends State<InstructionDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructionsViewModel>().ensureInstructionsLoaded(context);
    });
  }

  bool _isPlaceholder(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return true;
    return text.toUpperCase() == 'TODO';
  }

  bool _isHighlightStep(StepItem step) {
    final question = (step.question ?? '').toLowerCase();
    return question.contains('important') ||
        question.contains('quick reminder') ||
        question.contains('rappel');
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Consumer<InstructionsViewModel>(
      builder: (context, getInstructions, _) {
        final instruction = getInstructions.bySlug(widget.slug);
        final title =
            instruction == null
                ? ''
                : instruction.localizedTitle(locale).trim().isNotEmpty
                ? instruction.localizedTitle(locale)
                : instruction.localizedNavLabel(locale);
        final subtitle =
            instruction == null
                ? ''
                : instruction.localizedSubtitle(locale);
        final footer =
            instruction == null ? '' : instruction.localizedFooter(locale);
        final steps = instruction?.localizedSteps(locale) ?? [];
        final sections = instruction?.localizedSections(locale) ?? [];

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: const AppDrawer(),
          appBar: CustomAppBar(
            text1: "Instructions",
            text2: title,
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
                    getInstructions.isLoading && instruction == null
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
                              if (!_isPlaceholder(subtitle))
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    4,
                                  ),
                                  child: Text(
                                    subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              if (steps.isNotEmpty)
                                ...steps.map((step) {
                                  final highlight = _isHighlightStep(step);
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
                                        color:
                                            highlight
                                                ? AppColors.goldenOrangeColor
                                                : AppColors.blackColor,
                                        width: highlight ? 1.2 : 0.5,
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
                                })
                              else
                                ...sections.map((section) {
                                  final sectionSteps = section.steps ?? [];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ((section.title ?? '')
                                          .trim()
                                          .isNotEmpty)
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
                                      ...sectionSteps.map((step) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            borderRadius: BorderRadius.circular(
                                              17,
                                            ),
                                            border: Border.all(
                                              color: AppColors.blackColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                step.text ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (step.screenshotUrl != null &&
                                                  step
                                                      .screenshotUrl!
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10,
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.network(
                                                      step.screenshotUrl!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              if (!_isPlaceholder(footer))
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    24,
                                  ),
                                  child: Text(
                                    footer,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
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
