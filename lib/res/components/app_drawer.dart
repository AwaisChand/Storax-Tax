import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/instructions_view_model/instructions_view_model.dart';
import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';
import 'app_localization.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();
    final plans = context.watch<PricingPlansViewModel>();
    final userRole = authProvider.user?.role;
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManager = planNames.any(
      (n) => n.contains('business tax manager'),
    );
    final isGasReceiptsEnterprise = planNames.any(
      (n) => n.contains('gas receipts manager - business version'),
    );
    final canShowTeamManagement =
        userRole != "team" && (isBusinessTaxManager || isGasReceiptsEnterprise);

    final isFreeGasPlan = planNames.any(
      (n) => n.contains('free version') || n.contains('basic'),
    );
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset(
                AppAssets.appLogo,
                height: Utils.setHeight(context) * 0.2,
                width: Utils.setHeight(context) * 0.2,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// Dashboard
          _buildDrawerItem(
            context,
            title:
                AppLocalizations.of(context)!.translate("dashboardText") ?? '',
            iconPath: AppAssets.gasolineIcon,
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Future.microtask(() {
                context.goNamed('bottomNavBar');
                BottomNavBar.of(context)?.switchTab(0);
              });
            },
            color: AppColors.blackColor,
          ),

          /// Team Management
          if (canShowTeamManagement)
            _buildDrawerIconItem(
              context,
              title:
                  AppLocalizations.of(
                    context,
                  )!.translate("teamManagementText") ??
                  '',
              icon: Icons.group,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                context.pushNamed('viewTeamMember');
              },
            ),

          /// View Access
          if (authProvider.user?.role != 'viewer' &&
              authProvider.user?.role != 'team')
            _buildDrawerIconItem(
              context,
              title:
                  AppLocalizations.of(context)!.translate("viewAccessText") ??
                  '',
              icon: Icons.group,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                context.pushNamed('allViewrs');
              },
            ),

          /// Plans
          if (authProvider.user?.role != 'viewer' &&
              authProvider.user?.role != 'team')
            _buildDrawerItem(
              context,
              title: AppLocalizations.of(context)!.translate("plansText") ?? '',
              iconPath: AppAssets.gasolineIcon,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                context.pushNamed('myPlansNested');
              },
              color: AppColors.blackColor,
            ),

          /// Support Tickets


          /// Support Tickets
          _buildDrawerIconItem(
            context,
            title:
            AppLocalizations.of(
              context,
            )!.translate("supportingTicketsText") ??
                '',
            icon: Icons.help_outline,
            onTap: () {
              Scaffold.of(context).closeDrawer();

              if (plans.myPlans.isEmpty ||
                  planNames.every(
                        (n) => n.contains('free version') || n.contains('basic'),
                  )) {
                _showUpgradeDialog(context);
              } else {
                context.pushNamed('ticket-list-system');
              }
            },
          ),

          /// Instructions
          if (authProvider.user?.role != 'team')
            const _InstructionsExpansionTile(),
          if (authProvider.user?.regCountry.trim().toLowerCase() != 'us')
            _buildDrawerItem(
              context,
              title:
                  AppLocalizations.of(context)?.translate("changeLang") ??
                  "Change Language",
              iconPath: AppAssets.translatorImg,
              onTap: () {
                Scaffold.of(context).closeDrawer();

                final currentLang =
                    Localizations.localeOf(context).languageCode;

                if (currentLang == "en") {
                  MyApp.setLocale(context, const Locale('fr'));
                } else {
                  MyApp.setLocale(context, const Locale('en'));
                }
              },
            ),
        ],
      ),
    );
  }

  /// Generic drawer item with image icon
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required String iconPath,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Image.asset(
          iconPath,
          height: 20,
          fit: BoxFit.contain,
          color: color,
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13)),
        onTap: onTap,
      ),
    );
  }

  /// Generic drawer item with IconData
  Widget _buildDrawerIconItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: AppColors.blackColor),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13)),
        onTap: onTap,
      ),
    );
  }

  /// Helper widget to build the sub-items with custom bullet points matching the image
}

class _InstructionNavItem {
  const _InstructionNavItem({
    required this.slug,
    required this.en,
    required this.fr,
  });

  final String slug;
  final String en;
  final String fr;
}

const _fallbackInstructionMenu = [
  _InstructionNavItem(
    slug: 'gas-receipts',
    en: 'Gas Receipts Manager',
    fr: "Gestionnaire de reçus d'essence",
  ),
  _InstructionNavItem(
    slug: 'uber-gst-qst',
    en: 'UBER GST/QST',
    fr: 'UBER TPS/TVQ',
  ),
  _InstructionNavItem(
    slug: 'tax-manager',
    en: 'Tax Manager',
    fr: "Gestionnaire d'impôts",
  ),
  _InstructionNavItem(
    slug: 'km-tracking',
    en: 'KM Tracking',
    fr: 'Suivi du kilométrage',
  ),
  _InstructionNavItem(
    slug: 'rental-property',
    en: 'Rental Property Manager',
    fr: 'Gestionnaire de propriété locative',
  ),
  _InstructionNavItem(
    slug: 'team-management',
    en: 'Team Management',
    fr: "Gestion d'équipe",
  ),
  _InstructionNavItem(
    slug: 'viewers-management',
    en: 'Viewers Management',
    fr: 'Gestion des utilisateurs en lecture seule',
  ),
  _InstructionNavItem(
    slug: 'support-tickets',
    en: 'Support Tickets',
    fr: 'Billets de support',
  ),
  _InstructionNavItem(slug: 'plans', en: 'Plans', fr: 'Forfaits'),
  _InstructionNavItem(
    slug: 'personal-information',
    en: 'Personal Information',
    fr: 'Renseignements personnels',
  ),
];

class _InstructionsExpansionTile extends StatefulWidget {
  const _InstructionsExpansionTile();

  @override
  State<_InstructionsExpansionTile> createState() =>
      _InstructionsExpansionTileState();
}

class _InstructionsExpansionTileState
    extends State<_InstructionsExpansionTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InstructionsViewModel>().ensureInstructionsLoaded(context);
    });
  }

  void _openInstruction(String slug) {
    Scaffold.of(context).closeDrawer();
    context.pushNamed('instruction-detail', pathParameters: {'slug': slug});
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final instructions = context.watch<InstructionsViewModel>().instructions;

    final children =
        instructions.isNotEmpty
            ? instructions
                .where((item) => (item.slug ?? '').isNotEmpty)
                .map((item) {
                  final slug = item.slug!;
                  final title = item.localizedNavLabel(locale);
                  return _instructionBullet(
                    context,
                    title: title.isNotEmpty ? title : slug,
                    onTap: () => _openInstruction(slug),
                  );
                })
                .toList()
            : _fallbackInstructionMenu
                .map(
                  (item) => _instructionBullet(
                    context,
                    title: locale == 'fr' ? item.fr : item.en,
                    onTap: () => _openInstruction(item.slug),
                  ),
                )
                .toList();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            Icons.assignment_outlined,
            color: AppColors.blackColor,
          ),
          title: Text(
            AppLocalizations.of(context)!.translate("instructionsMenuText") ??
                'Instructions',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          iconColor: Colors.blue,
          collapsedIconColor: Colors.blue,
          childrenPadding: const EdgeInsets.only(left: 24),
          children: children,
        ),
      ),
    );
  }

  Widget _instructionBullet(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return _buildSubMenuBulletItem(context, title: title, onTap: onTap);
  }
}

Widget _buildSubMenuBulletItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      horizontalTitleGap: 8,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
}

void _showUpgradeDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.info_outline, size: 30, color: Colors.blue),
              ),

              const SizedBox(height: 16),

              /// Title
              Text(
                AppLocalizations.of(
                      context,
                    )!.translate("ticketUnavailableText") ??
                    '',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              /// Subtitle
              Text(
                AppLocalizations.of(context)!.translate("ticketdetailText") ??
                    '',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// View Plans Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenOrangeColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.pushNamed('myPlansNested');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("viewPlanText") ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Cancel Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("cancelText") ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.whiteColor,
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
