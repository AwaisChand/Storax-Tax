import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
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
              context.pushNamed('ticket-list-system');
            },
          ),

          /// --- NEWLY ADDED: INSTRUCTIONS COLLAPSIBLE DROPDOWN ---
          Theme(
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
                  "Instructions",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                iconColor: Colors.blue,
                collapsedIconColor: Colors.blue,
                childrenPadding: const EdgeInsets.only(left: 24),
                children: [
                  _buildSubMenuBulletItem(
                    context,
                    title:
                        AppLocalizations.of(
                          context,
                        )!.translate("gasReceiptManagerText") ??
                        '',
                    onTap: () {
                      context.pushNamed("inst-gas-receipt");
                    },
                  ),
                  _buildSubMenuBulletItem(
                    context,
                    title:
                        AppLocalizations.of(context)!.translate("uberText") ??
                        '',
                    onTap: () {
                      context.pushNamed("uber");

                    },
                  ),
                  _buildSubMenuBulletItem(
                    context,
                    title:
                        AppLocalizations.of(context)!.translate("taxManText") ??
                        '',
                    onTap: () {
                      context.pushNamed("tax-manager");

                    },
                  ),
                  _buildSubMenuBulletItem(
                    context,
                    title:
                        AppLocalizations.of(context)!.translate("rentalText") ?? '',
                    onTap: () {
                      context.pushNamed("rental");

                    },
                  ),
                ],
              ),
            ),
          ),

          if (authProvider.user?.role != 'viewer' &&
              authProvider.user?.role != 'team' &&
              authProvider.user?.regCountry.toLowerCase() != 'us')
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
}
